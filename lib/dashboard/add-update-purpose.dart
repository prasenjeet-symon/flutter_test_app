import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UltimatePurposeScreen extends StatefulWidget {
  final Map<String, String>? existingData; // For editing existing purpose
  final bool isEdit; // Flag to determine add or edit mode

  const UltimatePurposeScreen({Key? key, this.existingData, this.isEdit = false}) : super(key: key);

  @override
  _UltimatePurposeScreenState createState() => _UltimatePurposeScreenState();
}

class _UltimatePurposeScreenState extends State<UltimatePurposeScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subcategoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingData != null) {
      _categoryController.text = widget.existingData!['category'] ?? '';
      _subcategoryController.text = widget.existingData!['subcategory'] ?? '';
      _descriptionController.text = widget.existingData!['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subcategoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _savePurpose() {
    if (_formKey.currentState!.validate()) {
      // Simulate saving data (e.g., to backend or local state)
      final purposeData = {'category': _categoryController.text, 'subcategory': _subcategoryController.text, 'description': _descriptionController.text};
      // Return data to previous screen
      Navigator.of(context).pop(purposeData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color), onPressed: () => Navigator.of(context).pop()),
        title: Text(widget.isEdit ? 'Edit Ultimate Purpose' : 'Add Ultimate Purpose', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 24.h),
          child: Card(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Define Your Ultimate Purpose', style: Theme.of(context).textTheme.headlineLarge),
                    SizedBox(height: 8.h),
                    Text('Craft a clear and inspiring purpose to guide your professional journey.', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 24.h),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(labelText: 'Category', helperText: 'e.g., Social Impact, Technology', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _subcategoryController,
                      decoration: InputDecoration(labelText: 'Subcategory', helperText: 'e.g., Community Development, AI Innovation', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subcategory';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description', helperText: 'Describe your purpose in detail', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Cancel', style: Theme.of(context).textTheme.bodySmall),
                        ),
                        SizedBox(width: 16.w),
                        ElevatedButton(
                          onPressed: _savePurpose,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary], begin: Alignment.centerLeft, end: Alignment.centerRight),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            child: Text('Save', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
