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

// ╔══════════════════════════════════════════════════════════════════════════╗
// ║                    JAPA RECOGNITION — 3 APPROACHES                     ║
// ║                                                                        ║
// ║  APPROACH 1: Hotword Boosting (RECOMMENDED — used below)               ║
// ║    • Uses standard ASR model + boosts "hare" "krishna" "rama"          ║
// ║    • Sherpa raises log-probability of these tokens during beam search   ║
// ║    • Result: model strongly prefers mantra words over similar sounds    ║
// ║    • Needs: hotwords.txt file with boosted words                       ║
// ║                                                                        ║
// ║  APPROACH 2: Keyword Spotter (ALTERNATIVE — code included below)       ║
// ║    • Dedicated sherpa.KeywordSpotter API                               ║
// ║    • Detects only pre-defined keyword phrases                          ║
// ║    • Lowest CPU usage, but less flexible                               ║
// ║    • Needs: keywords.txt with phonetic definitions                     ║
// ║                                                                        ║
// ║  APPROACH 3: Post-Processing Filter (USED AS LAYER 2 below)           ║
// ║    • Accept all ASR output, then fuzzy-match against mantra words      ║
// ║    • Catches variations like "hari", "krsna", "ram"                    ║
// ║    • Works with ANY model, no retraining needed                        ║
// ║                                                                        ║
// ║  APPROACH 4: Fine-Tuned Model (BEST accuracy, most effort)            ║
// ║    • Train a custom Zipformer on mantra audio dataset                  ║
// ║    • See bottom of file for training instructions                      ║
// ╚══════════════════════════════════════════════════════════════════════════╝

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
          title: 'JapaRuchi',
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            primaryColor: const Color(0xFFFF9800), // Saffron
            scaffoldBackgroundColor: const Color(0xFF1A0E2E), // Deep purple
            cardColor: const Color(0xFF2A1B3D),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFFF9800),
              brightness: Brightness.dark,
            ),
          ),
          home: const JapaScreen(),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// MANTRA MATCHING ENGINE (Approach 3: Post-Processing Filter)
// ══════════════════════════════════════════════════════════════════════════════

class MantraTracker {
  // The Maha Mantra sequence (16 words = 1 mantra)
  static const List<String> mahaMantra = [
    'hare',
    'krishna',
    'hare',
    'krishna',
    'krishna',
    'krishna',
    'hare',
    'hare',
    'hare',
    'rama',
    'hare',
    'rama',
    'rama',
    'rama',
    'hare',
    'hare',
  ];

  // Fuzzy match variants (ASR often produces these)
  static const Map<String, String> _aliases = {
    // Krishna variants
    'krishna': 'krishna',
    'krsna': 'krishna',
    'krshna': 'krishna',
    'krishn': 'krishna',
    'krishnaa': 'krishna',
    'krishan': 'krishna',
    'kishan': 'krishna',
    'kisna': 'krishna',
    'krish': 'krishna',
    'christian': 'krishna', // Common ASR misrecognition
    'christina': 'krishna',
    // Hare variants
    'hare': 'hare',
    'hari': 'hare',
    'hary': 'hare',
    'harey': 'hare',
    'harry': 'hare',
    'hurry': 'hare',
    'are': 'hare', // Sometimes leading 'h' is missed
    // Rama variants
    'rama': 'rama',
    'ram': 'rama',
    'raam': 'rama',
    'ramma': 'rama',
    'rom': 'rama',
    'rome': 'rama', // Common ASR misrecognition
  };

  int _mantraWordIndex = 0; // Position in the 16-word sequence
  int _mantraCount = 0; // Full mantras completed
  int _roundCount = 0; // Rounds completed (108 mantras = 1 round)
  int _totalWordsMatched = 0;

  int get mantraCount => _mantraCount;
  int get roundCount => _roundCount;
  int get wordsInCurrentMantra => _mantraWordIndex;
  int get totalWordsMatched => _totalWordsMatched;
  int get mantrasInCurrentRound => _mantraCount % 108;
  double get roundProgress => (_mantraCount % 108) / 108.0;

  /// Feed raw ASR text, returns list of matched mantra words
  List<String> processText(String rawText) {
    final words =
        rawText
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z\s]'), '') // Strip punctuation
            .split(RegExp(r'\s+'))
            .where((w) => w.isNotEmpty)
            .toList();

