import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test_app/manage-influncers/create-warning.dart';
import 'package:flutter_test_app/manage-influncers/goal.dart';
import 'package:flutter_test_app/manage-influncers/manage-influncer.dart';
import 'package:flutter_test_app/manage-influncers/mission.dart';
import 'package:flutter_test_app/manage-influncers/problem.dart';
import 'package:flutter_test_app/manage-influncers/profile-fill.dart';
import 'package:flutter_test_app/manage-influncers/purpose-mission-goal-conformation.dart';
import 'package:flutter_test_app/manage-influncers/purpose.dart';
import 'package:flutter_test_app/manage-influncers/search-user.dart';
import 'package:flutter_test_app/manage-influncers/source-selection.dart';
import 'package:flutter_test_app/manage-influncers/success.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      // Get.toNamed(OrbitCreateConfigurePaths.manageTopicsScreen, arguments: {'targetUserTypeIdfr': 6, 'organizationId': 'spiderman', 'joiningIdentifier': '1d5756dc-ca10-11f0-8088-bad69bf8025f', 'orgQuestionGroupIdfr': '1', 'orgShortName': 'n', 'orgIdentifier': 'aa7f746b-bd1b-4417-a37e-a7faeef19301', 'orgIdfr': 65, 'groupName': 'Default', 'groupIdfr': 4, 'isDefault': true});
      // Get.toNamed(OrbitCreateConfigurePaths.organizationSettingsScreen, arguments: 'spiderman');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8207E0),
              secondary: Color.fromARGB(255, 27, 166, 217),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              surface: Color(0xFFF7F7F7),
              onSurface: Color(0xFF424242),
              onBackground: Color(0xFF1A202C),
              outline: Color(0xFF9E9E9E),
              error: Color(0xFFB00020),
              secondaryContainer: Color(0xFFE5F6FD),
              onSurfaceVariant: Color(0xFF8B8B8B),
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A202C),
              ),
              headlineMedium: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A202C),
              ),
              bodyLarge: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4A5568),
              ),
              bodyMedium: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF4A5568),
              ),
              labelMedium: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
              labelSmall: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                textStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: Color(0xFF1A202C)),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: const Color(0x1A000000),
              titleTextStyle: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A202C),
              ),
              iconTheme: const IconThemeData(color: Color(0xFF1A202C)),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 3,
              shadowColor: const Color(0x1A000000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8207E0),
              secondary: Color(0xFFB0BEC5),
              onPrimary: Colors.white,
              onSecondary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
              onBackground: Colors.white,
              outline: Color(0xFF374151),
              error: Color(0xFFCF6679),
              secondaryContainer: Color(0xFF2D3748),
              onSurfaceVariant: Color(0xFFD1D5DB),
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              headlineMedium: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              bodyLarge: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFD1D5DB),
              ),
              bodyMedium: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFD1D5DB),
              ),
              labelMedium: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF9CA3AF),
              ),
              labelSmall: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9CA3AF),
                textStyle: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1E1E1E),
              elevation: 2,
              shadowColor: const Color(0x1AFFFFFF),
              titleTextStyle: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),
              elevation: 3,
              shadowColor: const Color(0x1AFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ),
          themeMode: ThemeMode.system,
          home: const InfluencerSubmissionSuccessScreen(
            influencerName: ' Peter Pan',
            profileImagePath:
                'https://finlink.co.uk/wp-content/uploads/2023/11/LinkedIn-Logo-e1700490108143.png',
          ),
        );
      },
    );
  }
}
