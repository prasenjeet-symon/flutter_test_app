import 'package:flutter/material.dart';
import 'package:flutter_test_app/dashboard/dashbaord.dart';
import 'package:flutter_test_app/dashboard/initial.dart';
import 'package:flutter_test_app/dashboard/profile.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          initialRoute: '/',
          getPages: [GetPage(name: '/', page: () => const DashboardScreen()), GetPage(name: '/loading', page: () => const LoadingScreen()), GetPage(name: '/login', page: () => const LoginScreen())],
          home: DashboardScreen(),
        );
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Login')), body: const Center(child: Text('Login Screen')));
  }
}
