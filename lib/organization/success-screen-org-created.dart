import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Illustration/Animation
              SizedBox(
                width: 200.w,
                height: 200.h,
                // Replace with an actual success animation or image
                child: Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 150.sp),
              ),
              SizedBox(height: 32.h),

              // Success Title
              Text('Organization Created Successfully!', style: GoogleFonts.lato(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
              SizedBox(height: 12.h),

              // Description
              Text('Your new organization is ready to go. You can configure it now or do it later.', style: GoogleFonts.lato(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
              SizedBox(height: 48.h),

              // CTA Buttons
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    // Action for configuring the organization
                    // Navigate to configuration screen
                    print('Navigating to Configure Organization screen');
                  },
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    textStyle: GoogleFonts.lato(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Configure Organization'),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Action to dismiss the screen
                    // Navigate to dashboard or home screen
                    print('Navigating to main dashboard');
                  },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.h),
                    side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.w),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    textStyle: GoogleFonts.lato(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
