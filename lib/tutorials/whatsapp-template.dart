import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ---------------------------------------------------------------------------
// USAGE:
// Get.to(
//   () => const WhatsAppTemplateTutorialScreen(),
//   fullscreenDialog: true,
//   transition: Transition.downToUp,
// );
// ---------------------------------------------------------------------------

// 1. The Controller (Logic)
class WhatsAppTemplateTutorialController extends GetxController {
  final PageController pageController = PageController();

  // Reactive variable for current index
  var currentIndex = 0.obs;

  final List<TutorialStep> steps = [
    TutorialStep(
      title: "What is a Template?",
      description:
          "A WhatsApp Template is a pre-approved message format required to start a conversation with customers. It's like a verified 'digital letterhead'.",
      icon: Icons.mark_chat_read_outlined,
    ),
    TutorialStep(
      title: "Why is it Required?",
      description:
          "To prevent spam! You cannot send random messages to users first. Meta requires templates to ensure content is safe and not promotional spam.",
      icon: Icons.shield_outlined,
    ),
    TutorialStep(
      title: "How to Use It",
      description:
          "Create a message with variables like 'Hello {{1}}'. Once approved, you can reuse it for thousands of customers automatically.",
      icon: Icons.auto_fix_high_outlined,
    ),
  ];

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void updateIndex(int index) {
    currentIndex.value = index;
  }

  void closeScreen() {
    Get.back();
  }

  void onNextPressed() {
    if (currentIndex.value == steps.length - 1) {
      closeScreen();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
}

// 2. The View (UI)
class WhatsAppTemplateTutorialScreen extends StatelessWidget {
  const WhatsAppTemplateTutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WhatsAppTemplateTutorialController());
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // --- Color Strategy for Light/Dark Mode ---
    // Brand Green: Kept bright in both modes, but slightly adjusted for contrast if needed
    final Color brandColor = const Color(0xFF25D366);

    // Button Color:
    // Light Mode -> Dark Teal (Contrast against white bg)
    // Dark Mode  -> Bright Green (Contrast against dark bg)
    final Color buttonColor =
        isDark ? const Color(0xFF25D366) : const Color(0xFF075E54);

    // Button Text Color:
    // Light Mode -> White
    // Dark Mode  -> Black (since button is bright green)
    final Color buttonTextColor = isDark ? Colors.black : Colors.white;

    // Inactive Dot Color:
    final Color inactiveDotColor =
        isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: controller.closeScreen,
        ),
        actions: [
          TextButton(
            onPressed: controller.closeScreen,
            child: Text(
              "Skip",
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // -------------------------
            // 1. Main Content Carousel
            // -------------------------
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.steps.length,
                onPageChanged: controller.updateIndex,
                itemBuilder: (context, index) {
                  return _buildPageContent(
                    context,
                    controller.steps[index],
                    brandColor,
                  );
                },
              ),
            ),

            // -------------------------
            // 2. Bottom Controls
            // -------------------------
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicator (Wrapped in Obx)
                  Obx(
                    () => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(controller.steps.length, (index) {
                        return _buildDot(
                          index,
                          controller.currentIndex.value,
                          brandColor,
                          inactiveDotColor,
                        );
                      }),
                    ),
                  ),

                  // Next / Finish Button
                  ElevatedButton(
                    onPressed: controller.onNextPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonTextColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 0,
                    ),
                    child: Obx(
                      () => Text(
                        controller.currentIndex.value ==
                                controller.steps.length - 1
                            ? "Finish"
                            : "Next",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(
    int index,
    int currentIndex,
    Color activeColor,
    Color inactiveColor,
  ) {
    bool isActive = currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(right: 6.w),
      height: 8.h,
      width: isActive ? 24.w : 8.w,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }

  Widget _buildPageContent(
    BuildContext context,
    TutorialStep step,
    Color brandColor,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with graphical background
          Container(
            height: 200.h,
            width: 200.w,
            decoration: BoxDecoration(
              // Using opacity ensures it looks good on both white and black backgrounds
              color: brandColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 80.sp, color: brandColor),
          ),

          SizedBox(height: 40.h),

          // Title
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 26.sp,
              fontWeight: FontWeight.bold,
              color:
                  theme
                      .colorScheme
                      .onSurface, // Automatically white in dark mode
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: 16.h),

          // Description
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 15.sp,
              // Light opacity text for hierarchy
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}
