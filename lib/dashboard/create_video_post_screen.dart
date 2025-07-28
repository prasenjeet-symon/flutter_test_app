import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Used for picking video as well
import 'dart:io'; // Required for File
import 'package:geolocator/geolocator.dart'; // Import for geolocation
import 'package:geocoding/geocoding.dart'; // Import for geocoding
import 'package:video_player/video_player.dart'; // New import for video playback

class CreateVideoPostScreen extends StatefulWidget {
  const CreateVideoPostScreen({Key? key}) : super(key: key);

  @override
  State<CreateVideoPostScreen> createState() => _CreateVideoPostScreenState();
}

class _CreateVideoPostScreenState extends State<CreateVideoPostScreen> {
  XFile? _pickedVideo;
  VideoPlayerController? _videoPlayerController; // Video player controller
  bool _isPlaying = false; // To manage play/pause state

  final TextEditingController _videoCaptionController = TextEditingController();
  final TextEditingController _videoTopicController = TextEditingController();
  final TextEditingController _videoOrgController = TextEditingController();
  final TextEditingController _videoLocationController = TextEditingController();

  bool _isGettingLocation = false; // To show loading state for location

  @override
  void dispose() {
    _videoPlayerController?.dispose(); // Dispose video controller
    _videoCaptionController.dispose();
    _videoTopicController.dispose();
    _videoOrgController.dispose();
    _videoLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    // Using pickVideo for video selection
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _pickedVideo = video;
      });
      _initializeVideoPlayer(); // Initialize player after picking
    }
  }

  Future<void> _initializeVideoPlayer() async {
    if (_pickedVideo != null) {
      // Dispose previous controller if any before creating a new one
      _videoPlayerController?.dispose();
      _videoPlayerController = VideoPlayerController.file(File(_pickedVideo!.path))
        ..initialize()
            .then((_) {
              setState(() {
                _isPlaying = false; // Video loaded, but not playing initially
              });
              // Add a listener to handle video playback completion
              _videoPlayerController!.addListener(_videoPlayerListener);
            })
            .catchError((error) {
              // Handle potential errors during video initialization
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error initializing video: ${error.toString()}')));
              setState(() {
                _pickedVideo = null; // Clear picked video on error
                _videoPlayerController = null;
              });
            });
    }
  }

  void _videoPlayerListener() {
    // Check if video has ended and reset if it was playing
    if (_videoPlayerController!.value.position == _videoPlayerController!.value.duration && _isPlaying) {
      setState(() {
        _isPlaying = false;
        _videoPlayerController!.seekTo(Duration.zero); // Rewind to start
      });
    }
  }

  void _toggleVideoPlayback() {
    // Ensure controller is initialized before attempting playback
    if (_videoPlayerController == null || !_videoPlayerController!.value.isInitialized) return;

    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _videoPlayerController!.play();
      } else {
        _videoPlayerController!.pause();
      }
    });
  }

  void _clearVideoSelection() {
    setState(() {
      _pickedVideo = null;
      _videoPlayerController?.dispose(); // Dispose controller when cleared
      _videoPlayerController = null; // Nullify the controller
      _isPlaying = false; // Reset play state
      _videoCaptionController.clear();
      _videoTopicController.clear();
      _videoOrgController.clear();
      _videoLocationController.clear();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _videoLocationController.text = 'Getting location...'; // Provide feedback
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isGettingLocation = false;
        _videoLocationController.text = 'Location services are disabled.';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled. Please enable them to get your location.')));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could show a dialog for explanation
        setState(() {
          _isGettingLocation = false;
          _videoLocationController.text = 'Location permissions denied.';
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      setState(() {
        _isGettingLocation = false;
        _videoLocationController.text = 'Location permissions are permanently denied.';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied. Please enable from app settings.')));
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Construct a readable address string from available details
        String address = [place.name, place.street, place.subLocality, place.locality, place.administrativeArea, place.postalCode, place.country].where((element) => element != null && element.isNotEmpty).join(', ');
        setState(() {
          _videoLocationController.text = address;
        });
      } else {
        setState(() {
          _videoLocationController.text = 'Location found: Lat: ${position.latitude}, Lon: ${position.longitude}';
        });
      }
    } catch (e) {
      setState(() {
        _videoLocationController.text = 'Could not get location.';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting location: ${e.toString()}')));
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _createPost() {
    // This is where you'd handle the video post creation logic
    // e.g., upload _pickedVideo, send text data to backend.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Video Post Creating:\nVideo: ${_pickedVideo != null ? "Selected" : "None"}\nDescription: "${_videoCaptionController.text}"\nTopic: "${_videoTopicController.text}"\nOrg: "${_videoOrgController.text}"\nLocation: "${_videoLocationController.text}"',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    // In a real app, you would send this data to a backend or save it.
    // Navigator.pop(context); // Example: Close the screen after posting
  }

  // Reusing the _buildTextField helper for consistent styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    Widget? suffixIcon, // Added suffixIcon parameter
    bool readOnly = false, // Added readOnly parameter
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly, // Set readOnly
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Theme.of(context).colorScheme.onSurfaceVariant) : null,
          suffixIcon: suffixIcon, // Use suffixIcon
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
        title: Text('Create Video Post', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centers children horizontally
          children: [
            // Video Picker Container (Dynamic width, maintains original aspect ratio)
            SizedBox(
              width: double.infinity, // Take full available width
              child: GestureDetector(
                onTap: _pickedVideo == null ? _pickVideo : _toggleVideoPlayback, // Tap to pick or play/pause
                child: Container(
                  // No fixed AspectRatio here, it's inside for the video
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), width: 2.w),
                  ),
                  child:
                      _pickedVideo == null
                          ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.video_collection_outlined, size: 60.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                              SizedBox(height: 12.h),
                              Text('Tap to Add Video', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          )
                          : Stack(
                            children: [
                              _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                                  ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: AspectRatio(
                                      aspectRatio: _videoPlayerController!.value.aspectRatio, // Use video's original aspect ratio
                                      child: VideoPlayer(_videoPlayerController!),
                                    ),
                                  )
                                  : const Center(child: CircularProgressIndicator()), // Show loading while video initializes
                              Center(
                                child: IconButton(
                                  icon: Icon(
                                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                    size: 70.sp,
                                    color: Colors.white70, // Make controls visible on video
                                  ),
                                  onPressed: _toggleVideoPlayback,
                                ),
                              ),
                              Positioned(
                                top: 8.h,
                                right: 8.w,
                                child: GestureDetector(
                                  onTap: _clearVideoSelection,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black54, // Dark background for contrast
                                      shape: BoxShape.circle,
                                    ),
                                    padding: EdgeInsets.all(6.w), // Larger tap target
                                    child: Icon(
                                      Icons.close, // Cross icon for deleting selection
                                      color: Colors.white,
                                      size: 20.sp,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                ),
              ),
            ),
            SizedBox(height: 32.h), // Space after video container
            // Description Input (takes full width, centered by Column)
            SizedBox(
              width: double.infinity,
              child: _buildTextField(
                controller: _videoCaptionController,
                hintText: 'Write a description...',
                maxLines: 5, // Allows multiple lines for description
                keyboardType: TextInputType.multiline,
              ),
            ),
            // Organization Input (takes full width, centered by Column)
            SizedBox(width: double.infinity, child: _buildTextField(controller: _videoOrgController, hintText: 'Add an organization (optional)', prefixIcon: Icons.business_center_outlined)),
            // Topic Input (takes full width, centered by Column)
            SizedBox(width: double.infinity, child: _buildTextField(controller: _videoTopicController, hintText: 'Add a topic (e.g., #Vlog)', prefixIcon: Icons.tag)),
            // Location Input Below Topic Selection
            SizedBox(
              width: double.infinity,
              child: _buildTextField(
                controller: _videoLocationController,
                hintText: 'Add your location (optional)',
                prefixIcon: Icons.location_on_outlined,
                readOnly: true, // Make text field read-only as it's filled by detection
                suffixIcon:
                    _isGettingLocation
                        ? Padding(
                          padding: EdgeInsets.all(12.w), // Adjust padding for CircularProgressIndicator
                          child: SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
                        )
                        : IconButton(icon: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary), onPressed: _getCurrentLocation),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 16.h, // Padding for safe area + general bottom padding
          top: 16.h,
          left: 16.w,
          right: 16.w,
        ),
        color: Theme.of(context).colorScheme.surface, // Background color for the bottom bar
        child: FilledButton(
          onPressed: _createPost, // Calls the post creation logic
          style: FilledButton.styleFrom(
            minimumSize: Size(double.infinity, 48.h), // Slightly reduced height for compactness
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r), // Rounded corners for the button
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h), // Slightly reduced vertical padding
            textStyle: GoogleFonts.lato(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          child: const Text('Share'), // Changed button text to "Share"
        ),
      ),
    );
  }
}
