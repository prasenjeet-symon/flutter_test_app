import 'package:flutter/material.dart';
import 'package:flutter_test_app/dashboard/dashbaord.dart';
import 'package:flutter_test_app/dashboard/edit-profile.dart';
import 'package:flutter_test_app/dashboard/initial.dart';
import 'package:flutter_test_app/dashboard/profile.dart';
import 'package:flutter_test_app/organization/configure/goal_category_management.dart';
import 'package:flutter_test_app/organization/configure/manage_mission_screen.dart';
import 'package:flutter_test_app/organization/configure/manage_purpose_screen.dart';
import 'package:flutter_test_app/organization/configure/org_goal_management.dart';
import 'package:flutter_test_app/organization/configure/org_mission_category_management.dart';
import 'package:flutter_test_app/organization/configure/org_mission_sub_category_management.dart';
import 'package:flutter_test_app/organization/configure/org_purpose_category_management.dart';
import 'package:flutter_test_app/organization/configure/org_purpose_sub_category_management.dart';
import 'package:flutter_test_app/organization/configure/organization_settings_screen.dart';
import 'package:flutter_test_app/organization/founder-search.dart';
import 'package:flutter_test_app/organization/leads/create-lead.dart';
import 'package:flutter_test_app/organization/leads/lead-list.dart';
import 'package:flutter_test_app/organization/leads/org-lead-group.dart';
import 'package:flutter_test_app/organization/org-details.dart';
import 'package:flutter_test_app/organization/org-founder-choice.dart';
import 'package:flutter_test_app/organization/org-profile.dart';
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
          darkTheme: ThemeData.dark(),
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const WelcomeScreen()),
            GetPage(name: '/loading', page: () => const LoadingScreen()),
            GetPage(name: '/login', page: () => const LoginScreen()),
          ],
          home: const OrganizationProfileScreen(),
        );
      },
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: const Center(child: Text('Login Screen')),
    );
  }
}
