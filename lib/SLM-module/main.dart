import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test_app/SLM-module/llm_view.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil for responsive sizing (360x690 is standard mobile base)
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'SmolLM2 Mobile',
          theme: ThemeData(
            useMaterial3: true,
            primarySwatch: Colors.indigo,
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          ),
          home: LlmChatView(),
        );
      },
    );
  }
}
