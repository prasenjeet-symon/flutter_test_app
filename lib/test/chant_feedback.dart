import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void showChantCounterFeedbackSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.35,
        minChildSize: 0.15,
        maxChildSize: 0.5,
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(12.r))),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                // Drag handle
                Center(child: Container(margin: EdgeInsets.symmetric(vertical: 6.h), width: 32.w, height: 3.h, decoration: BoxDecoration(color: Theme.of(context).dividerColor, borderRadius: BorderRadius.circular(100.r)))),
                // Title
                Padding(
                  padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 6.h),
                  child: Text(
                    'Are you happy with the chant counter?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold, letterSpacing: -0.015 * 20.sp, color: Theme.of(context).textTheme.bodyLarge?.color),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  child: Text('Did it perform as expected?', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp, fontWeight: FontWeight.normal, color: Theme.of(context).textTheme.bodyLarge?.color), textAlign: TextAlign.center),
                ),
                // Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle Yes button press
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            minimumSize: Size(80.w, 36.h),
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                            textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, letterSpacing: 0.015 * 13.sp),
                          ),
                          child: Text('Yes'),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle No button press
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Theme.of(context).colorScheme.onSecondary,
                            minimumSize: Size(80.w, 36.h),
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
                            textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, letterSpacing: 0.015 * 13.sp),
                          ),
                          child: Text('No'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class ChantCounterFeedbackSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: ElevatedButton(onPressed: () => showChantCounterFeedbackSheet(context), child: Text('Show Chant Counter Feedback Sheet'))));
  }
}
