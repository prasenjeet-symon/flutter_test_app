import 'package:flutter/material.dart';
import 'package:flutter_test_app/dashboard/dashbaord.dart';
import 'package:flutter_test_app/dashboard/edit-profile.dart';
import 'package:flutter_test_app/dashboard/initial.dart';
import 'package:flutter_test_app/dashboard/profile.dart';
import 'package:flutter_test_app/organization/founder-search.dart';
import 'package:flutter_test_app/organization/org-details.dart';
import 'package:flutter_test_app/organization/org-founder-choice.dart';
import 'package:flutter_test_app/organization/reserve-founder.dart';
import 'package:flutter_test_app/organization/select-parent-org.dart';
import 'package:flutter_test_app/organization/success-screen-org-created.dart';
import 'package:flutter_test_app/organization/welcome-onboarding.dart';
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
          getPages: [GetPage(name: '/', page: () => const WelcomeScreen()), GetPage(name: '/loading', page: () => const LoadingScreen()), GetPage(name: '/login', page: () => const LoginScreen())],
          home: SuccessScreen(),
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
