import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            primaryColor: const Color(0xFF2C7BE5),
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF2C7BE5),
              secondary: const Color(0xFF1A4971),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1A202C),
              onBackground: const Color(0xFF1A202C),
              outline: const Color(0xFFE2E8F0),
              error: const Color(0xFFB00020),
              secondaryContainer: const Color(0xFFEDF2F7),
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A202C)),
              headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A202C)),
              bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: const Color(0xFF4A5568)),
              bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: const Color(0xFF4A5568)),
              labelMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280)),
              labelSmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: const Color(0xFF6B7280)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFB00020))),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFB00020), width: 2)),
              labelStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280)),
              helperStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), elevation: 0),
            ),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280), textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600))),
            iconTheme: const IconThemeData(color: Color(0xFF1A202C)),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 2,
              shadowColor: const Color(0x1A000000),
              titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A202C)),
              iconTheme: const IconThemeData(color: Color(0xFF1A202C)),
            ),
            cardTheme: CardTheme(
              elevation: 4,
              shadowColor: const Color(0x26000000),
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r), side: BorderSide(color: Color(0xFFE2E8F0), width: 1.w)),
              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF121212),
            primaryColor: const Color(0xFF2C7BE5),
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF2C7BE5),
              secondary: const Color(0xFF1A4971),
              onPrimary: Colors.white,
              surface: const Color(0xFF1E1E1E),
              onSurface: Colors.white,
              onBackground: Colors.white,
              outline: const Color(0xFF374151),
              error: const Color(0xFFCF6679),
              secondaryContainer: const Color(0xFF2D3748),
            ),
            textTheme: TextTheme(
              headlineLarge: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: Colors.white),
              headlineMedium: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
              bodyLarge: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: const Color(0xFFD1D5DB)),
              bodyMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w400, color: const Color(0xFFD1D5DB)),
              labelMedium: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: const Color(0xFF9CA3AF)),
              labelSmall: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: const Color(0xFF9CA3AF)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF374151))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
              errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFCF6679))),
              focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: Color(0xFFCF6679), width: 2)),
              labelStyle: TextStyle(fontSize: 14.sp, color: const Color(0xFF9CA3AF)),
              helperStyle: TextStyle(fontSize: 12.sp, color: const Color(0xFF9CA3AF)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), elevation: 0),
            ),
            textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: const Color(0xFF9CA3AF), textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600))),
            iconTheme: const IconThemeData(color: Colors.white),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1E1E1E),
              elevation: 2,
              shadowColor: const Color(0x1AFFFFFF),
              titleTextStyle: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            cardTheme: CardTheme(
              elevation: 4,
              shadowColor: const Color(0x26FFFFFF),
              color: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r), side: BorderSide(color: Color(0xFF374151), width: 1.w)),
              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
            ),
          ),
          themeMode: ThemeMode.system,
          home: EducationScreen(),
        );
      },
    );
  }
}

class EducationScreen extends StatefulWidget {
  final String? existingEducation; // For editing existing education entries
  final bool isEdit; // Flag to determine add or edit mode

  const EducationScreen({Key? key, this.existingEducation, this.isEdit = false}) : super(key: key);

