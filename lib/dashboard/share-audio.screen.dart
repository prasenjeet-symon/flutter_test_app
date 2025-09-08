import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test_app/dashboard/edit_audio.screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:file_picker/file_picker.dart';
import 'package:audioplayers/audioplayers.dart';

class CreateAudioPostScreen extends StatefulWidget {
  const CreateAudioPostScreen({Key? key}) : super(key: key);

  @override
  State<CreateAudioPostScreen> createState() => _CreateAudioPostScreenState();
}

class _CreateAudioPostScreenState extends State<CreateAudioPostScreen> {
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postDescriptionController = TextEditingController();
  final TextEditingController _postLocationController = TextEditingController();
  final TextEditingController _postLatitudeController = TextEditingController();
  final TextEditingController _postLongitudeController = TextEditingController();


  final _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String? _originalAudioPath;
  String? _trimmedAudioPath;
  bool _isPlaying = false;
  double _currentPosition = 0;
  double _audioDuration = 0;
  double _cropStart = 0;
  double _cropEnd = 0;

  bool _isGettingLocation = false;
  bool _allowOutsideVisibility = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).viewInsets.bottom > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position.inMilliseconds.toDouble();
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _audioDuration = duration.inMilliseconds.toDouble();
        });
      }
    });
  }

  @override
  void dispose() {
    _postTitleController.dispose();
    _postDescriptionController.dispose();
    _postLocationController.dispose();
    _scrollController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _originalAudioPath = result.files.single.path;
        _trimmedAudioPath = null;
        _cropStart = 0;
        _cropEnd = 0;
      });
      _loadAudio(_originalAudioPath!);
    }
  }

  Future<void> _loadAudio(String path) async {
    if (path.isNotEmpty) {
      await _audioPlayer.setSourceDeviceFile(path);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_audioPlayer.state == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      String? path = _trimmedAudioPath ?? _originalAudioPath;
      if (path != null) {
        // Stop any previous playback and load the correct audio
        if (_audioPlayer.source?.toString().contains(path) != true) {
          await _audioPlayer.stop();
          await _audioPlayer.setSourceDeviceFile(path);
        }
        await _audioPlayer.resume();
      }
    }
  }

  void _seekAudio(double value) {
    _audioPlayer.seek(Duration(milliseconds: value.toInt()));
  }

  Future<void> _navigateToEditScreen() async {
    if (_originalAudioPath == null) return;

    _audioPlayer.stop();

    // final result = await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => EditAudioScreen(
    //       originalAudioPath: _originalAudioPath!,
    //       initialTrimStart: _cropStart,
    //       initialTrimEnd: _cropEnd == 0 ? _audioDuration / 1000 : _cropEnd,
    //     ),
    //   ),
    // );
    //
    // if (result != null && result is Map<String, dynamic>) {
    //   final String? trimmedPath = result['trimmedAudioPath'];
    //   final double? newCropStart = result['cropStart'];
    //   final double? newCropEnd = result['cropEnd'];
    //
    //   if (trimmedPath != null) {
    //     await _audioPlayer.stop();
    //     setState(() {
    //       _trimmedAudioPath = trimmedPath;
    //       _cropStart = newCropStart ?? 0;
    //       _cropEnd = newCropEnd ?? 0;
    //       _currentPosition = 0; // Reset seek bar position to 0
    //     });
    //     await _loadAudio(_trimmedAudioPath!);
    //   }
    // }
  }

  void _clearAudioSelection() {
    _audioPlayer.stop();
    setState(() {
      _originalAudioPath = null;
      _trimmedAudioPath = null;
      _currentPosition = 0;
      _audioDuration = 0;
      _cropStart = 0;
      _cropEnd = 0;
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _postLocationController.text = 'Getting location...';
    });
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _handleLocationError('Location services are disabled.');
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _handleLocationError('Location permissions denied.');
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _handleLocationError('Location permissions are permanently denied.');
      return;
    }
    try {
      Position position =
          await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country
        ].where((element) => element != null && element.isNotEmpty).join(', ');
        setState(() {
          _postLocationController.text = address;
          _postLatitudeController.text = position.latitude.toString();
          _postLongitudeController.text = position.longitude.toString();
           });
      } else {
        setState(() {
          _postLocationController.text = 'Lat: ${position.latitude}, Lon: ${position.longitude}';
        });
      }
    } catch (e) {
      _handleLocationError('Could not get location.');
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _handleLocationError(String message) {
    setState(() {
      _isGettingLocation = false;
      _postLocationController.text = message;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _createPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Audio Post Creating:\nAudio: ${_trimmedAudioPath != null ? "Trimmed" : "Original"}\nTitle: "${_postTitleController.text}"\nDescription: "${_postDescriptionController.text}"\nLocation: "${_postLocationController.text}"\nOutside Visibility: $_allowOutsideVisibility',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool readOnly = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, color: Theme.of(context).colorScheme.onSurfaceVariant)
              : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.w)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        ),
        style: GoogleFonts.lato(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  String _formatDuration(double milliseconds) {
    if (milliseconds.isNaN || milliseconds.isInfinite) {
      return '00:00';
    }
    final seconds = milliseconds / 1000;
    int minutes = (seconds / 60).truncate();
    int remainingSeconds = (seconds % 60).truncate();
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = remainingSeconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Audio Post',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3), width: 1.w),
              ),
              child: _originalAudioPath == null ? _buildUploadView() : _buildAudioPlayerView(),
            ),
            SizedBox(height: 10.h),
            _buildTextField(
              controller: _postTitleController,
              hintText: 'Add a title...',
              prefixIcon: Icons.title,
            ),
            _buildTextField(
              controller: _postDescriptionController,
              hintText: 'Write a description...',
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
            _buildSelectionField(
              context,
              hintText: 'Add an organization (optional)',
              prefixIcon: Icons.business_center_outlined,
              value: null,
              onTap: () => {},
            ),
            _buildSelectionField(
              context,
              hintText: 'Add a topic',
              prefixIcon: Icons.tag,
              value: '',
              onTap: () => {},
            ),
            _buildTextField(
              controller: _postLocationController,
              hintText: 'Add your location (optional)',
              prefixIcon: Icons.location_on_outlined,
              readOnly: true,
              suffixIcon: IconButton(
                onPressed: _getCurrentLocation,
                icon: _isGettingLocation
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ))
                    : Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Allow outside organization visibility',
                  style: GoogleFonts.lato(
                      fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                ),
                Switch(
                  value: _allowOutsideVisibility,
                  onChanged: (newValue) {
                    setState(() {
                      _allowOutsideVisibility = newValue;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16.h,
          top: 16.h,
          left: 16.w,
          right: 16.w,
        ),
        color: Theme.of(context).colorScheme.surface,
        child: FilledButton(
          onPressed: (_originalAudioPath != null && _postTitleController.text.isNotEmpty)
              ? _createPost
              : null,
          style: FilledButton.styleFrom(
            minimumSize: Size(double.infinity, 48.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            textStyle: GoogleFonts.lato(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          child: const Text('Share'),
        ),
      ),
    );
  }

  // --- WIDGET FOR UPLOAD VIEW ---
  Widget _buildUploadView() {
    return InkWell(
      onTap: _pickAudioFile,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60.h, horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.upload_file_outlined,
              size: 60.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 12.h),
            Text(
              'Tap to Upload Audio',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET FOR AUDIO PLAYER VIEW ---
  Widget _buildAudioPlayerView() {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 16.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _trimmedAudioPath != null ? 'Trimmed Audio Ready' : 'Audio Ready for Posting',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                (_trimmedAudioPath ?? _originalAudioPath)!.split('/').last,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              _AudioPlayerPreview(
                  isPlaying: _isPlaying,
                  currentPosition: _currentPosition,
                  audioDuration: _audioDuration,
                  togglePlayPause: _togglePlayPause,
                  seek: _seekAudio,
                  formatDuration: _formatDuration),

              // SizedBox(height: 24.h),

              // **UI ENHANCEMENT**: Changed to a less prominent OutlinedButton
              // OutlinedButton.icon(
              //   onPressed: _navigateToEditScreen,
              //   icon: Icon(Icons.cut_outlined, size: 20.sp),
              //   label: Text('Trim or Edit Audio', style: GoogleFonts.lato(fontSize: 16.sp)),
              //   style: OutlinedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
              //   ),
              // ),
            ],
          ),
        ),
        // **UI CHANGE**: "Change Audio" button moved to a close icon here
        Positioned(
          top: 8.h,
          right: 8.w,
          child: Material(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
            borderRadius: BorderRadius.circular(30.r),
            clipBehavior: Clip.antiAlias,
            child: GestureDetector(
              onTap: _clearAudioSelection,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.all(6.r),
                child: Icon(
                  Icons.close_rounded,
                  size: 18.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionField(
    BuildContext context, {
    required String hintText,
    required IconData prefixIcon,
    required void Function() onTap,
    String? value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextField(
            controller: TextEditingController(text: value),
            readOnly: true,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: Icon(prefixIcon, color: Theme.of(context).colorScheme.onSurfaceVariant),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.w)),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            ),
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

// --- NEW WAVEFORM PLAYER WIDGET ---
class _AudioPlayerPreview extends StatelessWidget {
  final bool isPlaying;
  final double currentPosition;
  final double audioDuration;
  final VoidCallback togglePlayPause;
  final Function(double) seek;
  final String Function(double) formatDuration;

  const _AudioPlayerPreview({
    required this.isPlaying,
    required this.currentPosition,
    required this.audioDuration,
    required this.togglePlayPause,
    required this.seek,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (audioDuration > 0) ? currentPosition / audioDuration : 0.0;

    final Color backgroundColor =
        theme.brightness == Brightness.dark ? const Color(0xFF2A284D) : const Color(0xFFE0E7FF);
    final Color activeColor =
        theme.brightness == Brightness.dark ? const Color(0xFFa78bfa) : theme.colorScheme.primary;
    final Color inactiveColor = theme.brightness == Brightness.dark
        ? const Color(0xFF4c3d91)
        : theme.colorScheme.primary.withOpacity(0.3);
    final Color iconColor =
        theme.brightness == Brightness.dark ? const Color(0xFF1e1b4b) : theme.colorScheme.onPrimary;
    final Color textColor =
        theme.brightness == Brightness.dark ? const Color(0xFFddd6fe) : theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.sp,
            height: 48.sp,
            decoration: BoxDecoration(color: activeColor, shape: BoxShape.circle),
            child: IconButton(
              onPressed: togglePlayPause,
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                size: 28.sp,
                color: iconColor,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final position = box.globalToLocal(details.globalPosition);
                final newProgress = position.dx / box.size.width;
                seek((newProgress * audioDuration).clamp(0.0, audioDuration));
              },
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final position = box.globalToLocal(details.globalPosition);
                final newProgress = position.dx / box.size.width;
                seek((newProgress * audioDuration).clamp(0.0, audioDuration));
              },
              child: CustomPaint(
                size: Size(double.infinity, 40.h),
                painter: WaveformPainter(
                  progress: progress,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            formatDuration(audioDuration),
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for the waveform
class WaveformPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final List<double> _waveHeights = [
    0.4,
    0.6,
    0.8,
    0.5,
    0.7,
    0.9,
    0.6,
    0.4,
    0.7,
    0.5,
    0.8,
    0.6,
    0.9,
    0.7,
    0.5,
    0.4,
    0.6,
    0.8,
    0.5,
    0.7,
    0.9,
    0.6,
    0.4,
    0.7,
    0.5,
    0.8,
    0.6,
    0.9,
    0.7,
    0.5,
    0.4,
    0.6,
    0.8,
    0.5,
    0.7,
    0.9,
    0.6,
    0.4,
    0.7,
    0.5,
    0.8,
    0.6,
    0.9,
    0.7,
    0.5
  ];

  WaveformPainter({required this.progress, required this.activeColor, required this.inactiveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final barWidth = 3.0;
    final barSpacing = 2.0;
    final totalBarWidth = barWidth + barSpacing;
    final count = (size.width / totalBarWidth).floor();
    final activeBarCount = (count * progress).floor();

    for (int i = 0; i < count; i++) {
      paint.color = i < activeBarCount ? activeColor : inactiveColor;
      final barHeight = _waveHeights[i % _waveHeights.length] * size.height;
      final top = (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * totalBarWidth, top, barWidth, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
