import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:math'; // For generating random Picsum IDs

// Certification Model (UPDATED: Removed expirationDate and credentialId, credentialUrl)
class Certification {
  final String name;
  final String issuingBody;
  final String? description;
  final DateTime issueDate;
  // final DateTime? expirationDate; // Removed
  // final String? credentialId; // Removed
  final String? credentialUrl; // Kept as optional, but not in UI fields for now
  final String imageUrl; // For certification logo/image

  Certification({
    required this.name,
    required this.issuingBody,
    this.description,
    required this.issueDate,
    // this.expirationDate, // Removed
    // this.credentialId, // Removed
    this.credentialUrl, // Still in constructor for potential future use or if data still contains it
    required this.imageUrl,
  });

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      name: json['name'] as String,
      issuingBody: json['issuingBody'] as String,
      description: json['description'] as String?,
      issueDate: DateTime.parse(json['issueDate'] as String),
      // expirationDate: json['expirationDate'] != null // Removed
      //     ? DateTime.parse(json['expirationDate'] as String)
      //     : null,
      // credentialId: json['credentialId'] as String?, // Removed
      credentialUrl: json['credentialUrl'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'issuingBody': issuingBody,
      'description': description,
      'issueDate': issueDate.toIso8601String(),
      // 'expirationDate': expirationDate?.toIso8601String(), // Removed
      // 'credentialId': credentialId, // Removed
      'credentialUrl': credentialUrl,
      'imageUrl': imageUrl,
    };
  }

  Certification copyWith({
    String? name,
    String? issuingBody,
    String? description,
    DateTime? issueDate,
    // DateTime? expirationDate, // Removed
    // String? credentialId, // Removed
    String? credentialUrl,
    String? imageUrl,
  }) {
    return Certification(
      name: name ?? this.name,
      issuingBody: issuingBody ?? this.issuingBody,
      description: description ?? this.description,
      issueDate: issueDate ?? this.issueDate,
      // expirationDate: expirationDate ?? this.expirationDate, // Removed
      // credentialId: credentialId ?? this.credentialId, // Removed
      credentialUrl: credentialUrl ?? this.credentialUrl,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class CertificationScreen extends StatefulWidget {
  final String? existingCertifications;
  final bool isEdit;

  const CertificationScreen({Key? key, this.existingCertifications, this.isEdit = false}) : super(key: key);

  @override
  _CertificationScreenState createState() => _CertificationScreenState();
}

class _CertificationScreenState extends State<CertificationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _issuingBodyController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _issueDateController = TextEditingController();
  // final TextEditingController _expirationDateController = TextEditingController(); // Removed
  // final TextEditingController _credentialIdController = TextEditingController(); // Removed
  final TextEditingController _credentialUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Certification> _certificationEntries = [];
  String? _cardInDeleteMode; // Stores the name of the card currently in delete mode
  DateTime? _issueDate;
  // DateTime? _expirationDate; // Removed
  final Random _random = Random(); // For generating random Picsum IDs

  @override
  void initState() {
    super.initState();
    _loadCertificationData();
  }

  // Helper to generate a random Picsum image URL for certification logos
  String _generatePicsumUrl() {
    final int imageId = _random.nextInt(1000); // Random ID between 0 and 999
    return 'https://picsum.photos/id/$imageId/200/112'; // 200 width, 112 height for 16:9 aspect
  }

  void _loadCertificationData() {
    if (widget.isEdit && widget.existingCertifications != null) {
      try {
        final List<dynamic> decoded = jsonDecode(widget.existingCertifications!);
        _certificationEntries = decoded.map((e) => Certification.fromJson(e as Map<String, dynamic>)).toList();
      } catch (e) {
        _certificationEntries = [];
        print('Error decoding existing certifications: $e');
      }
    } else {
      // Dummy data for demonstration
      _certificationEntries = [
        Certification(
          name: 'Certified ScrumMaster (CSM)',
          issuingBody: 'Scrum Alliance',
          description: 'A professional certification for Scrum Masters.',
          issueDate: DateTime(2023, 3),
          // expirationDate: DateTime(2025, 3), // Removed
          // credentialId: 'ABC-123-XYZ', // Removed
          credentialUrl: 'https://www.scrumalliance.org/certifications/csm-certification',
          imageUrl: _generatePicsumUrl(),
        ),
        Certification(
          name: 'AWS Certified Solutions Architect – Associate',
          issuingBody: 'Amazon Web Services',
          description: 'Demonstrates knowledge of how to architect and deploy secure and robust applications on AWS.',
          issueDate: DateTime(2022, 9),
          // expirationDate: DateTime(2025, 9), // Removed
          // credentialId: 'AWS-SA-001', // Removed
          credentialUrl: 'https://aws.amazon.com/certification/certified-solutions-architect-associate/',
          imageUrl: _generatePicsumUrl(),
        ),
        Certification(
          name: 'Google Project Management Certificate',
          issuingBody: 'Google',
          description: 'A foundational understanding of project management principles and practices.',
          issueDate: DateTime(2021, 11),
          // expirationDate: null, // Removed
          // credentialId: 'GPM-9876', // Removed
          credentialUrl: 'https://grow.google/certificates/project-management/',
          imageUrl: _generatePicsumUrl(),
        ),
      ];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _issuingBodyController.dispose();
    _descriptionController.dispose();
    _issueDateController.dispose();
    // _expirationDateController.dispose(); // Removed
    // _credentialIdController.dispose(); // Removed
    _credentialUrlController.dispose();
    super.dispose();
  }

  void _toggleDeleteOverlay(String name) {
    setState(() {
      _cardInDeleteMode = (_cardInDeleteMode == name) ? null : name;
    });
  }

  void _deleteEntry(String name) {
    setState(() {
      _certificationEntries.removeWhere((entry) => entry.name == name);
      _cardInDeleteMode = null; // Exit delete mode after deletion
    });
  }

  void _showAddCertificationBottomSheet() {
    _nameController.clear();
    _issuingBodyController.clear();
    _descriptionController.clear();
    _issueDateController.clear();
    // _expirationDateController.clear(); // Removed
    // _credentialIdController.clear(); // Removed
    _credentialUrlController.clear();
    _issueDate = null;
    // _expirationDate = null; // Removed

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
                    Text('Add Certification', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text('Enter details for a new certification entry.', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Certification Name', helperText: 'e.g., Certified ScrumMaster', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter certification name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _issuingBodyController,
                      decoration: InputDecoration(labelText: 'Issuing Body', helperText: 'e.g., Scrum Alliance, Google', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter issuing body';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description (Optional)', helperText: 'Brief description of the certification', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _issueDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Issue Date',
                        helperText: 'Select issue date',
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        suffixIcon: Icon(Icons.calendar_today, size: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (_issueDate == null) {
                          return 'Please select an issue date';
                        }
                        return null;
                      },
                      onTap: () async {
                        final pickedDate = await showDatePicker(context: context, initialDate: _issueDate ?? DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100));
                        if (pickedDate != null) {
                          setState(() {
                            _issueDate = pickedDate;
                            _issueDateController.text = DateFormat.yMMMd().format(pickedDate);
                          });
                        }
                      },
                    ),
                    // SizedBox(height: 16.h), // Removed SizedBox
                    // TextFormField( // Removed Expiration Date field
                    //   controller: _expirationDateController,
                    //   readOnly: true,
                    //   decoration: InputDecoration(
                    //     labelText: 'Expiration Date (Optional)',
                    //     helperText: 'Select expiration date or leave empty if none',
                    //     labelStyle: Theme.of(context).textTheme.labelMedium,
                    //     suffixIcon: Icon(
                    //       Icons.calendar_today,
                    //       size: 16.sp,
                    //       color: Theme.of(context).colorScheme.onSurface,
                    //     ),
                    //   ),
                    //   style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                    //   onTap: () async {
                    //     final pickedDate = await showDatePicker(
                    //       context: context,
                    //       initialDate: _expirationDate ?? _issueDate ?? DateTime.now(),
                    //       firstDate: _issueDate ?? DateTime(1950),
                    //       lastDate: DateTime(2100),
                    //     );
                    //     if (pickedDate != null) {
                    //       setState(() {
                    //         _expirationDate = pickedDate;
                    //         _expirationDateController.text = DateFormat.yMMMd().format(pickedDate);
                    //       });
                    //     }
                    //   },
                    // ),
                    // SizedBox(height: 16.h), // Removed SizedBox
                    // TextFormField( // Removed Credential ID field
                    //   controller: _credentialIdController,
                    //   decoration: InputDecoration(
                    //     labelText: 'Credential ID (Optional)',
                    //     helperText: 'Unique ID for your certification',
                    //     labelStyle: Theme.of(context).textTheme.labelMedium,
                    //   ),
                    //   style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                    // ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _credentialUrlController,
                      decoration: InputDecoration(labelText: 'Credential URL (Optional)', helperText: 'Link to verify your certification', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
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
                              final newName = _nameController.text.trim();
                              final newCertification = Certification(
                                name: newName,
                                issuingBody: _issuingBodyController.text.trim(),
                                description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
                                issueDate: _issueDate!,
                                // expirationDate: _expirationDate, // Removed
                                // credentialId: _credentialIdController.text.trim().isNotEmpty ? _credentialIdController.text.trim() : null, // Removed
                                credentialUrl: _credentialUrlController.text.trim().isNotEmpty ? _credentialUrlController.text.trim() : null,
                                imageUrl: _generatePicsumUrl(), // Generate Picsum for new entries
                              );
                              setState(() {
                                _certificationEntries.add(newCertification);
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
                          label: Text('Add Certification', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
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
    _nameController.clear();
    _issuingBodyController.clear();
    _descriptionController.clear();
    _issueDateController.clear();
    // _expirationDateController.clear(); // Removed
    // _credentialIdController.clear(); // Removed
    _credentialUrlController.clear();
    _issueDate = null;
    // _expirationDate = null; // Removed
  }

  void _saveCertifications() {
    final certificationJson = jsonEncode(_certificationEntries.map((entry) => entry.toJson()).toList());
    Navigator.of(context).pop(certificationJson);
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
            onPressed: _saveCertifications, // Back button always saves and pops
          ),
          title: Text(widget.isEdit ? 'Edit Certifications' : 'Certifications', style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          actions: [IconButton(icon: Icon(Icons.add, size: 24.sp, color: Theme.of(context).colorScheme.onSurface), onPressed: _showAddCertificationBottomSheet)],
        ),
      ),
      body:
          _certificationEntries.isEmpty
              ? const EmptyCertificationWidget()
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                        _certificationEntries.map((entry) {
                          final String name = entry.name;
                          final bool isCardSelectedForDelete = _cardInDeleteMode == name;

                          return GestureDetector(
                            onTap: () => _toggleDeleteOverlay(name), // Tap to toggle delete overlay
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                              child: Stack(
                                children: [
                                  Container(
                                    // Main content of the card
                                    padding: EdgeInsets.all(16.w),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.secondaryContainer, // Subtle darker background
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
                                                    'Issued: ${DateFormat.yMMM().format(entry.issueDate)}', // Expiration removed from display
                                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(entry.name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                                                  SizedBox(height: 4.h),
                                                  Text(entry.issuingBody, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurfaceVariant)),
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
                                                                    Icons.verified, // Icon for certification
                                                                    size: 32.sp,
                                                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                                  ),
                                                                ),
                                                          )
                                                          : Container(
                                                            color: Theme.of(context).colorScheme.surfaceVariant,
                                                            child: Icon(
                                                              Icons.verified, // Icon for certification
                                                              size: 32.sp,
                                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                            ),
                                                          ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (entry.description != null && entry.description!.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 12.h),
                                            child: Text(entry.description!, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.left),
                                          ),
                                        // Removed Credential ID display
                                        // if (entry.credentialId != null && entry.credentialId!.isNotEmpty)
                                        //   Padding(
                                        //     padding: EdgeInsets.only(top: 8.h),
                                        //     child: Text(
                                        //       'Credential ID: ${entry.credentialId!}',
                                        //       style: TextStyle(
                                        //         fontSize: 12.sp,
                                        //         fontWeight: FontWeight.w500,
                                        //         color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        //       ),
                                        //     ),
                                        //   ),
                                        if (entry.credentialUrl != null && entry.credentialUrl!.isNotEmpty)
                                          Padding(
                                            padding: EdgeInsets.only(top: 4.h),
                                            child: InkWell(
                                              onTap: () {
                                                // TODO: Implement URL launch
                                                print('Launching URL: ${entry.credentialUrl!}');
                                              },
                                              child: Text('Verify Credential', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline)),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isCardSelectedForDelete)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(16.r)),
                                        child: Center(
                                          child: FloatingActionButton(
                                            heroTag: 'delete_${entry.name}', // Unique tag
                                            onPressed: () => _deleteEntry(name),
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

class EmptyCertificationWidget extends StatelessWidget {
  const EmptyCertificationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 48.h, left: 16.w, right: 16.w, bottom: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.military_tech, // Changed icon for certification
            size: 64.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text('No Certifications Yet', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text('Tap the + icon in the top right to add your professional certifications.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
