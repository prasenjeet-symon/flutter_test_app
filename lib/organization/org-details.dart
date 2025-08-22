import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class OrganizationDetailsScreen extends StatefulWidget {
  const OrganizationDetailsScreen({super.key});

  @override
  _OrganizationDetailsScreenState createState() => _OrganizationDetailsScreenState();
}

class _OrganizationDetailsScreenState extends State<OrganizationDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _orgNameController = TextEditingController();
  final TextEditingController _shortNameController = TextEditingController();
  final TextEditingController _orgIdController = TextEditingController();

  String? _selectedType;
  String? _selectedSize;
  XFile? _orgLogo;

  final List<String> _orgTypes = ['Technology', 'Healthcare', 'Finance', 'Education', 'Retail', 'Non-Profit', 'Manufacturing', 'Hospitality', 'Government'];
  final List<String> _orgSizes = ['1-10', '11-50', '51-200', '201-500', '501-1000', '1000+'];

  @override
  void dispose() {
    _orgNameController.dispose();
    _shortNameController.dispose();
    _orgIdController.dispose();
    super.dispose();
  }

  // Updated function to pick an image using image_picker
  Future<void> _selectLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _orgLogo = image;
      });
    }
  }

  Future<void> _showSearchableBottomSheet({required BuildContext context, required String title, required List<String> items, required Function(String) onSelect}) async {
    final selectedItem = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _SearchableBottomSheet(title: title, items: items);
      },
    );

    if (selectedItem != null) {
      onSelect(selectedItem);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      print('Organization Name: ${_orgNameController.text}');
      print('Short Name: ${_shortNameController.text}');
      print('Organization ID: ${_orgIdController.text}');
      print('Selected Type: $_selectedType');
      print('Selected Size: $_selectedSize');
      print('Logo Path: ${_orgLogo?.path ?? "No logo selected"}');

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Organization created successfully!')));
    }
  }

  Widget _buildTextField({required TextEditingController controller, required String hintText, String? labelText, int maxLines = 1, TextInputType keyboardType = TextInputType.text, IconData? prefixIcon, Widget? suffixIcon, bool readOnly = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          hintStyle: GoogleFonts.lato(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 16.sp),
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
        validator: (value) {
          if (labelText?.contains('*') == true && (value == null || value.isEmpty)) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  // The fix: Using GestureDetector for reliable tapping
  Widget _buildSelectableField({required String label, String? value, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        // Prevents TextFormField from receiving taps
        child: _buildTextField(controller: TextEditingController(text: value), labelText: label, hintText: 'Select $label', readOnly: true, suffixIcon: const Icon(Icons.arrow_drop_down)),
      ),
    );
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
        title: Text('Create Organization', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, fontSize: 20.sp)),
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
                  Center(
                    child: GestureDetector(
                      onTap: _selectLogo,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60.r,
                            backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                            // Updated to use FileImage for XFile
                            backgroundImage: _orgLogo != null ? FileImage(File(_orgLogo!.path)) : null,
                            child: _orgLogo == null ? Icon(Icons.camera_alt_rounded, size: 40.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)) : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(6.w),
                              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                              child: Icon(Icons.edit_rounded, size: 20.sp, color: Theme.of(context).colorScheme.onPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Center(
                    child: Column(
                      children: [
                        Text('Organization Details', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 24.sp), textAlign: TextAlign.center),
                        SizedBox(height: 16.h),
                        Text(
                          'Enter the details to set up your new organization.',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16.sp, height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                  _buildTextField(controller: _orgNameController, labelText: 'Organization Name *', hintText: 'e.g., Aakash Software'),
                  _buildTextField(controller: _shortNameController, labelText: 'Short Name', hintText: 'e.g., AAK'),
                  _buildTextField(controller: _orgIdController, labelText: 'Organization ID', hintText: 'e.g., aakash_soft'),
                  _buildSelectableField(
                    label: 'Type *',
                    value: _selectedType,
                    onTap: () {
                      _showSearchableBottomSheet(
                        context: context,
                        title: 'Select Organization Type',
                        items: _orgTypes,
                        onSelect: (selected) {
                          setState(() {
                            _selectedType = selected;
                          });
                        },
                      );
                    },
                  ),
                  _buildSelectableField(
                    label: 'Size *',
                    value: _selectedSize,
                    onTap: () {
                      _showSearchableBottomSheet(
                        context: context,
                        title: 'Select Organization Size',
                        items: _orgSizes,
                        onSelect: (selected) {
                          setState(() {
                            _selectedSize = selected;
                          });
                        },
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, padding: EdgeInsets.symmetric(vertical: 16.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                      child: Text('Create Now', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
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

class _SearchableBottomSheet extends StatefulWidget {
  final String title;
  final List<String> items;

  const _SearchableBottomSheet({required this.title, required this.items});

  @override
  __SearchableBottomSheetState createState() => __SearchableBottomSheetState();
}

class __SearchableBottomSheetState extends State<_SearchableBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items.where((item) => item.toLowerCase().contains(query)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.only(topLeft: Radius.circular(24.r), topRight: Radius.circular(24.r))),
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(16.w), child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, size: 24.sp),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
