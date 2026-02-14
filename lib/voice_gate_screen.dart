import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

class VoiceIdentificationScreen extends StatefulWidget {
  const VoiceIdentificationScreen({super.key});

  @override
  State<VoiceIdentificationScreen> createState() =>
      _VoiceIdentificationScreenState();
}

class _VoiceIdentificationScreenState
    extends State<VoiceIdentificationScreen> {
  sherpa.SpeakerEmbeddingExtractor? _extractor;
  final AudioRecorder _recorder = AudioRecorder();

  final Map<String, Float32List> _enrolledUsers = {};

  String _status = "Initializing...";
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  Future<void> _initModel() async {
    try {
      sherpa.initBindings();

      final dir = await getApplicationDocumentsDirectory();
      final modelFile = File("${dir.path}/speaker.onnx");

      if (!await modelFile.exists()) {
        final data =
        await rootBundle.load("assets/models/sherpa/speaker.onnx");
        await modelFile.writeAsBytes(
          data.buffer.asUint8List(),
          flush: true,
        );
      }

      final config = sherpa.SpeakerEmbeddingExtractorConfig(
        model: modelFile.path,
        numThreads: 2,
        debug: false,
      );

      _extractor =
          sherpa.SpeakerEmbeddingExtractor(config: config);

      setState(() => _status = "Ready");
    } catch (e) {
      setState(() => _status = "Model error: $e");
    }
  }

  Future<Float32List?> _recordAudio(int seconds) async {
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) return null;

    final chunks = <Uint8List>[];

    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );

    final sub = stream.listen((data) => chunks.add(data));

    await Future.delayed(Duration(seconds: seconds));

    await sub.cancel();
    await _recorder.stop();

    final bytes = chunks.expand((e) => e).toList();
    if (bytes.isEmpty) return null;

    final aligned = Uint8List.fromList(bytes);
    final int16 = aligned.buffer.asInt16List();

    final floatSamples = Float32List(int16.length);

    for (int i = 0; i < int16.length; i++) {
      floatSamples[i] = int16[i] / 32768.0;
    }

    return floatSamples;
  }

  Future<void> _enrollUser(String name) async {
    if (_extractor == null || _isBusy) return;

    _isBusy = true;
    setState(() => _status = "Enrolling $name... Speak");

    final samples = await _recordAudio(4);
    if (samples == null) {
      _isBusy = false;
      return;
    }

    final stream = _extractor!.createStream();

    stream.acceptWaveform(
      samples: samples,
      sampleRate: 16000,
    );

    stream.inputFinished();

    final embedding = _extractor!.compute(stream);
    stream.free();

    _normalize(embedding);

    _enrolledUsers[name] = embedding;

    setState(() => _status = "$name enrolled ✅");

    _isBusy = false;
  }

  Future<void> _identifySpeaker() async {
    if (_extractor == null || _enrolledUsers.isEmpty || _isBusy) {
      setState(() => _status = "No users enrolled");
      return;
    }

    _isBusy = true;
    setState(() => _status = "Listening...");

    final samples = await _recordAudio(3);
    if (samples == null) {
      _isBusy = false;
      return;
    }

    final stream = _extractor!.createStream();

    stream.acceptWaveform(
      samples: samples,
      sampleRate: 16000,
    );

    stream.inputFinished();

    final newEmbedding = _extractor!.compute(stream);
    stream.free();

    _normalize(newEmbedding);

    double bestScore = 0.0;
    String? bestUser;

    for (final entry in _enrolledUsers.entries) {
      final score =
      _cosineSimilarity(newEmbedding, entry.value);

      if (score > bestScore) {
        bestScore = score;
        bestUser = entry.key;
      }
    }

    if (bestScore > 0.75 && bestUser != null) {
      final identifiedUser = bestUser;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => WelcomeScreen(name: identifiedUser!),
        ),
      );}
    else {
      setState(() => _status =
      "Unknown speaker ❌ (${bestScore.toStringAsFixed(2)})");
    }

    _isBusy = false;
  }

  void _normalize(Float32List v) {
    double norm = 0;
    for (final x in v) {
      norm += x * x;
    }
    norm = sqrt(norm);

    for (int i = 0; i < v.length; i++) {
      v[i] = v[i] / norm;
    }
  }

  double _cosineSimilarity(
      Float32List a, Float32List b) {
    double dot = 0;
    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  @override
  void dispose() {
    _recorder.dispose();
    _extractor?.free();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Voice Identification")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(_status, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Enter name to enroll",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  _enrollUser(name);
                }
              },
              child: const Text("Enroll User"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _identifySpeaker,
              child: const Text("Identify Speaker"),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final String name;

  const WelcomeScreen({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Center(
        child: Text(
          "Welcome $name 🎤",
          style: const TextStyle(fontSize: 26),
        ),
      ),
    );
  }
}
