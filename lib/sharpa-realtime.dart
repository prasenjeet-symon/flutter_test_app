import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'LiteRT Offline AI',
          themeMode: ThemeMode.system,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.grey[100],
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: Colors.deepPurpleAccent,
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardColor: const Color(0xFF1E1E1E),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
          ),
          home: const SherpaScreen(),
        );
      },
    );
  }
}

class SherpaScreen extends StatefulWidget {
  const SherpaScreen({super.key});

  @override
  State<SherpaScreen> createState() => _SherpaScreenState();
}

class _SherpaScreenState extends State<SherpaScreen>
    with SingleTickerProviderStateMixin {
  // ─── AI Objects ───
  sherpa.OnlineRecognizer? _recognizer;
  sherpa.OnlineStream? _stream;

  // ─── Audio Objects ───
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _micSubscription;

  // ─── Decode Timer (decoupled from audio ingestion) ───
  Timer? _decodeTimer;

  // ─── State ───
  String _displayText = '';
  String _lastFinalText = ''; // Accumulated finalized segments
  String _statusMessage = 'Initializing AI...';
  bool _isReady = false;
  bool _isListening = false;
  bool _isBusy = false; // Guards against rapid start/stop
  double _volumeLevel = 0.0;
  bool _hasMicPermission = false;

  // ─── Animation ───
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _initSherpa();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. INITIALIZE SHERPA ENGINE
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _initSherpa() async {
    try {
      sherpa.initBindings();

      final assetsDir = await getApplicationDocumentsDirectory();

      Future<String> copyAsset(String filename) async {
        final file = File('${assetsDir.path}/$filename');
        if (!await file.exists()) {
          debugPrint('📂 Copying asset: $filename');
          final data = await rootBundle.load('assets/models/sherpa/$filename');
          await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
        }
        return file.path;
      }

      debugPrint('📂 Loading model files...');
      final encoderPath = await copyAsset('encoder.onnx');
      final decoderPath = await copyAsset('decoder.onnx');
      final joinerPath = await copyAsset('joiner.onnx');
      final tokensPath = await copyAsset('tokens.txt');

      final config = sherpa.OnlineRecognizerConfig(
        model: sherpa.OnlineModelConfig(
          transducer: sherpa.OnlineTransducerModelConfig(
            encoder: encoderPath,
            decoder: decoderPath,
            joiner: joinerPath,
          ),
          tokens: tokensPath,
          numThreads: 2, // Use 2 threads for better real-time perf
          modelType: 'zipformer',
          debug: false,
        ),
        feat: const sherpa.FeatureConfig(sampleRate: 16000),
        // Enable endpoint detection for automatic segmentation
        enableEndpoint: true,
        rule1MinTrailingSilence: 2.4, // Long silence → definitely done
        rule2MinTrailingSilence: 0.8, // Short pause after speech → segment
        rule3MinUtteranceLength: 30.0, // Max segment before forced split
      );

      _recognizer = sherpa.OnlineRecognizer(config);
      _stream = _recognizer!.createStream();

      if (!mounted) return;
      setState(() {
        _isReady = true;
        _statusMessage = 'AI Ready. Tap to speak.';
      });
      debugPrint('✅ Sherpa ready');
    } catch (e, stack) {
      debugPrint('❌ Sherpa init error: $e\n$stack');
      if (!mounted) return;
      setState(
        () => _statusMessage = 'Init Error: ${e.toString().split('\n').first}',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. MIC PERMISSION (request once, check status after)
  // ══════════════════════════════════════════════════════════════════════════
  Future<bool> _ensureMicPermission() async {
    if (_hasMicPermission) return true;

    final status = await Permission.microphone.request();
    _hasMicPermission = status == PermissionStatus.granted;

    if (!_hasMicPermission && mounted) {
      setState(() => _statusMessage = 'Microphone permission denied');
    }
    return _hasMicPermission;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 3. START LISTENING
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _startListening() async {
    if (!_isReady || _recognizer == null || _isBusy) return;
    _isBusy = true;

    try {
      if (!await _ensureMicPermission()) {
        _isBusy = false;
        return;
      }

      // Safely free previous stream and create fresh one
      _freeStream();
      _stream = _recognizer!.createStream();

      final audioStream = await _audioRecorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
          echoCancel: true,
          autoGain: true,
          noiseSuppress: true,
        ),
      );

      if (!mounted) {
        _isBusy = false;
        return;
      }

      setState(() {
        _isListening = true;
        _displayText = '';
        _lastFinalText = '';
        _statusMessage = 'Listening...';
      });

      _pulseController.repeat(reverse: true);

      // Audio ingestion — only feeds waveform, NO decoding here
      _micSubscription = audioStream.listen(
        _ingestAudioChunk,
        onError: (e) => debugPrint('🎤 Stream error: $e'),
        cancelOnError: false,
      );

      // Decoupled decode loop — runs every 60ms on main thread but
      // only calls lightweight decode steps (no audio conversion)
      _startDecodeLoop();
    } catch (e) {
      debugPrint('❌ Start error: $e');
      if (mounted) {
        setState(
          () => _statusMessage = 'Mic error: ${e.toString().split('\n').first}',
        );
      }
    } finally {
      _isBusy = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. STOP LISTENING
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _stopListening() async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      // 1. Stop decode loop first
      _stopDecodeLoop();

      // 2. Cancel mic subscription
      await _micSubscription?.cancel();
      _micSubscription = null;

      // 3. Stop the recorder safely
      try {
        await _audioRecorder.stop();
      } catch (_) {
        // Recorder may not be active — safe to ignore
      }

      _pulseController.stop();
      _pulseController.reset();

      // 4. Do one final decode pass to flush remaining audio
      _flushFinalDecode();

      if (!mounted) return;
      setState(() {
        _isListening = false;
        _volumeLevel = 0.0;
        _statusMessage = 'Tap to speak';
      });
    } finally {
      _isBusy = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 5. AUDIO INGESTION (runs on each mic chunk — lightweight, no decode)
  // ══════════════════════════════════════════════════════════════════════════
  void _ingestAudioChunk(Uint8List chunk) {
    if (_stream == null || chunk.isEmpty) return;

    // ╔══════════════════════════════════════════════════════════════════╗
    // ║  The record plugin returns Uint8List chunks that may be VIEWS   ║
    // ║  into a larger ByteBuffer with an ODD offsetInBytes.            ║
    // ║  Int16List requires 2-byte alignment, so we MUST copy into a   ║
    // ║  fresh buffer to guarantee alignment before converting.         ║
    // ╚══════════════════════════════════════════════════════════════════╝

    // Ensure even byte count (Int16 = 2 bytes per sample)
    final usableBytes = chunk.length - (chunk.length % 2);
    if (usableBytes < 2) return;

    // Copy into a new aligned buffer (cheap for small audio chunks)
    final aligned = Uint8List(usableBytes);
    aligned.setRange(0, usableBytes, chunk);
    final int16Data = aligned.buffer.asInt16List();

    final samples = Float32List(int16Data.length);
    double maxAmp = 0.0;

    for (int i = 0; i < int16Data.length; i++) {
      final s = int16Data[i] / 32768.0;
      samples[i] = s;
      final abs = s.abs();
      if (abs > maxAmp) maxAmp = abs;
    }

    // Feed audio to Sherpa (C++ side buffers internally)
    _stream!.acceptWaveform(samples: samples, sampleRate: 16000);

    // Throttled volume update for visualizer
    if (mounted && (maxAmp - _volumeLevel).abs() > 0.04) {
      setState(() => _volumeLevel = maxAmp);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 6. DECODE LOOP (decoupled timer — handles recognition + endpoint)
  // ══════════════════════════════════════════════════════════════════════════
  void _startDecodeLoop() {
    _decodeTimer?.cancel();
    // 80ms ≈ 12.5 decode cycles/sec — good balance of latency vs CPU
    _decodeTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _decodeStep();
    });
  }

  void _stopDecodeLoop() {
    _decodeTimer?.cancel();
    _decodeTimer = null;
  }

  void _decodeStep() {
    if (_recognizer == null || _stream == null) return;

    // Limit decode iterations per cycle to keep UI responsive.
    // Each decode() processes one frame (~10ms of audio).
    // At 80ms timer interval, 8 frames keeps us real-time without stalls.
    int maxDecodes = 8;
    while (maxDecodes > 0 && _recognizer!.isReady(_stream!)) {
      _recognizer!.decode(_stream!);
      maxDecodes--;
    }

    // Check for endpoint (finalized segment)
    final isEndpoint = _recognizer!.isEndpoint(_stream!);
    final result = _recognizer!.getResult(_stream!);
    final partialText = result.text.trim();

    if (isEndpoint && partialText.isNotEmpty) {
      // Segment finalized — append to accumulated text and reset stream
      _lastFinalText += '$partialText\n';
      _recognizer!.reset(_stream!);

      if (mounted) {
        setState(() {
          _displayText = _lastFinalText.trimRight();
        });
      }
      debugPrint('✅ Finalized: $partialText');
    } else if (isEndpoint && partialText.isEmpty) {
      // Empty endpoint (silence) — just reset
      _recognizer!.reset(_stream!);
    } else if (partialText.isNotEmpty) {
      // Partial/live result — show accumulated + current partial
      final liveText = (_lastFinalText + partialText).trimRight();
      if (liveText != _displayText && mounted) {
        setState(() => _displayText = liveText);
      }
    }
  }

  /// Final flush when user stops recording — decode any remaining buffered audio
  void _flushFinalDecode() {
    if (_recognizer == null || _stream == null) return;

    // Signal end of audio
    _stream!.inputFinished();

    // Decode any remaining frames
    while (_recognizer!.isReady(_stream!)) {
      _recognizer!.decode(_stream!);
    }

    final result = _recognizer!.getResult(_stream!);
    final remaining = result.text.trim();

    if (remaining.isNotEmpty) {
      _lastFinalText += remaining;
      if (mounted) {
        setState(() => _displayText = _lastFinalText.trimRight());
      }
      debugPrint('✅ Final flush: $remaining');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 7. CLEANUP
  // ══════════════════════════════════════════════════════════════════════════
  void _freeStream() {
    try {
      _stream?.free();
    } catch (_) {}
    _stream = null;
  }

  @override
  void dispose() {
    // Strict order: timer → subscription → recorder → stream → recognizer
    _decodeTimer?.cancel();
    _micSubscription?.cancel();
    _audioRecorder.dispose();
    _freeStream();
    try {
      _recognizer?.free();
    } catch (_) {}
    _pulseController.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 8. BUILD UI
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LiteRT Voice',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              // ─── Status Pill ───
              _buildStatusPill(primaryColor),

              SizedBox(height: 30.h),

              // ─── Transcript Box ───
              _buildTranscriptBox(isDark),

              SizedBox(height: 40.h),

              // ─── Mic Button ───
              _buildMicButton(primaryColor),

              SizedBox(height: 12.h),

              Text(
                'Offline Model: Zipformer Transducer',
                style: TextStyle(color: Colors.grey, fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusPill(Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color:
            _isListening
                ? primaryColor.withAlpha(25) // ~0.1 opacity
                : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _isListening ? primaryColor : Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isListening ? Icons.graphic_eq : Icons.mic_off_outlined,
            size: 18.sp,
            color: _isListening ? primaryColor : Colors.grey,
          ),
          SizedBox(width: 8.w),
          Text(
            _statusMessage,
            style: TextStyle(
              fontSize: 14.sp,
              color: _isListening ? primaryColor : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptBox(bool isDark) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10), // ~0.04 opacity
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          reverse: true,
          child: SelectableText(
            _displayText.isEmpty
                ? (_isListening ? 'Say something...' : 'Tap mic to start')
                : _displayText,
            style: TextStyle(
              fontSize: 22.sp,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color:
                  _displayText.isEmpty
                      ? Colors.grey[400]
                      : (isDark ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMicButton(Color primaryColor) {
    final buttonColor =
        !_isReady
            ? Colors.grey
            : (_isListening ? Colors.redAccent : primaryColor);

    return GestureDetector(
      onTap:
          _isReady && !_isBusy
              ? (_isListening ? _stopListening : _startListening)
              : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulseScale =
              _isListening ? 1.0 + (_pulseController.value * 0.08) : 1.0;
          final glowRadius = _isListening ? 10.0 + (_volumeLevel * 30.0) : 10.0;
          final spreadRadius = _isListening ? 5.0 + (_volumeLevel * 15.0) : 0.0;

          return Transform.scale(
            scale: pulseScale,
            child: Container(
              height: 80.w,
              width: 80.w,
              decoration: BoxDecoration(
                color: buttonColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withAlpha(77), // ~0.3 opacity
                    blurRadius: glowRadius,
                    spreadRadius: spreadRadius,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 36.sp,
              ),
            ),
          );
        },
      ),
    );
  }
}
