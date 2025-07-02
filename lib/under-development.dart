import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const ProgressAppBar(), body: const ProgressContent());
  }
}

class ProgressAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ProgressAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      elevation: 0,
      leading: IconButton(
        icon: SvgPicture.string(
          '''
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="currentColor" viewBox="0 0 256 256">
            <path d="M224,128a8,8,0,0,1-8,8H59.31l58.35,58.34a8,8,0,0,1-11.32,11.32l-72-72a8,8,0,0,1,0-11.32l72-72a8,8,0,0,1,11.32,11.32L59.31,120H216A8,8,0,0,1,224,128Z"></path>
          </svg>
          ''',
          width: 24.sp,
          height: 24.sp,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onPressed: () {
          // Handle back navigation
        },
      ),
      title: Text(
        'Progress',
        style: GoogleFonts.workSans(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: -0.27.sp, // -0.015 * 18 = -0.27
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}

class ProgressContent extends StatelessWidget {
  const ProgressContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            child: AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuA2oiDynAgCjR7iCR_9DjV80fHIHXwyOOxI8W12F_FcqQ8Jbxe3VSdWUvB77Dijny-VtdhnUsABgYpRMrpZaeLxaMpnzWhzcRVwUrlsrOgJQtnSEFvaeMVzVS6nYxfBQu1naU2Pho8buNA3sHA4yf_YTgCEG1ZdpQqvHnx-ehz9u5qN0brEJyknILEg49H0sln0Y_C-SPgM7V2l2qZGhxMKWma3ROSH40L7iVfMfdKmVjiKBjDU4Bw8PTCGG_2Sw0eSGCcr0mnVLXs',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 12.h),
            child: Text(
              'Under Development',
              style: GoogleFonts.workSans(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.42.sp, // -0.015 * 28 = -0.42
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Text(
              'This feature is currently under development and will be available soon. We appreciate your patience.',
              style: GoogleFonts.workSans(fontSize: 16.sp, fontWeight: FontWeight.normal, color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
