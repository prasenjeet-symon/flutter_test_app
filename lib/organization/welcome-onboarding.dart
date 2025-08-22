import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(margin: EdgeInsets.only(bottom: 32.h), child: Image.asset('assets/welcome-org-creator.png', height: 300.h, width: 300.w, fit: BoxFit.contain)),
            Text('Build Your Organization!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 28.sp), textAlign: TextAlign.center),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                'Start your journey as a leader. Create your organization, invite your team, and bring your vision to life with our powerful tools.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16.sp, height: 1.5),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 5,
                shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
              child: Text('Create Now', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            ),
            SizedBox(height: 8.h),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