    final matched = <String>[];

    for (final word in words) {
      final normalized = _aliases[word];
      if (normalized == null) continue; // Not a mantra word — skip

      // Check if this word matches the EXPECTED next word in the sequence
      final expected = mahaMantra[_mantraWordIndex];

      if (normalized == expected) {
        // Perfect sequence match
        matched.add(normalized);
        _totalWordsMatched++;
        _mantraWordIndex++;

        if (_mantraWordIndex >= 16) {
          _mantraWordIndex = 0;
          _mantraCount++;

          if (_mantraCount % 108 == 0) {
            _roundCount++;
          }
        }
      } else if (normalized == 'hare' ||
          normalized == 'krishna' ||
          normalized == 'rama') {
        // It's a valid mantra word but out of sequence.
        // Try to re-sync: find next occurrence in the mantra pattern.
        final resyncIndex = _findNextOccurrence(normalized, _mantraWordIndex);
        if (resyncIndex != null) {
          _mantraWordIndex = resyncIndex;
          matched.add(normalized);
          _totalWordsMatched++;
          _mantraWordIndex++;
          if (_mantraWordIndex >= 16) {
            _mantraWordIndex = 0;
            _mantraCount++;
            if (_mantraCount % 108 == 0) _roundCount++;
          }
        }
      }
    }

