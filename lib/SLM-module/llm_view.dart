import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'llm_controller.dart';

class LlmChatView extends StatelessWidget {
  final controller = Get.put(LlmController());
  final TextEditingController _inputController = TextEditingController();

  LlmChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SmolLM2 Mobile",
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Obx(
            () => Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child:
                    controller.isModelLoaded.value
                        ? Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 24.sp,
                        )
                        : SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.indigo,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        // --- 1. Downloading / Initializing State ---
        if (!controller.isModelLoaded.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (controller.isDownloading.value) ...[
                  Icon(
                    Icons.cloud_download_rounded,
                    size: 48.sp,
                    color: Colors.indigo,
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: LinearProgressIndicator(
                      value: controller.downloadProgress.value,
                      backgroundColor: Colors.grey[200],
                      color: Colors.indigo,
                      minHeight: 6.h,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ] else ...[
                  Icon(Icons.settings_suggest, size: 48.sp, color: Colors.grey),
                ],
                SizedBox(height: 20.h),
                Text(
                  controller.statusText.value,
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                ),
              ],
            ),
          );
        }

        // --- 2. Chat Interface ---
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isUser = msg['role'] == 'user';

                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      constraints: BoxConstraints(maxWidth: 0.8.sw),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.indigo : Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(18.r),
                          topRight: Radius.circular(18.r),
                          bottomLeft:
                              isUser ? Radius.circular(18.r) : Radius.zero,
                          bottomRight:
                              isUser ? Radius.zero : Radius.circular(18.r),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        msg['text'] ?? "",
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 15.sp,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Input Field
            Container(
              padding: EdgeInsets.all(12.w),
              color: Colors.white,
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        enabled: !controller.isGenerating.value,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    CircleAvatar(
                      backgroundColor:
                          controller.isGenerating.value
                              ? Colors.grey
                              : Colors.indigo,
                      radius: 22.r,
                      child: IconButton(
                        icon:
                            controller.isGenerating.value
                                ? SizedBox(
                                  width: 18.w,
                                  height: 18.w,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : Icon(
                                  Icons.arrow_upward,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                        onPressed:
                            controller.isGenerating.value
                                ? null
                                : () {
                                  controller.sendMessage(_inputController.text);
                                  _inputController.clear();
                                  FocusScope.of(context).unfocus();
                                },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
