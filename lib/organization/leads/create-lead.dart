import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateLeadScreen extends StatefulWidget {
  const CreateLeadScreen({super.key});

  @override
  _CreateLeadScreenState createState() => _CreateLeadScreenState();
}

class _CreateLeadScreenState extends State<CreateLeadScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  String _fullName = '';
  String? _gender;
  String _mobileNumber = '';
  String _email = '';
  String _addressLine1 = '';
  String _addressLine2 = '';
  String _city = '';
  String _zipcode = '';
  String _state = '';
  String _country = '';
  DateTime? _selectedDate;
  File? _profileImage;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newLeadData = {
        'fullName': _fullName,
        'gender': _gender,
        'mobileNumber': _mobileNumber,
        'email': _email,
        'dob': _selectedDate?.toIso8601String(),
        'address': {
          'address_line_1': _addressLine1,
          'address_line_2': _addressLine2,
          'city': _city,
          'zipcode': _zipcode,
          'state': _state,
          'country': _country,
        },
        'profilePicPath': _profileImage?.path,
      };

      print('New Lead Created: $newLeadData');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lead created successfully!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Create a New Lead',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSection(),
                SizedBox(height: 24.h),
                _buildPersonalDetailsSection(),
                SizedBox(height: 32.h),
                _buildAddressSection(),
                SizedBox(height: 32.h),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 60.r,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
              child:
                  _profileImage == null
                      ? Icon(
                        Icons.person,
                        size: 70.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.6),
                      )
                      : null,
            ),
          ),
          SizedBox(height: 12.h),
          TextButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.camera_alt, size: 20.sp),
            label: Text(
              _profileImage == null
                  ? 'Add Profile Picture'
                  : 'Change Profile Picture',
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Details',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          label: 'Full Name',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the full name';
            }
            return null;
          },
          onSaved: (value) => _fullName = value!,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          label: 'Mobile Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a mobile number';
            }
            return null;
          },
          onSaved: (value) => _mobileNumber = value!,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
          onSaved: (value) => _email = value!,
        ),
        SizedBox(height: 16.h),
        _buildGenderPicker(),
        SizedBox(height: 16.h),
        _buildDatePicker(),
      ],
    );
  }

  Widget _buildAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address Information',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          label: 'Address Line 1',
          icon: Icons.location_on_outlined,
          onSaved: (value) => _addressLine1 = value!,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          label: 'Address Line 2 (Optional)',
          icon: Icons.location_on_outlined,
          onSaved: (value) => _addressLine2 = value!,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          label: 'City',
          icon: Icons.location_city,
          onSaved: (value) => _city = value!,
        ),
        SizedBox(height: 16.h),
        _buildTextField(
          label: 'State',
          icon: Icons.apartment,
          onSaved: (value) => _state = value!,
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                label: 'Zipcode',
                icon: Icons.local_post_office_outlined,
                keyboardType: TextInputType.number,
                onSaved: (value) => _zipcode = value!,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildTextField(
                label: 'Country',
                icon: Icons.public_outlined,
                onSaved: (value) => _country = value!,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    FormFieldSetter<String>? onSaved,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget _buildGenderPicker() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Gender',
        prefixIcon: const Icon(Icons.transgender),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      value: _gender,
      items:
          ['Male', 'Female', 'Other']
              .map(
                (String gender) => DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender),
                ),
              )
              .toList(),
      onChanged: (String? newValue) {
        setState(() {
          _gender = newValue;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a gender';
        }
        return null;
      },
      onSaved: (value) => _gender = value,
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date of Birth (Optional)',
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
          filled: true,
          fillColor: Theme.of(
            context,
          ).colorScheme.surfaceVariant.withOpacity(0.3),
        ),
        child: Text(
          _selectedDate == null
              ? 'Select date'
              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
          style: GoogleFonts.lato(
            fontSize: 16.sp,
            color:
                _selectedDate == null
                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _submitForm,
        child: Text(
          'Create Lead',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        style: FilledButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}
