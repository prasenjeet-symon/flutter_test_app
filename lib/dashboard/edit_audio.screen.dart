// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_xlider/flutter_xlider.dart';
// import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_new/return_code.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
//
// class EditAudioScreen extends StatefulWidget {
//   final String originalAudioPath;
//   final double? initialTrimStart;
//   final double? initialTrimEnd;
//
//   const EditAudioScreen({
//     Key? key,
//     required this.originalAudioPath,
//     this.initialTrimStart,
//     this.initialTrimEnd,
//   }) : super(key: key);
//
//   @override
//   State<EditAudioScreen> createState() => _EditAudioScreenState();
// }
// class _EditAudioScreenState extends State<EditAudioScreen> {
//   final AudioPlayer _audioPlayer = AudioPlayer();
//
//   bool _isPlaying = false;
//   double _currentPosition = 0;
//   double _audioDuration = 0;
//   double _cropStart = 0;
//   double _cropEnd = 0;
//   bool _isTrimming = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadAudio(widget.originalAudioPath);
//
//     _audioPlayer.onPlayerStateChanged.listen((state) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = state == PlayerState.playing;
//         });
//       }
//     });
//
//     _audioPlayer.onPositionChanged.listen((position) {
//       if (mounted) {
//         final currentSeconds = position.inMilliseconds / 1000;
//         // Auto-pause and reset if playback goes beyond the selected trim area
//         if (_cropEnd > 0 && currentSeconds >= _cropEnd) {
//           _audioPlayer.pause();
//           final seekToPosition = Duration(milliseconds: (_cropStart * 1000).toInt());
//           _audioPlayer.seek(seekToPosition);
//           // UX FIX: Update the currentPosition state to reflect the seek
//           setState(() {
//             _currentPosition = seekToPosition.inMilliseconds.toDouble();
//           });
//         } else {
//           setState(() {
//             _currentPosition = position.inMilliseconds.toDouble();
//           });
//         }
//       }
//     });
//
//     _audioPlayer.onDurationChanged.listen((duration) {
//       if (mounted) {
//         final newAudioDuration = duration.inMilliseconds.toDouble();
//         // Guard against invalid duration
//         if (newAudioDuration <= 0) return;
//
//         setState(() {
//           _audioDuration = newAudioDuration;
//           final maxDurationInSeconds = newAudioDuration / 1000;
//
//           // Initialize or update crop values
//           double newCropStart = widget.initialTrimStart ?? 0;
//           double newCropEnd = widget.initialTrimEnd ?? maxDurationInSeconds;
//
//           // **CRASH FIX**: Clamp values to ensure they are valid for the slider.
//           // This prevents "Upper value should be smaller than max" errors by ensuring
//           // the values passed to the slider during the next build are always valid.
//           _cropStart = newCropStart.clamp(0.0, maxDurationInSeconds);
//           _cropEnd = newCropEnd.clamp(_cropStart, maxDurationInSeconds);
//         });
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _audioPlayer.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadAudio(String path) async {
//     if (path.isNotEmpty) {
//       await _audioPlayer.setSourceDeviceFile(path);
//     }
//   }
//
//   Future<void> _togglePlayPause() async {
//     // If playing, pause.
//     if (_audioPlayer.state == PlayerState.playing) {
//       await _audioPlayer.pause();
//     } else {
//       // If paused or stopped, check if the current position is outside the trim range.
//       if (_currentPosition / 1000 < _cropStart || _currentPosition / 1000 >= _cropEnd) {
//         // If so, seek to the start of the trim range before resuming.
//         await _audioPlayer.seek(Duration(milliseconds: (_cropStart * 1000).toInt()));
//       }
//       await _audioPlayer.resume();
//     }
//   }
//
//   Future<void> _trimAudioAndReturn() async {
//     if (_isTrimming) return;
//
//     setState(() {
//       _isTrimming = true;
//     });
//
//     // **CRASH FIX**: Store context-dependent objects BEFORE the async gap.
//     final scaffoldMessenger = ScaffoldMessenger.of(context);
//     final navigator = Navigator.of(context);
//
//     try {
//       final Directory tempDir = await getTemporaryDirectory();
//       final String outputPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_trimmed.mp3';
//
//       final String command = '-i "${widget.originalAudioPath}" -ss $_cropStart -to $_cropEnd -c copy "$outputPath"';
//
//       final session = await FFmpegKit.execute(command);
//       final returnCode = await session.getReturnCode();
//
//       if (ReturnCode.isSuccess(returnCode)) {
//         scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Audio trimmed successfully!')));
//         navigator.pop({
//           'trimmedAudioPath': outputPath,
//           'cropStart': _cropStart,
//           'cropEnd': _cropEnd,
//         });
//       } else {
//         scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Audio trimming failed.')));
//         navigator.pop(null);
//       }
//     } catch (e) {
//       scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
//       navigator.pop(null);
//     } finally {
//       if(mounted){
//         setState(() {
//           _isTrimming = false;
//         });
//       }
//     }
//   }
//
//   String _formatDuration(double seconds) {
//     if (seconds.isNaN || seconds.isInfinite) {
//       return '00:00';
//     }
//     int minutes = (seconds / 60).truncate();
//     int remainingSeconds = (seconds % 60).truncate();
//     String minutesStr = minutes.toString().padLeft(2, '0');
//     String secondsStr = remainingSeconds.toString().padLeft(2, '0');
//     return '$minutesStr:$secondsStr';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Edit Audio', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
//         centerTitle: true,
//         backgroundColor: Theme.of(context).colorScheme.surface,
//         elevation: 1,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(16.r),
//                   border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), width: 1.w),
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'Editing Audio',
//                       style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface),
//                     ),
//                     SizedBox(height: 8.h),
//                     Text(
//                       widget.originalAudioPath.split('/').last,
//                       style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     SizedBox(height: 24.h),
//                     // --- WAVEFORM PLAYER WIDGET ---
//                     _WaveformDisplay(
//                       isPlaying: _isPlaying,
//                       progress: (_audioDuration > 0) ? _currentPosition / _audioDuration : 0.0,
//                       onTogglePlayPause: _togglePlayPause,
//                     ),
//                     SizedBox(height: 16.h),
//                     // --- RANGE SLIDER FOR TRIMMING ---
//                     if (_audioDuration > 0)
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 8.w),
//                         child: FlutterSlider(
//                           values: [_cropStart, _cropEnd],
//                           max: _audioDuration / 1000,
//                           min: 0,
//                           rangeSlider: true,
//                           onDragging: (handlerIndex, lowerValue, upperValue) {
//                             // **RANGE FIX**: Clamp values during dragging to prevent out-of-bounds errors.
//                             final maxDurationInSeconds = _audioDuration / 1000;
//                             final newCropStart = lowerValue.clamp(0.0, maxDurationInSeconds);
//                             final newCropEnd = upperValue.clamp(newCropStart, maxDurationInSeconds);
//                             setState(() {
//                               _cropStart = newCropStart;
//                               _cropEnd = newCropEnd;
//                             });
//                           },
//                           onDragCompleted: (handlerIndex, lowerValue, upperValue) {
//                             _audioPlayer.seek(Duration(milliseconds: (lowerValue * 1000).toInt()));
//                           },
//                           trackBar: FlutterSliderTrackBar(
//                             activeTrackBarHeight: 6.h,
//                             activeTrackBar: BoxDecoration(color: Theme.of(context).colorScheme.primary),
//                             inactiveTrackBar: BoxDecoration(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3)),
//                           ),
//                           handler: _buildSliderHandler(),
//                           rightHandler: _buildSliderHandler(),
//                           tooltip: FlutterSliderTooltip(
//                             format: (value) => _formatDuration(double.parse(value)),
//                             textStyle: GoogleFonts.lato(fontSize: 14.sp, color: Theme.of(context).colorScheme.onPrimary),
//                             boxStyle: FlutterSliderTooltipBox(
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).colorScheme.primary,
//                                 borderRadius: BorderRadius.circular(5.r),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     if (_audioDuration > 0) SizedBox(height: 8.h),
//                     if (_audioDuration > 0)
//                       Padding(
//                         padding: EdgeInsets.symmetric(horizontal: 24.w),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               _formatDuration(_currentPosition / 1000),
//                               style: GoogleFonts.lato(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
//                             ),
//                             Text(
//                               _formatDuration(_audioDuration / 1000),
//                               style: GoogleFonts.lato(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
//                             ),
//                           ],
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 32.h),
//               _isTrimming
//                   ? const CircularProgressIndicator()
//                   : SizedBox(
//                 width: double.infinity,
//                 child: FilledButton.icon(
//                   onPressed: _trimAudioAndReturn,
//                   icon: Icon(Icons.cut_outlined, size: 20.sp),
//                   label: const Text('Trim & Save'),
//                   style: FilledButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 12.h),
//                     textStyle: GoogleFonts.lato(fontSize: 18.sp, fontWeight: FontWeight.bold),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   FlutterSliderHandler _buildSliderHandler() {
//     return FlutterSliderHandler(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         shape: BoxShape.circle,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black26,
//             blurRadius: 2,
//             spreadRadius: 0.5,
//             offset: Offset(0, 1),
//           )
//         ],
//       ),
//       child: Container(
//         padding: EdgeInsets.all(4.w),
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(
//           Icons.drag_handle,
//           size: 20.sp,
//           color: Theme.of(context).colorScheme.primary,
//         ),
//       ),
//     );
//   }
// }
//
//
// // --- WAVEFORM DISPLAY WIDGET (for Edit Screen) ---
// class _WaveformDisplay extends StatelessWidget {
//   final bool isPlaying;
//   final double progress;
//   final VoidCallback onTogglePlayPause;
//
//   const _WaveformDisplay({
//     required this.isPlaying,
//     required this.progress,
//     required this.onTogglePlayPause,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//
//     final Color backgroundColor = theme.brightness == Brightness.dark ? const Color(0xFF2A284D) : const Color(0xFFE0E7FF);
//     final Color activeColor = theme.brightness == Brightness.dark ? const Color(0xFFa78bfa) : theme.colorScheme.primary;
//     final Color inactiveColor = theme.brightness == Brightness.dark ? const Color(0xFF4c3d91) : theme.colorScheme.primary.withOpacity(0.3);
//     final Color iconColor = theme.brightness == Brightness.dark ? const Color(0xFF1e1b4b) : theme.colorScheme.onPrimary;
//
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 48.sp,
//             height: 48.sp,
//             decoration: BoxDecoration(
//               color: activeColor,
//               shape: BoxShape.circle,
//             ),
//             child: IconButton(
//               onPressed: onTogglePlayPause,
//               icon: Icon(
//                 isPlaying ? Icons.pause : Icons.play_arrow,
//                 size: 28.sp,
//                 color: iconColor,
//               ),
//               padding: EdgeInsets.zero,
//             ),
//           ),
//           SizedBox(width: 16.w),
//           Expanded(
//             child: CustomPaint(
//               size: Size(double.infinity, 40.h),
//               painter: WaveformPainter(
//                 progress: progress,
//                 activeColor: activeColor,
//                 inactiveColor: inactiveColor,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Custom Painter for the waveform (reused from the other screen)
// class WaveformPainter extends CustomPainter {
//   final double progress;
//   final Color activeColor;
//   final Color inactiveColor;
//   final List<double> _waveHeights = [0.4, 0.6, 0.8, 0.5, 0.7, 0.9, 0.6, 0.4, 0.7, 0.5, 0.8, 0.6, 0.9, 0.7, 0.5, 0.4, 0.6, 0.8, 0.5, 0.7, 0.9, 0.6, 0.4, 0.7, 0.5, 0.8, 0.6, 0.9, 0.7, 0.5, 0.4, 0.6, 0.8, 0.5, 0.7, 0.9, 0.6, 0.4, 0.7, 0.5, 0.8, 0.6, 0.9, 0.7, 0.5];
//
//   WaveformPainter({required this.progress, required this.activeColor, required this.inactiveColor});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()..style = PaintingStyle.fill;
//     final barWidth = 3.0;
//     final barSpacing = 2.0;
//     final totalBarWidth = barWidth + barSpacing;
//     final count = (size.width / totalBarWidth).floor();
//     final activeBarCount = (count * progress).floor();
//
//     for (int i = 0; i < count; i++) {
//       paint.color = i < activeBarCount ? activeColor : inactiveColor;
//       final barHeight = _waveHeights[i % _waveHeights.length] * size.height;
//       final top = (size.height - barHeight) / 2;
//
//       canvas.drawRRect(
//         RRect.fromRectAndRadius(
//           Rect.fromLTWH(i * totalBarWidth, top, barWidth, barHeight),
//           const Radius.circular(2),
//         ),
//         paint,
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
//
