import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReserveFounderScreen extends StatefulWidget {
  const ReserveFounderScreen({super.key});

  @override
  _ReserveFounderScreenState createState() => _ReserveFounderScreenState();
}

class _ReserveFounderScreenState extends State<ReserveFounderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedGender;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _dobController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), firstDate: DateTime(1900), lastDate: DateTime.now());
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Process the form data
      Navigator.pushNamed(context, '/next_screen');
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface, size: 24.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Reserve Founder', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, fontSize: 20.sp)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reserve a Founder Position', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 28.sp), textAlign: TextAlign.left),
                  SizedBox(height: 16.h),
                  Text(
                    'Enter the details to reserve a founder position for someone new. Full name and gender are required.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16.sp, height: 1.5),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 32.h),
                  // Full Name
                  TextFormField(
                    controller: _fullNameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter full name',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 16.sp),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                    ),
                    style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a full name';
                      }
                      if (value.length < 2) {
                        return 'Name must be at least 2 characters long';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Gender
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(
                      labelText: 'Gender *',
                      hintText: 'Select gender',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 16.sp),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                    ),
                    style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                    items:
                        _genders.map((gender) {
                          return DropdownMenuItem(value: gender, child: Text(gender));
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a gender';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Date of Birth
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Date of Birth',
                      hintText: 'Select date of birth',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 16.sp),
                      suffixIcon: Icon(Icons.calendar_today_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 24.sp),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                    ),
                    style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      // Optional field, no validation required
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Mobile Number
                  TextFormField(
                    controller: _mobileController,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number',
                      hintText: 'Enter mobile number',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 16.sp),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                    ),
                    style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null; // Optional field
                      }
                      if (!RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(value)) {
                        return 'Please enter a valid mobile number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  // Email
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter email address',
                      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 16.sp),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                      contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                    ),
                    style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return null; // Optional field
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 32.h),
                  // Reserve Founder Button
                  SizedBox(
                    height: 58.h,
                    child: OutlinedButton(
                      onPressed: _submitForm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.w),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_forward_rounded, size: 24.sp, color: Theme.of(context).colorScheme.primary),
                          SizedBox(width: 8.w),
                          Text('Reserve Founder', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
