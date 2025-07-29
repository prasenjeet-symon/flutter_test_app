import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test_app/dashboard/add-update-certification.dart';
import 'package:flutter_test_app/dashboard/add-update-core-values.dart';
import 'package:flutter_test_app/dashboard/add-update-education.dart';
import 'package:flutter_test_app/dashboard/add-update-experience.dart';
import 'package:flutter_test_app/dashboard/add-update-goals.dart';
import 'package:flutter_test_app/dashboard/add-update-mision.dart';
import 'package:flutter_test_app/dashboard/add-update-others.dart';
import 'package:flutter_test_app/dashboard/add-update-purpose.dart';
import 'package:flutter_test_app/dashboard/add-update-skills.dart';
import 'package:flutter_test_app/dashboard/add_social_media_links_screen.dart';
import 'package:flutter_test_app/dashboard/chat-groups.dart';
import 'package:flutter_test_app/dashboard/comments_screen.dart';
import 'package:flutter_test_app/dashboard/connection.dart';
import 'package:flutter_test_app/dashboard/create_post_screen.dart';
import 'package:flutter_test_app/dashboard/create_video_post_screen.dart';
import 'package:flutter_test_app/dashboard/edit-profile.dart';
import 'package:flutter_test_app/dashboard/followers.dart';
import 'package:flutter_test_app/dashboard/followings.dart';
import 'package:flutter_test_app/dashboard/organization-topics-selection.dart';
import 'package:flutter_test_app/dashboard/post_likers_screen.dart';
import 'package:flutter_test_app/dashboard/profile.dart';
import 'package:flutter_test_app/dashboard/selected_topics_order_screen.dart';
import 'package:flutter_test_app/dashboard/social_feed_page.dart';
import 'package:flutter_test_app/dashboard/suggested-user.dart';
import 'package:flutter_test_app/dashboard/text_feed_screen.dart';
import 'package:flutter_test_app/dashboard/tumblr_feed_screen.dart';
import 'package:flutter_test_app/dashboard/user_activity_timeline_screen.dart';
import 'package:flutter_test_app/dashboard/video_feed_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            // primaryColor is deprecated, use colorScheme.primary instead
            // primaryColor: const Color.fromARGB(255, 231, 17, 184),
            colorScheme: ColorScheme.light(
              primary: const Color.fromARGB(255, 229, 44, 186),
              secondary: const Color(0xFF1A4971),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1A202C),
              onBackground: const Color(0xFF1A202C),
              outline: const Color(0xFFE2E8F0),
              error: const Color(0xFFB00020),
              secondaryContainer: const Color(0xFFEDF2F7),
              // Added surfaceVariant and onSurfaceVariant for better theme consistency
              surfaceVariant: const Color(0xFFEDF2F7), // Light grey for surfaces like search input fill
              onSurfaceVariant: const Color(0xFF4A5568), // Darker text for surfaceVariant
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A202C)),
              headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A202C)),
              bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: const Color(0xFF4A5568)),
              bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: const Color(0xFF4A5568)),
              labelMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280)),
              labelSmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: const Color(0xFF6B7280)),
              // Ensure headlineSmall for AppBar title is also covered if needed
              headlineSmall: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A202C)),
              titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: const Color(0xFF1A202C)), // Used in PostLikersScreen
              labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF4A5568)), // Used in buttons
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFB00020))),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFB00020), width: 2)),
              labelStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
              helperStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                // Removed backgroundColor and foregroundColor here to allow button's own styleFrom to apply
                // backgroundColor: Colors.transparent, // This was causing issues
                // foregroundColor: Colors.white, // This was causing issues
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
            ),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280), textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600))),
            iconTheme: const IconThemeData(color: Color(0xFF1A202C)),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: const Color(0x1A000000),
              titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A202C)),
              iconTheme: const IconThemeData(color: Color(0xFF1A202C)),
            ),
            cardTheme: CardTheme(color: Colors.white, elevation: 3, shadowColor: const Color(0x1A000000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            // primaryColor is deprecated
            // primaryColor: const Color(0xFF2C7BE5),
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF2C7BE5),
              secondary: const Color(0xFF1A4971),
              onPrimary: Colors.white,
              surface: const Color(0xFF1E1E1E),
              onSurface: Colors.white,
              onBackground: Colors.white,
              outline: const Color(0xFF374151),
              error: const Color(0xFFCF6679),
              secondaryContainer: const Color(0xFF2D3748),
              // Added surfaceVariant and onSurfaceVariant for better theme consistency
              surfaceVariant: const Color(0xFF2D3748), // Darker grey for surfaces like search input fill
              onSurfaceVariant: const Color(0xFFD1D5DB), // Lighter text for surfaceVariant
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: Colors.white),
              headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
              bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: const Color(0xFFD1D5DB)),
              bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: const Color(0xFFD1D5DB)),
              labelMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
              labelSmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
              // Ensure headlineSmall for AppBar title is also covered if needed
              headlineSmall: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white),
              titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.white),
              labelLarge: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFFD1D5DB)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF374151))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFCF6679))),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFCF6679), width: 2)),
              labelStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)),
              helperStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                // Removed backgroundColor and foregroundColor here to allow button's own styleFrom to apply
                // backgroundColor: Colors.transparent, // This was causing issues
                // foregroundColor: Colors.white, // This was causing issues
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
            ),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFF9CA3AF), textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600))),
            iconTheme: const IconThemeData(color: Colors.white),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1E1E1E),
              elevation: 2,
              shadowColor: const Color(0x1AFFFFFF),
              titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            cardTheme: CardTheme(
              color: const Color(0xFF1E1E1E),
              elevation: 3,
              shadowColor: const Color(0x1AFFFFFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ),
          themeMode: ThemeMode.system,
          // home: PostLikersScreen(postId: '1'),
          home: SocialFeedPage(),
          //home: PersonalInformationScreen(),
        );
      },
    );
  }
}