  @override
  _EducationScreenState createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _instituteController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _admissionDateController = TextEditingController();
  final TextEditingController _graduationDateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _educationEntries = [];
  Map<String, bool> _showCrossIcon = {};
  DateTime? _admissionDate;
  DateTime? _graduationDate;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingEducation != null) {
      try {
        final decoded = jsonDecode(widget.existingEducation!) as List<dynamic>;
        _educationEntries =
            decoded
                .map(
                  (e) => {
                    'degree': e['degree'] as String,
                    'institute': e['institute'] as String,
                    'description': e['description'] as String,
                    'admissionDate': DateTime.parse(e['admissionDate']),
                    'graduationDate': e['graduationDate'] != null ? DateTime.parse(e['graduationDate']) : null,
                  },
                )
                .toList();
        _educationEntries.forEach((entry) => _showCrossIcon[entry['degree']] = false);
      } catch (e) {
        // Fallback: treat as comma-separated string
        _educationEntries = widget.existingEducation!.split(',').map((e) => {'degree': e.trim(), 'institute': '', 'description': '', 'admissionDate': DateTime.now(), 'graduationDate': null}).where((e) => e['degree'] != "").toList();
        _educationEntries.forEach((entry) => _showCrossIcon[entry['degree']] = false);
      }
    }
  }

  @override
  void dispose() {
    _degreeController.dispose();
    _instituteController.dispose();
    _descriptionController.dispose();
    _admissionDateController.dispose();
    _graduationDateController.dispose();
    super.dispose();
  }

  void _toggleCrossIcon(String degree) {
    setState(() {
      _showCrossIcon[degree] = !_showCrossIcon[degree]!;
    });
  }

  void _deleteEntry(String degree) {
    setState(() {
      _educationEntries.removeWhere((entry) => entry['degree'] == degree);
      _showCrossIcon.remove(degree);
    });
  }

  void _showAddEducationBottomSheet() {
    _degreeController.clear();
    _instituteController.clear();
    _descriptionController.clear();
    _admissionDateController.clear();
    _graduationDateController.clear();
    _admissionDate = null;
    _graduationDate = null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            margin: EdgeInsets.only(top: 24.h),
            decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer, borderRadius: BorderRadius.circular(2.r)))),
                    SizedBox(height: 16.h),
                    Text('Add Education', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text('Enter details for a new education entry.', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 24.h),
                    TextFormField(
                      controller: _degreeController,
                      decoration: InputDecoration(labelText: 'Degree', helperText: 'e.g., B.Sc. Computer Science', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a degree';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _instituteController,
                      decoration: InputDecoration(labelText: 'Institute', helperText: 'e.g., MIT', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter an institute';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: 'Description', helperText: 'e.g., Specialized in AI and machine learning', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _admissionDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Admission Date',
                        helperText: 'Select admission date',
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        suffixIcon: Icon(Icons.calendar_today, size: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please select an admission date';
                        }
                        return null;
                      },
                      onTap: () async {
                        final pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100));
                        if (pickedDate != null) {
                          setState(() {
                            _admissionDate = pickedDate;
                            _admissionDateController.text = DateFormat.yMMMd().format(pickedDate);
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _graduationDateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Graduation Date',
                        helperText: 'Optional: Select graduation date',
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        suffixIcon: Icon(Icons.calendar_today, size: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      onTap: () async {
                        final pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2100));
                        if (pickedDate != null) {
                          setState(() {
                            _graduationDate = pickedDate;
                            _graduationDateController.text = DateFormat.yMMMd().format(pickedDate);
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
                            _degreeController.clear();
                            _instituteController.clear();
                            _descriptionController.clear();
                            _admissionDateController.clear();
                            _graduationDateController.clear();
                            _admissionDate = null;
                            _graduationDate = null;
                          },
                          child: Text('Cancel', style: Theme.of(context).textTheme.labelMedium),
                        ),
                        SizedBox(width: 16.w),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (_admissionDate == null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an admission date'), backgroundColor: Theme.of(context).colorScheme.error));
                                return;
                              }
                              setState(() {
                                _educationEntries.add({
                                  'degree': _degreeController.text.trim(),
                                  'institute': _instituteController.text.trim(),
                                  'description': _descriptionController.text.trim(),
                                  'admissionDate': _admissionDate,
                                  'graduationDate': _graduationDate,
                                });
                                _showCrossIcon[_degreeController.text.trim()] = false;
                              });
                              Navigator.of(context).pop();
                              _degreeController.clear();
                              _instituteController.clear();
                              _descriptionController.clear();
                              _admissionDateController.clear();
                              _graduationDateController.clear();
                              _admissionDate = null;
                              _graduationDate = null;
                            }
                          },
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
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _saveEducation() {
    // Save entries as JSON when navigating back
    final educationJson = jsonEncode(
      _educationEntries
          .map((entry) => {'degree': entry['degree'], 'institute': entry['institute'], 'description': entry['description'], 'admissionDate': entry['admissionDate'].toIso8601String(), 'graduationDate': entry['graduationDate']?.toIso8601String()})
          .toList(),
    );
    Navigator.of(context).pop(educationJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color), onPressed: _saveEducation),
        title: Text(widget.isEdit ? 'Edit Education' : 'Add Education', style: Theme.of(context).textTheme.headlineMedium),
        actions: [IconButton(icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color), onPressed: _showAddEducationBottomSheet)],
      ),
      body:
          _educationEntries.isEmpty
              ? EmptyWidget()
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                        _educationEntries.map((entry) {
                          return GestureDetector(
                            onTap: () => _toggleCrossIcon(entry['degree']),
                            child: Card(
                              margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Theme.of(context).colorScheme.primary, Color.lerp(Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.onPrimary, 0.1)!],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                child: Stack(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(20.w),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(entry['degree'], style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onPrimary)),
                                          SizedBox(height: 12.h),
                                          Text(entry['institute'], style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onPrimary)),
                                          SizedBox(height: 12.h),
                                          Text(entry['description'], style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.85))),
                                          SizedBox(height: 12.h),
                                          Row(
                                            children: [
                                              Icon(Icons.login, size: 16.sp, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.85)),
                                              SizedBox(width: 8.w),
                                              Text('Admitted: ${DateFormat.yMMM().format(entry['admissionDate'])}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.85))),
                                            ],
                                          ),
                                          if (entry['graduationDate'] != null) ...[
                                            SizedBox(height: 6.h),
                                            Row(
                                              children: [
                                                Icon(Icons.celebration, size: 16.sp, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.85)),
                                                SizedBox(width: 8.w),
                                                Text('Graduated: ${DateFormat.yMMM().format(entry['graduationDate'])}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.85))),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    if (_showCrossIcon[entry['degree']]!)
                                      Positioned(top: 8.w, right: 8.w, child: IconButton(icon: Icon(Icons.close, size: 18.sp, color: Theme.of(context).colorScheme.onPrimary), onPressed: () => _deleteEntry(entry['degree']))),
                                  ],
                                ),
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

class EmptyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 48.h, left: 8.w, right: 8.w, bottom: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 64.sp, color: Theme.of(context).colorScheme.primary),
          SizedBox(height: 16.h),
          Text('No Education Entries Yet', style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 8.h),
          Text('Tap the + icon in the top right to add your educational qualifications.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
