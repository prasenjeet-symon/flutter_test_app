import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Model for Ultimate Purpose (could be expanded if needed, but simple for now)
class UltimatePurpose {
  final String category;
  final String subcategory;
  final String description;

  UltimatePurpose({required this.category, required this.subcategory, required this.description});

  // Optional: If you need to load/save this as a single object from JSON string
  factory UltimatePurpose.fromJson(Map<String, dynamic> json) {
    return UltimatePurpose(category: json['category'] as String, subcategory: json['subcategory'] as String, description: json['description'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'category': category, 'subcategory': subcategory, 'description': description};
  }
}

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

  // Using a single UltimatePurpose object instead of a list, as it's a singular "purpose"
  UltimatePurpose? _ultimatePurpose;

  @override
  void initState() {
    super.initState();
    _loadPurposeData();
  }

  void _loadPurposeData() {
    if (widget.isEdit && widget.existingData != null) {
      _categoryController.text = widget.existingData!['category'] ?? '';
      _subcategoryController.text = widget.existingData!['subcategory'] ?? '';
      _descriptionController.text = widget.existingData!['description'] ?? '';
      _ultimatePurpose = UltimatePurpose(category: _categoryController.text, subcategory: _subcategoryController.text, description: _descriptionController.text);
    } else {
      // Dummy data for demonstration if no purpose exists
      _ultimatePurpose = null; // Start with no purpose by default
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subcategoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // No longer directly called by the card button, but from AppBar edit
  void _editPurpose() {
    // Populate controllers for editing
    _categoryController.text = _ultimatePurpose!.category;
    _subcategoryController.text = _ultimatePurpose!.subcategory;
    _descriptionController.text = _ultimatePurpose!.description;
    _showPurposeFormBottomSheet(isEditMode: true);
  }

  void _showPurposeFormBottomSheet({bool isEditMode = false}) {
    if (!isEditMode) {
      _clearFormFields();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: EdgeInsets.only(top: 24.h),
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
            child: Padding(
              padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 16.h, bottom: MediaQuery.of(context).viewInsets.bottom + 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), borderRadius: BorderRadius.circular(2.r)))),
                    SizedBox(height: 16.h),
                    Text(isEditMode ? 'Edit Your Purpose' : 'Add Your Ultimate Purpose', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text('Craft a clear and inspiring purpose to guide your professional journey.', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(labelText: 'Category', helperText: 'e.g., Social Impact, Technology', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
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
                        if (value == null || value.trim().isEmpty) {
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
                        if (value == null || value.trim().isEmpty) {
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
                            _clearFormFields();
                          },
                          child: Text('Cancel', style: Theme.of(context).textTheme.labelMedium),
                        ),
                        SizedBox(width: 16.w),
                        FilledButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _ultimatePurpose = UltimatePurpose(category: _categoryController.text.trim(), subcategory: _subcategoryController.text.trim(), description: _descriptionController.text.trim());
                              });
                              Navigator.of(context).pop();
                              _clearFormFields();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: Icon(isEditMode ? Icons.save : Icons.add, size: 18.sp, color: Theme.of(context).colorScheme.onPrimary),
                          label: Text(isEditMode ? 'Save Purpose' : 'Add Purpose', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _clearFormFields() {
    _categoryController.clear();
    _subcategoryController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          bottom: PreferredSize(preferredSize: Size.fromHeight(1.h), child: Container(color: Theme.of(context).colorScheme.outline, height: 1.h)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 24.sp, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              // On back, if purpose exists, save it to return
              if (_ultimatePurpose != null) {
                Navigator.of(context).pop(_ultimatePurpose!.toJson());
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(widget.isEdit ? 'Edit Ultimate Purpose' : 'Ultimate Purpose', style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          actions: [
            if (_ultimatePurpose == null) // Only show add if no purpose exists
              IconButton(icon: Icon(Icons.add, size: 24.sp, color: Theme.of(context).colorScheme.onSurface), onPressed: () => _showPurposeFormBottomSheet(isEditMode: false))
            else // Show edit if purpose exists
              IconButton(icon: Icon(Icons.edit, size: 24.sp, color: Theme.of(context).colorScheme.onSurface), onPressed: _editPurpose),
          ],
        ),
      ),
      body:
          _ultimatePurpose == null
              ? const EmptyUltimatePurposeWidget()
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(16.r)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.emoji_objects_outlined, // Icon representing purpose/idea
                                size: 28.sp,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  _ultimatePurpose!.description, // Description now here
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h), // Space before labels at the bottom
                          Align(
                            alignment: Alignment.bottomRight, // Align labels to bottom right
                            child: Wrap(
                              spacing: 8.w, // Horizontal spacing between labels
                              runSpacing: 8.h, // Vertical spacing if they wrap
                              crossAxisAlignment: WrapCrossAlignment.end,
                              children: [
                                // Category Label
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.15), // Primary color with opacity
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(_ultimatePurpose!.category, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                                ),
                                // Subcategory Label
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.15), // Tertiary color with opacity
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(_ultimatePurpose!.subcategory, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.tertiary)),
                                ),
                              ],
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

class EmptyUltimatePurposeWidget extends StatelessWidget {
  const EmptyUltimatePurposeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 48.h, left: 16.w, right: 16.w, bottom: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb, // Icon for ultimate purpose
            size: 64.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text('Define Your Ultimate Purpose', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text('Tap the + icon in the top right to articulate your overarching goal and guide your journey.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
