import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Model for Mission Statement
class MissionStatement {
  final String statement;
  final String category;
  final String subcategory;

  MissionStatement({required this.statement, required this.category, required this.subcategory});

  factory MissionStatement.fromJson(Map<String, dynamic> json) {
    return MissionStatement(statement: json['statement'] as String, category: json['category'] as String, subcategory: json['subcategory'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'statement': statement, 'category': category, 'subcategory': subcategory};
  }
}

class MissionScreen extends StatefulWidget {
  final Map<String, String>? existingData; // For editing existing mission

  const MissionScreen({Key? key, this.existingData}) : super(key: key);

  @override
  _MissionScreenState createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  final TextEditingController _missionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _subcategoryController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  MissionStatement? _missionStatement;

  @override
  void initState() {
    super.initState();
    _loadMissionData();
  }

  void _loadMissionData() {
    if (widget.existingData != null && widget.existingData!.containsKey('statement')) {
      _missionController.text = widget.existingData!['statement'] ?? '';
      _categoryController.text = widget.existingData!['category'] ?? '';
      _subcategoryController.text = widget.existingData!['subcategory'] ?? '';
      _missionStatement = MissionStatement(statement: _missionController.text, category: _categoryController.text, subcategory: _subcategoryController.text);
    } else {
      _missionStatement = null; // No mission by default
    }
  }

  @override
  void dispose() {
    _missionController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    super.dispose();
  }

  void _showMissionFormBottomSheet({bool isEditMode = false}) {
    if (isEditMode && _missionStatement != null) {
      // Pre-fill controllers with existing data when in edit mode
      _missionController.text = _missionStatement!.statement;
      _categoryController.text = _missionStatement!.category;
      _subcategoryController.text = _missionStatement!.subcategory;
    } else {
      // Clear controllers when adding a new mission
      _missionController.clear();
      _categoryController.clear();
      _subcategoryController.clear();
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
                    Text(isEditMode ? 'Edit Your Mission' : 'Add Your Mission', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text('Define a clear mission to guide your actions and decisions.', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _missionController,
                      decoration: InputDecoration(labelText: 'Mission Statement', helperText: 'e.g., To empower individuals through innovative technology.', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a mission statement';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(labelText: 'Mission Category', helperText: 'e.g., Education, Healthcare, Environment', labelStyle: Theme.of(context).textTheme.labelMedium),
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
                      decoration: InputDecoration(labelText: 'Mission Subcategory', helperText: 'e.g., Online Learning, Disease Prevention, Waste Reduction', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a subcategory';
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
                            // Clearing controllers after dialog closes (important for subsequent adds)
                            _missionController.clear();
                            _categoryController.clear();
                            _subcategoryController.clear();
                          },
                          child: Text('Cancel', style: Theme.of(context).textTheme.labelMedium),
                        ),
                        SizedBox(width: 16.w),
                        FilledButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _missionStatement = MissionStatement(statement: _missionController.text.trim(), category: _categoryController.text.trim(), subcategory: _subcategoryController.text.trim());
                              });
                              Navigator.of(context).pop();
                              // Clear controllers after successful save
                              _missionController.clear();
                              _categoryController.clear();
                              _subcategoryController.clear();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: Icon(isEditMode ? Icons.save : Icons.add, size: 18.sp, color: Theme.of(context).colorScheme.onPrimary),
                          label: Text(isEditMode ? 'Save Mission' : 'Add Mission', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
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
              // On back, if mission exists, save it to return
              if (_missionStatement != null) {
                Navigator.of(context).pop(_missionStatement!.toJson());
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text('Mission Statement', style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          actions: [
            if (_missionStatement == null)
              IconButton(icon: Icon(Icons.add, size: 24.sp, color: Theme.of(context).colorScheme.onSurface), onPressed: () => _showMissionFormBottomSheet(isEditMode: false))
            else
              IconButton(icon: Icon(Icons.edit, size: 24.sp, color: Theme.of(context).colorScheme.onSurface), onPressed: () => _showMissionFormBottomSheet(isEditMode: true)),
          ],
        ),
      ),
      body:
          _missionStatement == null
              ? const EmptyMissionWidget()
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
                                Icons.flag_outlined, // Icon representing a mission
                                size: 28.sp,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(child: Text(_missionStatement!.statement, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface))),
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
                                  child: Text(_missionStatement!.category, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                                ),
                                // Subcategory Label
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.tertiary.withOpacity(0.15), // Tertiary color with opacity
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(_missionStatement!.subcategory, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.tertiary)),
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

class EmptyMissionWidget extends StatelessWidget {
  const EmptyMissionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 48.h, left: 16.w, right: 16.w, bottom: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.flag, // Icon for empty state mission
            size: 64.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text('Define Your Mission', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text('Tap the + icon in the top right to articulate your guiding mission statement, category, and subcategory.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
