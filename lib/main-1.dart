import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_test_app/tutorials/whatsapp-template.dart'; // Ensure this path is correct

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsiveness
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // We use the 'builder' to ensure ScreenUtil is initialized before the App starts
      builder: (context, child) {
        return GetMaterialApp(
          title: 'WhatsApp Template Tutorial',
          debugShowCheckedModeBanner: false,

          // 1. Tell Flutter to listen to system settings
          themeMode: ThemeMode.system,

          // 2. Define the Light Theme
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: Colors.white,
          ),

          // 3. Define the Dark Theme (This was missing!)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark, // Essential: Generates dark palette
            ),
            // Optional: Customize dark background if 'black' is too harsh
            scaffoldBackgroundColor: const Color(0xFF121212),
          ),

          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // OPTIONAL: Open tutorial on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openTutorial();
    });
  }

  void _openTutorial() {
    Get.to(
      () => const WhatsAppTemplateTutorialScreen(),
      fullscreenDialog: true,
      transition: Transition.downToUp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: Center(
        child: ElevatedButton(
          onPressed: _openTutorial,
          child: const Text("Open Tutorial"),
        ),
      ),
    );
  }
}
