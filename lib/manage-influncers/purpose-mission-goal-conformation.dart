import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class StrategyOnboardingScreen extends StatelessWidget {
  const StrategyOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // --- Strictly using Scaffold Background Color ---
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            size: 24.sp,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(right: 24.w),
              child: Text(
                "Step 0/4",
                style: GoogleFonts.lato(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 12.h),
                    // --- Header Section ---
                    Text(
                      "Profile Strategy",
                      style: GoogleFonts.lato(
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        letterSpacing: -1.2,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Configure the strategic core of this influencer to ensure alignment with your brand goals.",
                      style: GoogleFonts.lato(
                        fontSize: 15.sp,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // --- Vertical Timeline Flow ---
                    _buildTimelineStep(
                      context,
                      title: "Purpose",
                      desc:
                          "Define the fundamental 'Why' and the unique impact of this profile.",
                      icon: Icons.wb_sunny_rounded,
                      tint: Colors.orange,
                      isFirst: true,
                    ),
                    _buildTimelineStep(
                      context,
                      title: "Mission",
                      desc:
                          "Outline the daily actions and roadmap to fulfill the purpose.",
                      icon: Icons.explore_rounded,
                      tint: Colors.blue,
                    ),
                    _buildTimelineStep(
                      context,
                      title: "Goals",
                      desc:
                          "Establish clear, measurable targets for long-term growth.",
                      icon: Icons.track_changes_rounded,
                      tint: const Color(0xFF10B981),
                    ),
                    _buildTimelineStep(
                      context,
                      title: "Problems",
                      desc:
                          "Identify the specific pain points this influencer aims to solve.",
                      icon: Icons.extension_rounded,
                      tint: Colors.purple,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),

            // --- Sticky Bottom Action Bar ---
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required String title,
    required String desc,
    required IconData icon,
    required Color tint,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Timeline Progress Column ---
          Column(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: tint.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: tint, size: 22.sp),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          tint.withOpacity(0.5),
                          colorScheme.outlineVariant.withOpacity(0.2),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 20.w),

          // --- Content Area ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  desc,
                  style: GoogleFonts.lato(
                    fontSize: 14.sp,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h), // Spacing between steps
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 34.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
              child: Text(
                "Start Configuration",
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
              ),
              child: Text(
                "Maybe later",
                style: GoogleFonts.lato(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
