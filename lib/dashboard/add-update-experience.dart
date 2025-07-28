import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For generating random Picsum IDs

// Experience Model
class Experience {
  final String title;
  final String company;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final String imageUrl; // For company logo/image

  Experience({required this.title, required this.company, required this.description, required this.startDate, this.endDate, required this.imageUrl});

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      title: json['title'] as String,
      company: json['company'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'company': company, 'description': description, 'startDate': startDate.toIso8601String(), 'endDate': endDate?.toIso8601String(), 'imageUrl': imageUrl};
  }

  Experience copyWith({String? title, String? company, String? description, DateTime? startDate, DateTime? endDate, String? imageUrl}) {
    return Experience(title: title ?? this.title, company: company ?? this.company, description: description ?? this.description, startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate, imageUrl: imageUrl ?? this.imageUrl);
  }
}

class ExperienceScreen extends StatefulWidget {
  final String? existingExperience;
  final bool isEdit;

  const ExperienceScreen({Key? key, this.existingExperience, this.isEdit = false}) : super(key: key);

  @override
  _ExperienceScreenState createState() => _ExperienceScreenState();
}

class _ExperienceScreenState extends State<ExperienceScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Experience> _experienceEntries = [];
  String? _cardInDeleteMode; // Stores the title of the card currently in delete mode
  DateTime? _startDate;
  DateTime? _endDate;
  final Random _random = Random(); // For generating random Picsum IDs

  @override
  void initState() {
    super.initState();
    _loadExperienceData();
  }

  // Helper to generate a random Picsum image URL for company logos
  String _generatePicsumUrl() {
    final int imageId = _random.nextInt(1000); // Random ID between 0 and 999
    return 'https://picsum.photos/id/$imageId/200/112'; // 200 width, 112 height for 16:9 aspect
  }

  void _loadExperienceData() {
    if (widget.isEdit && widget.existingExperience != null) {
      try {
        final List<dynamic> decoded = jsonDecode(widget.existingExperience!);
        _experienceEntries = decoded.map((e) => Experience.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _experienceEntries = [];
        print('Error decoding existing experience: $e');
      }
    } else {
      // Dummy data for demonstration
      _experienceEntries = [
        Experience(
          title: 'Senior Software Engineer',
          company: 'Tech Solutions Inc.',
          description: 'Led a team of 5 in developing scalable web applications using Flutter and Node.js. Improved system performance by 30%.',
          startDate: DateTime(2022, 1),
          endDate: null, // Current job
          imageUrl: _generatePicsumUrl(),
        ),
        Experience(
          title: 'Software Developer',
          company: 'Innovate Co.',
          description: 'Developed and maintained mobile applications for various clients. Implemented new features and optimized existing codebase.',
          startDate: DateTime(2019, 6),
          endDate: DateTime(2021, 12),
          imageUrl: _generatePicsumUrl(),
        ),
        Experience(
          title: 'Junior Developer Intern',
          company: 'Startup Hub',
          description: 'Assisted senior developers with front-end development and bug fixing. Gained hands-on experience with Agile methodologies.',
          startDate: DateTime(2018, 5),
          endDate: DateTime(2018, 8),
          imageUrl: _generatePicsumUrl(),
        ),
      ];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _toggleDeleteOverlay(String title) {
    setState(() {
      _cardInDeleteMode = (_cardInDeleteMode == title) ? null : title;
    });
  }

  void _deleteEntry(String title) {
    setState(() {
      _experienceEntries.removeWhere((entry) => entry.title == title);
      _cardInDeleteMode = null; // Exit delete mode after deletion
    });
  }

  void _showAddExperienceBottomSheet() {
    _titleController.clear();
    _companyController.clear();
    _descriptionController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _startDate = null;
    _endDate = null;

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
                    Text('Add Experience', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text('Enter details for a new work experience entry.', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'Job Title', helperText: 'e.g., Software Engineer, Project Manager', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a job title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _companyController,
                      decoration: InputDecoration(labelText: 'Company', helperText: 'e.g., Google, Microsoft', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a company name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Job Description', helperText: 'e.g., Developed, managed, led team...', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a job description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _startDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Date',
                        helperText: 'Select start date',
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        suffixIcon: Icon(Icons.calendar_today, size: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (_startDate == null) {
                          return 'Please select a start date';
                        }
                        return null;
                      },
                      onTap: () async {
                        final pickedDate = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100));
                        if (pickedDate != null) {
                          setState(() {
                            _startDate = pickedDate;
                            _startDateController.text = DateFormat.yMMMd().format(pickedDate);
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _endDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'End Date (Optional)',
                        helperText: 'Select end date or leave empty for current',
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        suffixIcon: Icon(Icons.calendar_today, size: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      onTap: () async {
                        final pickedDate = await showDatePicker(context: context, initialDate: _endDate ?? _startDate ?? DateTime.now(), firstDate: _startDate ?? DateTime(1950), lastDate: DateTime(2100));
                        if (pickedDate != null) {
                          setState(() {
                            _endDate = pickedDate;
                            _endDateController.text = DateFormat.yMMMd().format(pickedDate);
                          });
                        }
                      },
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _clearBottomSheetFields();
                          },
                          child: Text('Cancel', style: Theme.of(context).textTheme.labelMedium),
                        ),
                        SizedBox(width: 16.w),
                        FilledButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final newTitle = _titleController.text.trim();
                              final newExperience = Experience(
                                title: newTitle,
                                company: _companyController.text.trim(),
                                description: _descriptionController.text.trim(),
                                startDate: _startDate!,
                                endDate: _endDate,
                                imageUrl: _generatePicsumUrl(), // Generate Picsum for new entries
                              );
                              setState(() {
                                _experienceEntries.add(newExperience);
                              });
                              Navigator.of(context).pop();
                              _clearBottomSheetFields();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: Icon(Icons.add, size: 18.sp, color: Theme.of(context).colorScheme.onPrimary),
                          label: Text('Add Experience', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
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

  void _clearBottomSheetFields() {
    _titleController.clear();
    _companyController.clear();
    _descriptionController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _startDate = null;
    _endDate = null;
  }

  void _saveExperience() {
    final experienceJson = jsonEncode(_experienceEntries.map((entry) => entry.toJson()).toList());
    Navigator.of(context).pop(experienceJson);
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
            onPressed: _saveExperience, // Back button always saves and pops
          ),
          title: Text(widget.isEdit ? 'Edit Experience' : 'Experience', style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          actions: [IconButton(icon: Icon(Icons.add, size: 24.sp, color: Theme.of(context).colorScheme.onSurface), onPressed: _showAddExperienceBottomSheet)],
        ),
      ),
      body:
          _experienceEntries.isEmpty
              ? const EmptyExperienceWidget()
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                        _experienceEntries.map((entry) {
                          final String title = entry.title;
                          final bool isCardSelectedForDelete = _cardInDeleteMode == title;

                          return GestureDetector(
                            onTap: () => _toggleDeleteOverlay(title), // Tap to toggle delete overlay
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
                              // Uses theme's CardTheme elevation and shape
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                              child: Stack(
                                children: [
                                  Container(
                                    // Main content of the card
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer, // Slightly darker background
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${DateFormat.yMMM().format(entry.startDate)} - ${entry.endDate != null ? DateFormat.yMMM().format(entry.endDate!) : 'Present'}',
                                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(entry.company, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                                                  SizedBox(height: 4.h),
                                                  Text(entry.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 16.w),
                                            Expanded(
                                              flex: 1,
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12.r),
                                                child: AspectRatio(
                                                  aspectRatio: 16 / 9,
                                                  child:
                                                      (entry.imageUrl.isNotEmpty)
                                                          ? Image.network(
                                                            entry.imageUrl,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error, stackTrace) => Container(
                                                                  color: Theme.of(context).colorScheme.surfaceVariant,
                                                                  child: Icon(
                                                                    Icons.business, // Changed icon for experience
                                                                    size: 32.sp,
                                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                                  ),
                                                                ),
                                                          )
                                                          : Container(
                                                            color: Theme.of(context).colorScheme.surfaceVariant,
                                                            child: Icon(
                                                              Icons.business, // Changed icon for experience
                                                              size: 32.sp,
                                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                            ),
                                                          ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12.h),
                                        Text(entry.description, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.left),
                                      ],
                                    ),
                                  ),
                                  if (isCardSelectedForDelete)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(16.r)),
                                        child: Center(
                                          child: FloatingActionButton(
                                            heroTag: 'delete_${entry.title}', // Unique tag
                                            onPressed: () => _deleteEntry(title),
                                            backgroundColor: Theme.of(context).colorScheme.error,
                                            mini: true,
                                            child: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.onError),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
    );
  }
}

class EmptyExperienceWidget extends StatelessWidget {
  const EmptyExperienceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 48.h, left: 16.w, right: 16.w, bottom: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.work, // Changed icon for experience
            size: 64.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text('No Experience Entries Yet', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text('Tap the + icon in the top right to add your work experience.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
