import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({Key? key}) : super(key: key);

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final TextEditingController _eventDescriptionController = TextEditingController();
  final TextEditingController _eventVenueController = TextEditingController();
  final TextEditingController _eventLocationController = TextEditingController();
  final TextEditingController _eventLatitudeController = TextEditingController();
  final TextEditingController _eventLongitudeController = TextEditingController();

  final _scrollController = ScrollController();

  XFile? _eventImage;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  LatLng? _lastKnownLocation;

  bool _isGettingLocation = false;
  bool _allowOutsideVisibility = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(updateFields: false); // Get location on init for map centering
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
    _eventDescriptionController.dispose();
    _eventVenueController.dispose();
    _eventLocationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _eventImage = image;
      });
    }
  }

  void _clearImageSelection() {
    setState(() {
      _eventImage = null;
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _getCurrentLocation({bool updateFields = true}) async {
    if (updateFields) {
      setState(() {
        _isGettingLocation = true;
        _eventLocationController.text = 'Getting location...';
      });
    }

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
      setState(() {
        _lastKnownLocation = LatLng(position.latitude, position.longitude);
      });

      if (updateFields) {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          String address = [
            place.street,
            place.subLocality,
            place.locality,
            place.postalCode,
            place.country
          ].where((element) => element != null && element.isNotEmpty).join(', ');
          setState(() {
            _eventLocationController.text = address;
            _eventLatitudeController.text = position.latitude.toString();
            _eventLongitudeController.text = position.longitude.toString();
          });
        }
      }
    } catch (e) {
      _handleLocationError('Could not get location.');
    } finally {
      if (updateFields) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  void _handleLocationError(String message) {
    if (mounted) {
      setState(() {
        _isGettingLocation = false;
        _eventLocationController.text = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _openLocationPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationPickerSheet(
        initialPosition: _lastKnownLocation ?? const LatLng(16.2949, 80.1328), // Default to Chilakaluripet
      ),
    );

    if (result != null) {
      setState(() {
        _eventVenueController.text = result;
        _eventLocationController.text = result;
      });
    }
  }

  void _createPost() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Event Created:\nImage: ${_eventImage != null ? "Selected" : "None"}\nDescription: "${_eventDescriptionController.text}"\nDate: ${_selectedDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}\nTime: ${_selectedTime?.format(context) ?? 'N/A'}\nLocation: "${_eventLocationController.text}"\nOutside Visibility: $_allowOutsideVisibility',
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
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
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
        title: Text('Create Event', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
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
            // Image Picker
            SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), width: 2.w),
                    ),
                    child: _eventImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 60.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                        SizedBox(height: 12.h),
                        Text('Tap to Add Image', textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    )
                        : Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: Image.file(File(_eventImage!.path), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 8.h,
                          right: 8.w,
                          child: GestureDetector(
                            onTap: _clearImageSelection,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(6.w),
                              child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            _buildTextField(
              controller: _eventDescriptionController,
              hintText: 'Write a description...',
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: TextEditingController(text: _selectedDate != null ? '${_selectedDate!.toLocal()}'.split(' ')[0] : ''),
                    hintText: 'Select date...',
                    prefixIcon: Icons.calendar_today_outlined,
                    readOnly: true,
                    onTap: _selectDate,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _buildTextField(
                    controller: TextEditingController(text: _selectedTime != null ? _selectedTime!.format(context) : ''),
                    hintText: 'Select time...',
                    prefixIcon: Icons.access_time_outlined,
                    readOnly: true,
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
            _buildTextField(
              controller: _eventVenueController,
              hintText: 'Add venue...',
              readOnly: true,
              onTap: _openLocationPicker,
              prefixIcon: Icons.pin_drop_outlined,
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
            _buildTextField(
              controller: _eventLocationController,
              hintText: 'Add location (optional)',
              prefixIcon: Icons.location_on_outlined,
              readOnly: true,
              suffixIcon: _isGettingLocation
                  ? Padding(
                padding: EdgeInsets.all(12.w),
                child: SizedBox(width: 20.w, height: 20.h, child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary)),
              )
                  : IconButton(icon: Icon(Icons.my_location, color: Theme.of(context).colorScheme.primary), onPressed: () => _getCurrentLocation()),
            ),
            SizedBox(height: 16.h),
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
          onPressed:  _selectedDate != null && _selectedTime != null ? _createPost : null,
          style: FilledButton.styleFrom(
            minimumSize: Size(double.infinity, 48.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            textStyle: GoogleFonts.lato(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          child: const Text('Post Event'),
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

// --- NEW WIDGET: LOCATION PICKER BOTTOM SHEET ---
class LocationPickerSheet extends StatefulWidget {
  final LatLng initialPosition;
  const LocationPickerSheet({Key? key, required this.initialPosition}) : super(key: key);

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  GoogleMapController? _mapController;
  late LatLng _selectedPosition;
  Set<Marker> _markers = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedPosition = widget.initialPosition;
    _markers.add(
      Marker(
        markerId: const MarkerId('selected-location'),
        position: _selectedPosition,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _markers = {
        Marker(
          markerId: const MarkerId('selected-location'),
          position: _selectedPosition,
        ),
      };
    });
  }

  Future<void> _selectAndReturnLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _selectedPosition.latitude,
        _selectedPosition.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode,
        ].where((element) => element != null && element.isNotEmpty).join(', ');
        Navigator.pop(context, address);
      } else {
        Navigator.pop(context, 'Lat: ${_selectedPosition.latitude}, Lon: ${_selectedPosition.longitude}');
      }
    } catch (e) {
      Navigator.pop(context, null);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not get address for this location.')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  'Select Venue Location',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: _selectedPosition,
                      zoom: 15.0,
                    ),
                    onTap: _onTap,
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: FilledButton(
                  onPressed: _selectAndReturnLocation,
                  style: FilledButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                  )
                      : const Text('Select this Location'),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