    return matched;
  }

  /// Find the next position where [word] appears in mahaMantra from [startIndex]
  int? _findNextOccurrence(String word, int startIndex) {
    // Look forward up to 4 positions (allow small skips)
    for (int offset = 0; offset < 4; offset++) {
      final idx = (startIndex + offset) % 16;
      if (mahaMantra[idx] == word) return idx;
    }
    return null;
  }

  void reset() {
    _mantraWordIndex = 0;
    _mantraCount = 0;
    _roundCount = 0;
    _totalWordsMatched = 0;
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// JAPA SCREEN
// ══════════════════════════════════════════════════════════════════════════════

class JapaScreen extends StatefulWidget {
  const JapaScreen({super.key});

  @override
  State<JapaScreen> createState() => _JapaScreenState();
}

class _JapaScreenState extends State<JapaScreen>
    with SingleTickerProviderStateMixin {
  // ─── AI Objects ───
  sherpa.OnlineRecognizer? _recognizer;
  sherpa.OnlineStream? _stream;

  // ─── Audio Objects ───
  final AudioRecorder _audioRecorder = AudioRecorder();
  StreamSubscription<Uint8List>? _micSubscription;
  Timer? _decodeTimer;

  // ─── Mantra Tracker ───
  final MantraTracker _tracker = MantraTracker();

  // ─── State ───
  String _rawText = '';
  String _lastProcessedText = '';
  String _statusMessage = 'Initializing...';
  bool _isReady = false;
  bool _isListening = false;
  bool _isBusy = false;
  double _volumeLevel = 0.0;
  bool _hasMicPermission = false;
  String _lastFinalText = '';
  List<String> _recentMatchedWords = [];

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
  // 1. INIT SHERPA WITH HOTWORD BOOSTING
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _initSherpa() async {
    try {
      sherpa.initBindings();
      final assetsDir = await getApplicationDocumentsDirectory();

      Future<String> copyAsset(String filename) async {
        final file = File('${assetsDir.path}/$filename');
        if (!await file.exists()) {
          debugPrint('📂 Copying: $filename');
          final data = await rootBundle.load('assets/models/sherpa/$filename');
          await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
        }
        return file.path;
      }

      final encoderPath = await copyAsset('encoder.onnx');
      final decoderPath = await copyAsset('decoder.onnx');
      final joinerPath = await copyAsset('joiner.onnx');
      final tokensPath = await copyAsset('tokens.txt');

      // ┌─────────────────────────────────────────────────────────────────┐
      // │  HOTWORDS FILE — boosts mantra words during beam search        │
      // │  Format: one word/phrase per line, with optional boost score   │
      // │  Higher score = stronger preference for that word              │
      // └─────────────────────────────────────────────────────────────────┘
      final hotwordsFile = File('${assetsDir.path}/hotwords.txt');
      if (!await hotwordsFile.exists()) {
        await hotwordsFile.writeAsString(
          // Each line: <word/phrase> :  <boost_score>
          // Boost score range: 1.0 (mild) to 10.0 (very strong)
          'hare :5.0\n'
          'krishna :5.0\n'
          'rama :5.0\n'
          'hare krishna :8.0\n'
          'hare rama :8.0\n'
          'krishna krishna :6.0\n'
          'rama rama :6.0\n'
          'hare hare :6.0\n',
        );
      }

      final config = sherpa.OnlineRecognizerConfig(
        model: sherpa.OnlineModelConfig(
          transducer: sherpa.OnlineTransducerModelConfig(
            encoder: encoderPath,
            decoder: decoderPath,
            joiner: joinerPath,
          ),
          tokens: tokensPath,
          numThreads: 2,
          modelType: 'zipformer',
          debug: false,
        ),
        feat: const sherpa.FeatureConfig(sampleRate: 16000),
        enableEndpoint: true,
        rule1MinTrailingSilence: 2.0,
        rule2MinTrailingSilence: 0.6,
        rule3MinUtteranceLength: 30.0,
        // ── Hotword Boosting (REQUIRES modified_beam_search) ──
        decodingMethod: 'modified_beam_search',
        maxActivePaths: 4, // Beam width — 4 is good balance of speed/accuracy
        hotwordsFile: hotwordsFile.path,
        hotwordsScore: 5.0, // Global boost multiplier
      );

      _recognizer = sherpa.OnlineRecognizer(config);
      _stream = _recognizer!.createStream();

      if (!mounted) return;
      setState(() {
        _isReady = true;
        _statusMessage = 'Ready — Tap to begin japa';
      });
      debugPrint('✅ Sherpa ready with hotword boosting');
    } catch (e, stack) {
      debugPrint('❌ Init error: $e\n$stack');
      if (!mounted) return;
      setState(
        () => _statusMessage = 'Error: ${e.toString().split('\n').first}',
      );
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. PERMISSION
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
  // 3. START / STOP
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _startListening() async {
    if (!_isReady || _recognizer == null || _isBusy) return;
    _isBusy = true;

    try {
      if (!await _ensureMicPermission()) {
        _isBusy = false;
        return;
      }

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
        _rawText = '';
        _lastFinalText = '';
        _lastProcessedText = '';
        _statusMessage = 'Chanting...';
      });

      _pulseController.repeat(reverse: true);

      _micSubscription = audioStream.listen(
        _ingestAudioChunk,
        onError: (e) => debugPrint('🎤 Error: $e'),
        cancelOnError: false,
      );

      _startDecodeLoop();
    } catch (e) {
      debugPrint('❌ Start error: $e');
      if (mounted) setState(() => _statusMessage = 'Mic error');
    } finally {
      _isBusy = false;
    }
  }

  Future<void> _stopListening() async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      _stopDecodeLoop();
      await _micSubscription?.cancel();
      _micSubscription = null;
      try {
        await _audioRecorder.stop();
      } catch (_) {}

      _pulseController.stop();
      _pulseController.reset();

      _flushFinalDecode();

      if (!mounted) return;
      setState(() {
        _isListening = false;
        _volumeLevel = 0.0;
        _statusMessage = 'Session paused — Tap to resume';
      });
    } finally {
      _isBusy = false;
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 4. AUDIO INGESTION
  // ══════════════════════════════════════════════════════════════════════════
  void _ingestAudioChunk(Uint8List chunk) {
    if (_stream == null || chunk.isEmpty) return;

    final usableBytes = chunk.length - (chunk.length % 2);
    if (usableBytes < 2) return;

    // Copy to aligned buffer
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

    _stream!.acceptWaveform(samples: samples, sampleRate: 16000);

    if (mounted && (maxAmp - _volumeLevel).abs() > 0.04) {
      setState(() => _volumeLevel = maxAmp);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 5. DECODE LOOP + MANTRA MATCHING
  // ══════════════════════════════════════════════════════════════════════════
  void _startDecodeLoop() {
    _decodeTimer?.cancel();
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

    int maxDecodes = 8;
    while (maxDecodes > 0 && _recognizer!.isReady(_stream!)) {
      _recognizer!.decode(_stream!);
      maxDecodes--;
    }

    final isEndpoint = _recognizer!.isEndpoint(_stream!);
    final result = _recognizer!.getResult(_stream!);
    final partialText = result.text.trim();

    if (isEndpoint && partialText.isNotEmpty) {
      _lastFinalText += '$partialText ';
      _recognizer!.reset(_stream!);

      // Feed finalized text to mantra tracker
      _processMantraText(partialText);

      if (mounted) {
        setState(() => _rawText = _lastFinalText.trimRight());
      }
      debugPrint('✅ Finalized: $partialText');
    } else if (isEndpoint) {
      _recognizer!.reset(_stream!);
    } else if (partialText.isNotEmpty) {
      // Show partial + run partial matching
      final liveText = (_lastFinalText + partialText).trimRight();
      if (liveText != _rawText && mounted) {
        setState(() => _rawText = liveText);
      }

      // Process partial text for live counter updates
      final newText = partialText;
      if (newText != _lastProcessedText) {
        _processMantraText(newText);
        _lastProcessedText = newText;
      }
    }
  }

  void _processMantraText(String text) {
    final matched = _tracker.processText(text);
    if (matched.isNotEmpty && mounted) {
      setState(() {
        _recentMatchedWords = matched;
      });
      debugPrint(
        '🙏 Matched: $matched | Mantras: ${_tracker.mantraCount} | Round: ${_tracker.roundCount}',
      );
    }
  }

  void _flushFinalDecode() {
    if (_recognizer == null || _stream == null) return;
    _stream!.inputFinished();

    while (_recognizer!.isReady(_stream!)) {
      _recognizer!.decode(_stream!);
    }

    final result = _recognizer!.getResult(_stream!);
    final remaining = result.text.trim();

    if (remaining.isNotEmpty) {
      _lastFinalText += remaining;
      _processMantraText(remaining);
      if (mounted) setState(() => _rawText = _lastFinalText.trimRight());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 6. CLEANUP
  // ══════════════════════════════════════════════════════════════════════════
  void _freeStream() {
    try {
      _stream?.free();
    } catch (_) {}
    _stream = null;
  }

  void _resetSession() {
    _tracker.reset();
    setState(() {
      _rawText = '';
      _lastFinalText = '';
      _lastProcessedText = '';
      _recentMatchedWords = [];
    });
  }

  @override
  void dispose() {
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
  // 7. BUILD UI
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    const saffron = Color(0xFFFF9800);
    const gold = Color(0xFFFFD54F);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🙏 JapaRuchi',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetSession,
            tooltip: 'Reset Counter',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            children: [
              // ─── Round & Mantra Counters ───
              _buildCounterCards(saffron, gold),

              SizedBox(height: 16.h),

              // ─── Round Progress Bar ───
              _buildRoundProgress(saffron),

              SizedBox(height: 16.h),

              // ─── Status Pill ───
              _buildStatusPill(saffron),

              SizedBox(height: 16.h),

              // ─── Live Transcript (debug view) ───
              _buildTranscriptBox(),

              SizedBox(height: 24.h),

              // ─── Mic Button ───
              _buildMicButton(saffron),

              SizedBox(height: 10.h),

              Text(
                'Offline • Zipformer + Hotword Boost',
                style: TextStyle(color: Colors.grey[600], fontSize: 11.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCards(Color saffron, Color gold) {
    return Row(
      children: [
        Expanded(
          child: _counterCard(
            icon: '📿',
            label: 'ROUNDS',
            value: '${_tracker.roundCount}',
            highlight: _tracker.roundCount > 0,
            color: gold,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _counterCard(
            icon: '🕉️',
            label: 'MANTRAS',
            value: '${_tracker.mantrasInCurrentRound}',
            subtitle: 'of 108',
            highlight: _isListening,
            color: saffron,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: _counterCard(
            icon: '🔤',
            label: 'WORDS',
            value: '${_tracker.totalWordsMatched}',
            highlight: false,
            color: Colors.tealAccent,
          ),
        ),
      ],
    );
  }

  Widget _counterCard({
    required String icon,
    required String label,
    required String value,
    String? subtitle,
    required bool highlight,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border:
            highlight
                ? Border.all(color: color.withAlpha(100), width: 1.5)
                : null,
      ),
      child: Column(
        children: [
          Text(icon, style: TextStyle(fontSize: 20.sp)),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[400],
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundProgress(Color saffron) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Round ${_tracker.roundCount + 1} Progress',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${_tracker.mantrasInCurrentRound} / 108',
              style: TextStyle(
                fontSize: 12.sp,
                color: saffron,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: _tracker.roundProgress,
            minHeight: 8.h,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(saffron),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(Color saffron) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 14.w),
      decoration: BoxDecoration(
        color:
            _isListening ? saffron.withAlpha(25) : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _isListening ? saffron : Theme.of(context).dividerColor,
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isListening ? Icons.graphic_eq : Icons.mic_off_outlined,
              size: 16.sp,
              color: _isListening ? saffron : Colors.grey,
            ),
            SizedBox(width: 6.w),
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 13.sp,
                color: _isListening ? saffron : Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_recentMatchedWords.isNotEmpty && _isListening) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: saffron.withAlpha(40),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  _recentMatchedWords.last,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: saffron,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTranscriptBox() {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Recognition',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: SelectableText(
                  _rawText.isEmpty
                      ? (_isListening
                          ? 'Hare Krishna...'
                          : 'Tap to begin chanting')
                      : _rawText,
                  style: TextStyle(
                    fontSize: 18.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                    color: _rawText.isEmpty ? Colors.grey[600] : Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton(Color saffron) {
    final buttonColor =
        !_isReady ? Colors.grey : (_isListening ? Colors.redAccent : saffron);

    return GestureDetector(
      onTap:
          _isReady && !_isBusy
              ? (_isListening ? _stopListening : _startListening)
              : null,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale =
              _isListening ? 1.0 + (_pulseController.value * 0.08) : 1.0;
          final glow = _isListening ? 10.0 + (_volumeLevel * 30.0) : 10.0;
          final spread = _isListening ? 5.0 + (_volumeLevel * 15.0) : 0.0;

          return Transform.scale(
            scale: scale,
            child: Container(
              height: 76.w,
              width: 76.w,
              decoration: BoxDecoration(
                color: buttonColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: buttonColor.withAlpha(77),
                    blurRadius: glow,
                    spreadRadius: spread,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 34.sp,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// FINE-TUNING GUIDE (Approach 4 — Maximum Accuracy)
// ══════════════════════════════════════════════════════════════════════════════
//
// For the best possible mantra recognition accuracy, fine-tune a custom model:
//
// STEP 1: Collect Training Data
//   - Record 50+ devotees chanting the maha mantra (diverse voices)
//   - Record at different speeds (slow japa, fast kirtan)
//   - Record in different environments (temple, home, outdoor)
//   - Minimum 10 hours of labeled audio
//   - Format: 16kHz mono WAV files
//
// STEP 2: Prepare Labels
//   - Transcribe each audio file with exact mantra words
//   - Use a simplified vocabulary: {"hare", "krishna", "rama", " ", ""}
//   - Create train/dev/test splits (80/10/10)
//
// STEP 3: Train with Icefall (Sherpa's training framework)
//   ```bash
//   git clone https://github.com/k2-fsa/icefall
//   cd icefall
//
//   # Use the pre-trained zipformer as starting point (transfer learning)
//   # Modify: egs/librispeech/ASR/zipformer/train.py
//   # - Set vocab to just mantra tokens
//   # - Reduce model size (encoder_dim=192, num_encoder_layers=3)
//   # - Set epochs=50, lr=0.001 for fine-tuning
//
//   python zipformer/train.py \
//     --exp-dir ./mantra-model \
//     --num-epochs 50 \
//     --start-epoch 1 \
//     --use-fp16 1 \
//     --base-lr 0.001 \
//     --manifest-dir ./data/mantra
//   ```
//
// STEP 4: Export to Sherpa ONNX
//   ```bash
//   python zipformer/export-onnx.py \
//     --tokens ./data/mantra/tokens.txt \
//     --exp-dir ./mantra-model \
//     --epoch 50 \
//     --avg 10 \
//     --onnx-opset-version 13
//   ```
//
// STEP 5: Optimize for Mobile
//   - Quantize model: onnxruntime quantize_dynamic encoder.onnx encoder_int8.onnx
//   - Target size: < 5MB for mobile deployment
//   - Test on actual device with background noise
//
// ALTERNATIVE: Use Sherpa's Keyword Spotter API
//   - Even simpler for pure detection (not transcription)
//   - Create keywords.txt with phonetic spellings:
//     ```
//     hare krishna @hare_krishna
//     hare rama @hare_rama
//     ```
//   - Use sherpa.KeywordSpotter instead of OnlineRecognizer
//   - Lowest CPU usage, best for background counting
// ══════════════════════════════════════════════════════════════════════════════
