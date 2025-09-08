import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CreateYouTubePostScreen extends StatefulWidget {
  const CreateYouTubePostScreen({Key? key}) : super(key: key);

  @override
  State<CreateYouTubePostScreen> createState() => _CreateYouTubePostScreenState();
}

class _CreateYouTubePostScreenState extends State<CreateYouTubePostScreen> {
  final TextEditingController _youtubeLinkController = TextEditingController();
  final TextEditingController _postTitleController = TextEditingController();
  final TextEditingController _postDescriptionController = TextEditingController();
  final TextEditingController _postLocationController = TextEditingController();
  final TextEditingController _postLatitudeController = TextEditingController();
  final TextEditingController _postLongitudeController = TextEditingController();

  final _scrollController = ScrollController();

  YoutubePlayerController? _youtubePlayerController;
  bool _isGettingLocation = false;
  String? _currentVideoId;
  bool _allowOutsideVisibility = false;

  @override
  void initState() {
    super.initState();
    _youtubeLinkController.addListener(_onYoutubeLinkChanged);
    // Add a post-frame callback to automatically scroll to the bottom when the keyboard appears.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (MediaQuery.of(context).viewInsets.bottom > 0) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _youtubeLinkController.removeListener(_onYoutubeLinkChanged);
    _youtubeLinkController.dispose();
    _postTitleController.dispose();
    _postDescriptionController.dispose();
    _postLocationController.dispose();
    _youtubePlayerController?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onYoutubeLinkChanged() {
    String? videoId = YoutubePlayer.convertUrlToId(_youtubeLinkController.text);
    if (videoId != null && videoId != _currentVideoId) {
      setState(() {
        _currentVideoId = videoId;
        _youtubePlayerController?.dispose();
        _youtubePlayerController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            showLiveFullscreenButton: false
          ),
        );
      });
    } else if (videoId == null && _currentVideoId != null) {
      setState(() {
        _currentVideoId = null;
        _youtubePlayerController?.dispose();
        _youtubePlayerController = null;
      });
    }
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
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = [place.street, place.subLocality, place.locality, place.administrativeArea, place.country].where((element) => element != null && element.isNotEmpty).join(', ');
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _createPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'YouTube Post Creating:\nLink: "${_youtubeLinkController.text}"\nTitle: "${_postTitleController.text}"\nDescription: "${_postDescriptionController.text}"\nLocation: "${_postLocationController.text}"\nOutside Visibility: $_allowOutsideVisibility',
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
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Theme.of(context).colorScheme.onSurfaceVariant) : null,
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.w)),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        ),
        style: GoogleFonts.lato(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Post', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
            // YouTube Link Input
            SizedBox(
              width: double.infinity,
              child: _buildTextField(
                controller: _youtubeLinkController,
                hintText: 'Paste YouTube video link...',
                prefixIcon: Icons.link,
              ),
            ),
            SizedBox(height: 16.h),
            // YouTube Player or Placeholder
            SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), width: 2.w),
                  ),
                  child: _youtubePlayerController != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: YoutubePlayer(
                      controller: _youtubePlayerController!,

                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Theme.of(context).colorScheme.primary,
                      progressColors: ProgressBarColors(
                        playedColor: Theme.of(context).colorScheme.primary,
                        handleColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.ondemand_video, size: 60.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      SizedBox(height: 12.h),
                      Text('Awaiting YouTube Link', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            // Title Input
            SizedBox(
              width: double.infinity,
              child: _buildTextField(
                controller: _postTitleController,
                hintText: 'Add a title...',
                prefixIcon: Icons.title,
              ),
            ),
            // Description Input
            SizedBox(
              width: double.infinity,
              child: _buildTextField(
                controller: _postDescriptionController,
                hintText: 'Write a description...',
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
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
              value:'',
              onTap: () => {},
            ),
            // Location Input
            SizedBox(
              width: double.infinity,
              child: _buildTextField(
                controller: _postLocationController,
                hintText: 'Add your location (optional)',
                prefixIcon: Icons.location_on_outlined,
                readOnly: true,
                suffixIcon: _isGettingLocation
                    ? Padding(
                  padding: EdgeInsets.all(12.w),
                  child: SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
                )
                    : IconButton(icon: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary), onPressed: _getCurrentLocation),
              ),
            ),
            SizedBox(height: 16.h),
            // Outside Visibility Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Allow outside organization visibility',
                  style: GoogleFonts.lato(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
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
          onPressed: _currentVideoId != null ? _createPost : null,
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
              prefixIcon: Icon(prefixIcon,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              suffixIcon: const Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.5))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.5))),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2.w)),
              filled: true,
              fillColor:
              Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              contentPadding:
              EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
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