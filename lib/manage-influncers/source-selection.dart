import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class InfluencerSourceSelectionScreen extends StatelessWidget {
  const InfluencerSourceSelectionScreen({super.key});

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
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              // --- Header Section ---
              Text(
                "Influencer Source",
                style: GoogleFonts.lato(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  letterSpacing: -1.2,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Select how you would like to add an influencer to your directory.",
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  height: 1.4,
                ),
              ),

              SizedBox(height: 48.h),

              // --- Option 1: Existing on Platform ---
              _buildSelectionCard(
                context,
                title: "Existing Influencer",
                description:
                    "Search and select from users already present on this platform.",
                icon: Icons.person_search_rounded,
                iconBgColor: colorScheme.primary.withOpacity(0.1),
                iconColor: colorScheme.primary,
                onTap: () {
                  // Navigate to search and select flow
                },
              ),

              SizedBox(height: 24.h),

              // --- Option 2: Reserve New (Not on platform) ---
              _buildSelectionCard(
                context,
                title: "Reserve New Influencer",
                description:
                    "The influencer is not on this platform yet. Create a new profile for approval.",
                icon: Icons.add_moderator_rounded,
                iconBgColor: const Color(0xFF10B981).withOpacity(0.1),
                iconColor: const Color(0xFF10B981),
                onTap: () {
                  // Navigate to the Warning/Instruction screen before creation
                },
              ),

              const Spacer(),

              // --- Footer Info ---
              Center(
                child: Column(
                  children: [
                    Text(
                      "All new influencers go through a verification process.",
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color:
            colorScheme
                .surface, // Card surface color to pop against scaffold bg
        borderRadius: BorderRadius.circular(28.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28.r),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Modern Icon Container ---
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 28.sp),
                ),
                SizedBox(width: 20.w),

                // --- Text Area ---
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                        description,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Subtle Arrow Indicator ---
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 20.sp,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
