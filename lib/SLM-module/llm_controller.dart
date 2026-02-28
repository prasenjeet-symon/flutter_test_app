import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

class LlmController extends GetxController {
  // --- State Variables ---
  var isModelLoaded = false.obs;
  var isDownloading = false.obs;
  var downloadProgress = 0.0.obs;
  var isGenerating = false.obs;
  var statusText = "Initializing...".obs;

  // Chat History
  var messages = <Map<String, String>>[].obs;

  // AI Engine Instance
  Llama? _llama;

  // --- Constants ---
  // Using Q8 (High Quality) because 135M is small enough to handle it.
  static const _modelUrl =
      "https://huggingface.co/QuantFactory/SmolLM2-135M-Instruct-GGUF/resolve/main/SmolLM2-135M-Instruct.Q8_0.gguf?download=true";
  static const _modelFileName = "smollm2_135m_instruct_q8.gguf";

  @override
  void onInit() {
    super.onInit();
    // Delay check slightly to allow UI to mount
    Future.delayed(const Duration(seconds: 1), () => _checkAndLoadModel());
  }

  /// 1. Check File Integrity
  Future<void> _checkAndLoadModel() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_modelFileName');

    print("--- [DEBUG] Checking file at: ${file.path} ---");

    if (await file.exists()) {
      int size = await file.length();
      print(
        "--- [DEBUG] Found file. Size: ${(size / 1024 / 1024).toStringAsFixed(2)} MB ---",
      );

      // If file is too small (< 50MB), it's corrupted. Delete it.
      if (size < 50 * 1024 * 1024) {
        print("--- [DEBUG] File corrupted. Deleting... ---");
        await file.delete();
      }
    }

    if (!await file.exists()) {
      await _downloadModel(file);
    } else {
      _initLlama(file.path);
    }
  }

  /// 2. Download with Chunked Writing (Safe for RAM)
  Future<void> _downloadModel(File file) async {
    isDownloading.value = true;
    statusText.value = "Starting Download...";
    print("--- [DEBUG] Starting Download Loop ---");

    final client = http.Client();
    IOSink? sink; // Declare sink outside try block to close it safely

    try {
      final request = http.Request('GET', Uri.parse(_modelUrl));
      final response = await client.send(request);

      if (response.statusCode != 200) {
        throw Exception("HTTP Error: ${response.statusCode}");
      }

      final contentLength = response.contentLength ?? 145000000;
      int received = 0;

      // 1. Open the file stream
      sink = file.openWrite();

      // 2. BLOCKING LOOP (The Fix)
      // We wait for every chunk. The app cannot skip ahead.
      await for (List<int> chunk in response.stream) {
        // Write to buffer
        sink.add(chunk);

        // Update Progress
        received += chunk.length;
        downloadProgress.value = received / contentLength;

        // Log every 20% (reduced logs)
        if (received % (contentLength ~/ 5) < chunk.length) {
          print(
            "--- [DEBUG] Progress: ${(downloadProgress.value * 100).toInt()}% ---",
          );
          statusText.value =
              "Downloading... ${(downloadProgress.value * 100).toInt()}%";
        }
      }

      // 3. Force Write to Disk (Critical Step)
      print("--- [DEBUG] Stream Finished. Flushing data to disk... ---");
      await sink.flush();
      print("--- [DEBUG] Data Flushed. Closing file... ---");
      await sink.close();
      sink = null; // Mark as closed

      print("--- [DEBUG] File Closed. Size: ${await file.length()} ---");

      // 4. Verification
      if (await file.length() < 1000) {
        throw Exception("Downloaded file is empty");
      }

      // 5. Success
      isDownloading.value = false;
      statusText.value = "Download Complete. Initializing...";
      _initLlama(file.path);
    } catch (e) {
      print("--- [DEBUG] ERROR: $e ---");
      isDownloading.value = false;
      statusText.value = "Download Error";
      // Close sink if it's still open
      if (sink != null) await sink.close();
      // Delete partial file
      if (await file.exists()) await file.delete();
    } finally {
      client.close();
    }
  }

  /// 3. Initialize AI Engine
  Future<void> _initLlama(String path) async {
    print("--- [DEBUG] Initializing Llama Engine... ---");
    statusText.value = "Loading Engine (This may freeze briefly)...";

    // Allow UI to update before heavy lifting
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      ContextParams contextParams = ContextParams();

      contextParams.nBatch = 512;
      contextParams.nThreads = 4;
      contextParams.nCtx = 2048;

      _llama = Llama(
        path,
        modelParams: ModelParams(),
        contextParams: contextParams,
      );

      print("--- [DEBUG] Engine Loaded Successfully ---");
      isModelLoaded.value = true;
      statusText.value = "Ready";
    } catch (e) {
      print("--- [DEBUG] Engine Init Failed: $e ---");
      statusText.value = "Init Failed";
      Get.snackbar("Critical Error", "Engine failed to load: $e");

      // If engine fails, file might be bad
      final file = File(path);
      if (await file.exists()) await file.delete();
    }
  }

  /// 4. Chat Logic
  void sendMessage(String text) async {
    if (text.trim().isEmpty || !isModelLoaded.value || _llama == null) return;

    // UI Updates
    messages.add({'role': 'user', 'text': text});
    messages.add({'role': 'bot', 'text': '...'}); // Placeholder
    isGenerating.value = true;

    int botIndex = messages.length - 1;
    String currentResponse = "";

    // Build ChatML Prompt
    String prompt = _buildChatMLPrompt();

    try {
      _llama!.setPrompt(prompt);

      await for (final token in _llama!.generateText()) {
        currentResponse += token;
        messages[botIndex] = {'role': 'bot', 'text': currentResponse};
        messages.refresh(); // Update GetX UI
      }
    } catch (e) {
      print("--- [DEBUG] Generation Error: $e ---");
      messages[botIndex] = {'role': 'bot', 'text': "[Error: $e]"};
    } finally {
      isGenerating.value = false;
    }
  }

  /// Helper: Format prompt for SmolLM2
  String _buildChatMLPrompt() {
    StringBuffer buffer = StringBuffer();
    buffer.write(
      "<|im_start|>system\nYou are a helpful assistant.<|im_end|>\n",
    );

    // Keep context small (last 6 messages)
    final history =
        messages.length > 6 ? messages.sublist(messages.length - 6) : messages;

    for (var msg in history) {
      if (msg['text'] == '...') continue;
      buffer.write(
        "<|im_start|>${msg['role'] == 'user' ? 'user' : 'assistant'}\n${msg['text']}<|im_end|>\n",
      );
    }

    buffer.write("<|im_start|>assistant\n");
    return buffer.toString();
  }

  @override
  void onClose() {
    _llama?.dispose();
    super.onClose();
  }
}
