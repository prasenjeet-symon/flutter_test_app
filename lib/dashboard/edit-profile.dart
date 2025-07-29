import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; // Keep this for picking images
// import 'package:image_cropper/image_cropper.dart'; // REMOVE THIS LINE if it's there
// import 'image_crop_view_screen.dart'; // REMOVE THIS LINE if it's there
import 'dart:io'; // Required for File

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers for personal information
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  String? _selectedGender; // For dropdown

  // Controllers for address information
  final TextEditingController _addressLine1Controller = TextEditingController();
  final TextEditingController _addressLine2Controller = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  XFile? _profilePicture; // To store the picked profile picture

  // Dummy initial values (replace with actual user data from your backend)
  @override
  void initState() {
    super.initState();
    _fullNameController.text = "John Doe";
    _selectedGender = "Male";
    _dobController.text = "1990-01-15"; // YYYY-MM-DD
    _bioController.text = "Passionate Flutter developer and tech enthusiast.";

    _addressLine1Controller.text = "123, Main Street";
    _addressLine2Controller.text = "Near Central Park";
    _cityController.text = "Patna";
    _pincodeController.text = "800001";
    _stateController.text = "Bihar";
    _landmarkController.text = "Gandhi Maidan";
    _countryController.text = "India";
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _stateController.dispose();
    _landmarkController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  // Function to pick image directly from gallery without cropping
  Future<void> _pickProfilePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profilePicture = image; // Directly assign the picked image
      });
    }
  }

  // Function to show date picker for DOB
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Function to save profile changes
  void _saveProfile() {
    // Here you would typically send data to a backend service
    // For demonstration, we'll just print the collected data
    print('Saving Profile Information:');
    print('Full Name: ${_fullNameController.text}');
    print('Gender: $_selectedGender');
    print('DOB: ${_dobController.text}');
    print('Bio: ${_bioController.text}');
    print('Profile Picture Path: ${_profilePicture?.path ?? "No new picture selected"}');
    print('\nAddress Information:');
    print('Address Line 1: ${_addressLine1Controller.text}');
    print('Address Line 2: ${_addressLine2Controller.text}');
    print('City: ${_cityController.text}');
    print('Pincode: ${_pincodeController.text}');
    print('State: ${_stateController.text}');
    print('Landmark: ${_landmarkController.text}');
    print('Country: ${_countryController.text}');

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully! (Data printed to console)')));
    // You might navigate back after saving: Navigator.pop(context);
  }

  // Reusing the _buildTextField helper for consistent styling
  Widget _buildTextField({required TextEditingController controller, required String hintText, int maxLines = 1, TextInputType keyboardType = TextInputType.text, IconData? prefixIcon, Widget? suffixIcon, bool readOnly = false}) {
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
        title: Text('Edit Profile', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to start
          children: [
            // --- Profile Picture Section ---
            Center(
              child: GestureDetector(
                onTap: _pickProfilePicture,
                child: CircleAvatar(
                  radius: 60.r,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  backgroundImage: _profilePicture != null ? FileImage(File(_profilePicture!.path)) as ImageProvider<Object>? : null, // Use FileImage for XFile
                  child: _profilePicture == null ? Icon(Icons.camera_alt_outlined, size: 40.sp, color: Theme.of(context).colorScheme.onSurfaceVariant) : null,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Center(child: Text('Tap to change profile picture', style: GoogleFonts.lato(fontSize: 14.sp, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500))),
            SizedBox(height: 32.h),

            // --- Personal Information Section ---
            Text('Personal Information', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 16.h),
            _buildTextField(controller: _fullNameController, hintText: 'Full Name', prefixIcon: Icons.person_outline),
            // Gender Dropdown
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: InputDecoration(
                  hintText: 'Gender',
                  prefixIcon: Icon(Icons.transgender, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.w)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                ),
                items: ['Male', 'Female', 'Other', 'Prefer not to say'].map((String gender) => DropdownMenuItem<String>(value: gender, child: Text(gender, style: GoogleFonts.lato(fontSize: 16.sp)))).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
                style: GoogleFonts.lato(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                dropdownColor: Theme.of(context).colorScheme.surface, // Adjust dropdown background
              ),
            ),
            // Date of Birth
            _buildTextField(
              controller: _dobController,
              hintText: 'Date of Birth (YYYY-MM-DD)',
              prefixIcon: Icons.calendar_today_outlined,
              readOnly: true, // Make it read-only as it's set by date picker
              suffixIcon: IconButton(icon: Icon(Icons.edit_calendar, color: Theme.of(context).colorScheme.primary), onPressed: () => _selectDate(context)),
            ),
            _buildTextField(controller: _bioController, hintText: 'Bio (e.g., your interests, profession)', maxLines: 3, keyboardType: TextInputType.multiline, prefixIcon: Icons.info_outline),
            SizedBox(height: 32.h),

            // --- Address Information Section ---
            Text('Address Information', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 16.h),
            _buildTextField(controller: _addressLine1Controller, hintText: 'Address Line 1', prefixIcon: Icons.location_on_outlined),
            _buildTextField(controller: _addressLine2Controller, hintText: 'Address Line 2 (Optional)', prefixIcon: Icons.location_on_outlined),
            _buildTextField(controller: _cityController, hintText: 'City', prefixIcon: Icons.location_city_outlined),
            _buildTextField(controller: _pincodeController, hintText: 'Pincode', keyboardType: TextInputType.number, prefixIcon: Icons.pin_drop_outlined),
            _buildTextField(controller: _stateController, hintText: 'State', prefixIcon: Icons.map_outlined),
            _buildTextField(controller: _landmarkController, hintText: 'Landmark (Optional)', prefixIcon: Icons.signpost_outlined),
            _buildTextField(controller: _countryController, hintText: 'Country', prefixIcon: Icons.public_outlined),
            SizedBox(height: 32.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 16.h, top: 16.h, left: 16.w, right: 16.w),
        color: Theme.of(context).colorScheme.surface,
        child: FilledButton(
          onPressed: _saveProfile,
          style: FilledButton.styleFrom(
            minimumSize: Size(double.infinity, 48.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            textStyle: GoogleFonts.lato(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          child: const Text('Save Profile'),
        ),
      ),
    );
  }
}
