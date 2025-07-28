import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Required for File
import 'package:geolocator/geolocator.dart'; // Import for geolocation
import 'package:geocoding/geocoding.dart'; // Import for geocoding

class CreateImagePostScreen extends StatefulWidget {
  const CreateImagePostScreen({Key? key}) : super(key: key);

  @override
  State<CreateImagePostScreen> createState() => _CreateImagePostScreenState();
}

class _CreateImagePostScreenState extends State<CreateImagePostScreen> {
  XFile? _pickedImage;
  final TextEditingController _imageCaptionController = TextEditingController();
  final TextEditingController _imageTopicController = TextEditingController();
  final TextEditingController _imageOrgController = TextEditingController();
  final TextEditingController _imageLocationController = TextEditingController(); // Controller for location

  bool _isGettingLocation = false; // To show loading state for location

  @override
  void dispose() {
    _imageCaptionController.dispose();
    _imageTopicController.dispose();
    _imageOrgController.dispose();
    _imageLocationController.dispose(); // Dispose location controller
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void _clearImageSelection() {
    setState(() {
      _pickedImage = null;
      _imageCaptionController.clear();
      _imageTopicController.clear();
      _imageOrgController.clear();
      _imageLocationController.clear(); // Clear location as well
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _imageLocationController.text = 'Getting location...'; // Provide feedback
    });

    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users to enable the location services.
      setState(() {
        _isGettingLocation = false;
        _imageLocationController.text = 'Location services are disabled.';
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
          _imageLocationController.text = 'Location permissions denied.';
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      setState(() {
        _isGettingLocation = false;
        _imageLocationController.text = 'Location permissions are permanently denied.';
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
        // Construct a readable address string
        String address = [place.name, place.street, place.subLocality, place.locality, place.administrativeArea, place.postalCode, place.country].where((element) => element != null && element.isNotEmpty).join(', ');
        setState(() {
          _imageLocationController.text = address;
        });
      } else {
        setState(() {
          _imageLocationController.text = 'Location found: Lat: ${position.latitude}, Lon: ${position.longitude}';
        });
      }
    } catch (e) {
      setState(() {
        _imageLocationController.text = 'Could not get location.';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting location: ${e.toString()}')));
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _createPost() {
    // This is where you'd handle the image post creation logic
    // e.g., upload _pickedImage, send text data to backend.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Image Post Creating:\nImage: ${_pickedImage != null ? "Selected" : "None"}\nDescription: "${_imageCaptionController.text}"\nTopic: "${_imageTopicController.text}"\nOrg: "${_imageOrgController.text}"\nLocation: "${_imageLocationController.text}"',
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    // In a real app, you would send this data to a backend or save it.
    // Navigator.pop(context); // Close the screen after posting
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
        title: Text('Create Image Post', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Centers children horizontally
          children: [
            // Image Picker Container (Dynamic width, square aspect ratio, no shadow)
            SizedBox(
              width: double.infinity, // Take full available width
              child: GestureDetector(
                onTap: _pickImage,
                child: AspectRatio(
                  // Maintain a 1:1 aspect ratio (square)
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), width: 2.w),
                    ),
                    child:
                        _pickedImage == null
                            ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 60.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                SizedBox(height: 12.h),
                                Text('Tap to Add Image', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              ],
                            )
                            : Stack(
                              children: [
                                Positioned.fill(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(16.r),
                                    child: Image.file(
                                      File(_pickedImage!.path),
                                      fit: BoxFit.contain, // Maintain original aspect ratio within bounds
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8.h,
                                  right: 8.w,
                                  child: GestureDetector(
                                    onTap: _clearImageSelection,
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
            ),
            SizedBox(height: 32.h), // Space after image container
            // Description Input (takes full width, centered by Column)
            SizedBox(
              width: double.infinity,
              child: _buildTextField(
                controller: _imageCaptionController,
                hintText: 'Write a description...',
                maxLines: 5, // Allows multiple lines for description
                keyboardType: TextInputType.multiline,
              ),
            ),
            // Organization Input (takes full width, centered by Column)
            SizedBox(width: double.infinity, child: _buildTextField(controller: _imageOrgController, hintText: 'Add an organization (optional)', prefixIcon: Icons.business_center_outlined)),
            // Topic Input (takes full width, centered by Column)
            SizedBox(width: double.infinity, child: _buildTextField(controller: _imageTopicController, hintText: 'Add a topic (e.g., #Photography)', prefixIcon: Icons.tag)),
            // --- Location Input Added Below Topic Selection ---
            SizedBox(
              width: double.infinity,
              child: _buildTextField(
                controller: _imageLocationController,
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

            // --- End Location Input ---
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
