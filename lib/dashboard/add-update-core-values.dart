import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Model for Core Value - Simplified
class CoreValue {
  String id; // Unique ID for each value, useful for list operations
  String name;

  CoreValue({required this.id, required this.name});

  // Factory constructor for creating a CoreValue from a JSON map
  factory CoreValue.fromJson(Map<String, dynamic> json) {
    return CoreValue(id: json['id'] as String, name: json['name'] as String);
  }

  // Method for converting a CoreValue to a JSON map
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class CoreValuesScreen extends StatefulWidget {
  final List<Map<String, String>>? existingData; // List of existing core values

  const CoreValuesScreen({Key? key, this.existingData}) : super(key: key);

  @override
  _CoreValuesScreenState createState() => _CoreValuesScreenState();
}

class _CoreValuesScreenState extends State<CoreValuesScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Use a List of CoreValue objects
  List<CoreValue> _coreValues = [];

  @override
  void initState() {
    super.initState();
    _loadCoreValuesData();
  }

  void _loadCoreValuesData() {
    if (widget.existingData != null) {
      _coreValues =
          widget.existingData!
              .map(
                (data) => CoreValue.fromJson({
                  'id': data['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(), // Ensure ID exists
                  'name': data['name'] ?? '',
                }),
              )
              .toList();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Modified to only support adding new core values
  void _showAddCoreValueFormBottomSheet() {
    _nameController.clear(); // Always clear for new entry

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
                    Text(
                      'Add New Core Value', // Only "Add New"
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add a new core value that defines you.', // Simplified helper text
                      style: Theme.of(context).textTheme.bodyLarge, // Reverted font size
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Core Value Name', helperText: 'e.g., Integrity, Innovation, Compassion', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a core value name';
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
                            _nameController.clear();
                          },
                          child: Text('Cancel', style: Theme.of(context).textTheme.labelMedium),
                        ),
                        SizedBox(width: 16.w),
                        FilledButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                // Always add a new core value
                                _coreValues.add(
                                  CoreValue(
                                    id: DateTime.now().microsecondsSinceEpoch.toString(), // Simple unique ID
                                    name: _nameController.text.trim(),
                                  ),
                                );
                              });
                              Navigator.of(context).pop();
                              _nameController.clear();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: Icon(
                            Icons.add, // Always "Add" icon
                            size: 18.sp,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          label: Text(
                            'Add Value', // Always "Add Value"
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary),
                          ),
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

  void _confirmDelete(CoreValue coreValue) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Core Value?', style: Theme.of(context).textTheme.titleLarge),
            content: Text('Are you sure you want to delete "${coreValue.name}"?', style: Theme.of(context).textTheme.bodyMedium),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge)),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _coreValues.removeWhere((cv) => cv.id == coreValue.id);
                  });
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                child: Text('Delete', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onError, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
    );
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
              // On back, return the list of core values
              Navigator.of(context).pop(_coreValues.map((cv) => cv.toJson()).toList());
            },
          ),
          title: Text('Core Values', style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add, size: 24.sp, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => _showAddCoreValueFormBottomSheet(), // Call the add-only bottom sheet
            ),
          ],
        ),
      ),
      body:
          _coreValues.isEmpty
              ? const EmptyCoreValuesWidget()
              : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Wrap(
                  spacing: 8.w, // Horizontal space between chips
                  runSpacing: 8.h, // Vertical space between rows of chips
                  children:
                      _coreValues.map((coreValue) {
                        return Chip(
                          avatar: Icon(
                            Icons.favorite_border, // Icon for core value
                            size: 20.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          label: Text(coreValue.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          side: BorderSide.none, // No border for a cleaner look
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                          onDeleted: () => _confirmDelete(coreValue),
                          deleteIconColor: Theme.of(context).colorScheme.error,
                        );
                      }).toList(),
                ),
              ),
    );
  }
}

class EmptyCoreValuesWidget extends StatelessWidget {
  const EmptyCoreValuesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 48.h, left: 16.w, right: 16.w, bottom: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.self_improvement, // A relevant icon for values
            size: 64.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text('Define Your Core Values', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text(
            'What principles guide your life and work? Tap the + icon to add your core values.',
            style: Theme.of(context).textTheme.bodyLarge, // Reverted font size
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
