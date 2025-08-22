import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrgFounderChoiceScreen extends StatelessWidget {
  const OrgFounderChoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface, size: 24.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Select Founder Status', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, fontSize: 20.sp)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Is the Organization Founder on Our Platform?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 28.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'Let us know if the founder is already registered or needs to reserve a founder position.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16.sp, height: 1.5),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              // Founder Already on Platform Button
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/existing_founder');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.person_rounded, size: 32.sp, color: Theme.of(context).colorScheme.onPrimary),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Founder is on Platform', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
                            SizedBox(height: 4.h),
                            Text('Select this if the founder is already registered.', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Reserve Founder Position Button
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/reserve_founder');
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Theme.of(context).colorScheme.secondary, Theme.of(context).colorScheme.secondary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.bookmark_add_rounded, size: 32.sp, color: Theme.of(context).colorScheme.onSecondary),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reserve Founder Position', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSecondary)),
                            SizedBox(height: 4.h),
                            Text('Select this to reserve a founder position for someone new.', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.9))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
