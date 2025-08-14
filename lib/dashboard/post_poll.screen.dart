import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class CreatePollScreen extends StatefulWidget {
  const CreatePollScreen({Key? key}) : super(key: key);

  @override
  State<CreatePollScreen> createState() => _CreatePollScreenState();
}

class _CreatePollScreenState extends State<CreatePollScreen> {
  final TextEditingController _pollTitleController = TextEditingController();
  final TextEditingController _pollDescriptionController = TextEditingController();
  final TextEditingController _pollOrgController = TextEditingController();
  final TextEditingController _pollTopicController = TextEditingController();
  final TextEditingController _pollLocationController = TextEditingController();

  bool _isGettingLocation = false;
  bool _isMultiSelect = false;
  bool _isVisible = false;

  List<Map<String, dynamic>> pollOptions = [];
  Map<String, TextEditingController> optionControllers = {};

  @override
  void initState() {
    super.initState();
    _addOption();
    _addOption();
  }

  void _addOption() {
    final id = const Uuid().v4();
    pollOptions.add({'id': id, 'title': '', 'response_count': null, 'icon': null});
    optionControllers[id] = TextEditingController();
    setState(() {});
  }

  void _removeOption(int index) {
    if (pollOptions.length > 2) {
      final id = pollOptions[index]['id'];
      optionControllers[id]?.dispose();
      optionControllers.remove(id);
      pollOptions.removeAt(index);
      setState(() {});
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
      _pollLocationController.text = 'Getting location...';
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _isGettingLocation = false;
        _pollLocationController.text = 'Location services are disabled.';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled. Please enable them to get your location.')));
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _isGettingLocation = false;
          _pollLocationController.text = 'Location permissions denied.';
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied.')));
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isGettingLocation = false;
        _pollLocationController.text = 'Location permissions are permanently denied.';
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied. Please enable from app settings.')));
      return;
    }
    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = [
          place.name, place.street, place.subLocality, place.locality,
          place.administrativeArea, place.postalCode, place.country
        ].where((element) => element != null && element.isNotEmpty).join(', ');
        setState(() {
          _pollLocationController.text = address;
        });
      } else {
        setState(() {
          _pollLocationController.text = 'Location found: Lat: ${position.latitude}, Lon: ${position.longitude}';
        });
      }
    } catch (e) {
      setState(() {
        _pollLocationController.text = 'Could not get location.';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting location: ${e.toString()}')));
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  void _clearPollFields() {
    _pollTitleController.clear();
    _pollDescriptionController.clear();
    _pollOrgController.clear();
    _pollTopicController.clear();
    _pollLocationController.clear();
    pollOptions.clear();
    for (final c in optionControllers.values) {
      c.dispose();
    }
    optionControllers.clear();
    _addOption();
    _addOption();
    setState(() {});
  }

  void _createPoll() {
    if (_pollTitleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
      return;
    }
    if (pollOptions.any((o) => optionControllers[o['id']]!.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All options must have text')));
      return;
    }
    final payload = {
      'title': _pollTitleController.text.trim(),
      'description': _pollDescriptionController.text.trim().isEmpty ? null : _pollDescriptionController.text.trim(),
      'polls': pollOptions.map((o) => {
        'id': o['id'],
        'title': optionControllers[o['id']]!.text.trim(),
        'response_count': o['response_count'],
        'icon': o['icon'],
      }).toList(),
      'is_multi_select': _isMultiSelect,
      'organization': _pollOrgController.text.trim().isEmpty ? null : _pollOrgController.text.trim(),
      'topic': _pollTopicController.text.trim().isEmpty ? null : _pollTopicController.text.trim(),
      'location': _pollLocationController.text.trim().isEmpty ? null : _pollLocationController.text.trim(),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Poll Created:\n${payload.toString()}'),
        duration: const Duration(seconds: 3),
      ),
    );
    // Call your controller.createPost("poll", payload) here for real use.
  }

  Widget _buildTextField({
    required TextEditingController? controller,
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

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pollTitleController.dispose();
    _pollDescriptionController.dispose();
    _pollOrgController.dispose();
    _pollTopicController.dispose();
    _pollLocationController.dispose();
    for (final c in optionControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Poll', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _clearPollFields,
            child: Text('Clear', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: double.infinity, child: _buildTextField(controller: _pollTitleController, hintText: 'Enter your poll question')),
            SizedBox(width: double.infinity, child: _buildTextField(controller: _pollDescriptionController, hintText: 'Optional description', maxLines: 5, keyboardType: TextInputType.multiline)),
            _sectionTitle(context, "Poll Options"),
            ...pollOptions.asMap().entries.map(
                  (entry) {
                final index = entry.key;
                final option = entry.value;
                return Row(
                  key: ValueKey(option['id']),
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: optionControllers[option['id']],
                        hintText: 'Option ${index + 1}',
                      ),
                    ),
                    if (pollOptions.length > 2)
                      IconButton(
                        onPressed: () => _removeOption(index),
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                      ),
                  ],
                );
              },
            ),
            SizedBox(height: 8.h),
            Center(
              child: TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add),
                label: const Text("Add Option"),
              ),
            ),

            SizedBox(width: double.infinity, child: _buildTextField(controller: _pollOrgController, hintText: 'Add an organization (optional)', prefixIcon: Icons.business_center_outlined)),
            SizedBox(width: double.infinity, child: _buildTextField(controller: _pollTopicController, hintText: 'Add a topic (e.g., #Technology)', prefixIcon: Icons.tag)),
            SizedBox(
              width: double.infinity,
              child: _buildTextField(
                controller: _pollLocationController,
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
            SwitchListTile(
              value: _isMultiSelect,
              title: Text("Allow multiple selections", style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),),
              onChanged: (val) => setState(() => _isMultiSelect = val),
              contentPadding: EdgeInsets.only(left: 7.w),
            ),
            SwitchListTile(
              value: _isVisible,
              title: Text("Should visible to out side the org", style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),),
              onChanged: (val) => setState(() => _isVisible = val),
              contentPadding: EdgeInsets.only(left: 7.w),
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
          onPressed: _createPoll,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
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
}
