import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class InfluencerSubmissionSuccessScreen extends StatelessWidget {
  final String influencerName;
  final String? profileImagePath;

  const InfluencerSubmissionSuccessScreen({
    super.key,
    required this.influencerName,
    this.profileImagePath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Using a standard success green color
    const Color successColor = Color(0xFF10B981);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- Success Icon with Success Color ---
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: successColor.withOpacity(0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: successColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 80.sp,
                        color: successColor,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // --- Header ---
                    Text(
                      "Request Submitted",
                      style: GoogleFonts.lato(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "The influencer profile has been submitted successfully and is now awaiting strategic review.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 15.sp,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 48.h),

                    // --- Influencer Summary Card ---
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(24.r),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // --- Displaying Received Profile Pic ---
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface.withOpacity(0.05),
                              shape: BoxShape.circle,
                              image:
                                  (profileImagePath != null &&
                                          profileImagePath!.isNotEmpty)
                                      ? DecorationImage(
                                        image: FileImage(
                                          File(profileImagePath!),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                      : null,
                            ),
                            child:
                                (profileImagePath == null ||
                                        profileImagePath!.isEmpty)
                                    ? Icon(
                                      Icons.person_rounded,
                                      color: colorScheme.primary,
                                    )
                                    : null,
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  influencerName,
                                  style: GoogleFonts.lato(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  "Pending Approval",
                                  style: GoogleFonts.lato(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Simplified Bottom Navigation ---
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 34.h),
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed:
                      () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Back to Dashboard",
                    style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
