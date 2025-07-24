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
            cardTheme: CardTheme(color: Colors.white, elevation: 3, shadowColor: const Color(0x1A000000), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)), margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h)),
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
              color: const Color(0xFF1E1E1E),
              elevation: 3,
              shadowColor: const Color(0x1AFFFFFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            ),
          ),
          themeMode: ThemeMode.system,
          home: GoalsScreen(),
        );
      },
    );
  }
}

class GoalsScreen extends StatefulWidget {
  final String? existingGoals; // For editing existing goals
  final bool isEdit; // Flag to determine add or edit mode

  const GoalsScreen({Key? key, this.existingGoals, this.isEdit = false}) : super(key: key);

  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final TextEditingController _newGoalController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _goals = [];
  Map<String, bool> _showCrossIcon = {};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingGoals != null) {
      try {
        final decoded = jsonDecode(widget.existingGoals!) as List<dynamic>;
        _goals = decoded.map((e) => {'text': e['text'] as String, 'accomplishedDate': e['accomplishedDate'] != null ? DateTime.parse(e['accomplishedDate']) : null}).toList();
        _goals.forEach((goal) => _showCrossIcon[goal['text']] = false);
      } catch (e) {
        // Fallback: treat as comma-separated string
        _goals = widget.existingGoals!.split(',').map((e) => {'text': e.trim(), 'accomplishedDate': null}).where((e) => e['text']!.isNotEmpty).toList();
        _goals.forEach((goal) => _showCrossIcon[goal['text']] = false);
      }
    }
  }

  @override
  void dispose() {
    _newGoalController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _toggleCrossIcon(String goalText) {
    setState(() {
      _showCrossIcon[goalText] = !_showCrossIcon[goalText]!;
    });
  }

  void _deleteGoal(String goalText) {
    setState(() {
      _goals.removeWhere((goal) => goal['text'] == goalText);
      _showCrossIcon.remove(goalText);
    });
  }

  void _showAddGoalBottomSheet() {
    _selectedDate = null;
    _dateController.clear();
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
                    Text('Add Goal', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text('Enter a new goal and optionally set an achieved by date.', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 24.h),
                    TextFormField(
                      controller: _newGoalController,
                      decoration: InputDecoration(labelText: 'Goal', helperText: 'e.g., Launch a startup', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a goal';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Achieved By',
                        helperText: 'Optional: Select a target completion date',
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                        suffixIcon: Icon(Icons.calendar_today, size: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                      ),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      onTap: () async {
                        final pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                        if (pickedDate != null) {
                          setState(() {
                            _selectedDate = pickedDate;
                            _dateController.text = DateFormat.yMMMd().format(pickedDate);
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
                            _newGoalController.clear();
                            _dateController.clear();
                            _selectedDate = null;
                          },
                          child: Text('Cancel', style: Theme.of(context).textTheme.bodySmall),
                        ),
                        SizedBox(width: 16.w),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _goals.add({'text': _newGoalController.text.trim(), 'accomplishedDate': _selectedDate});
                                _showCrossIcon[_newGoalController.text.trim()] = false;
                              });
                              Navigator.of(context).pop();
                              _newGoalController.clear();
                              _dateController.clear();
                              _selectedDate = null;
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

  void _saveGoals() {
    if (_goals.isNotEmpty) {
      // Return data as JSON-encoded string
      final goalsJson = jsonEncode(_goals.map((goal) => {'text': goal['text'], 'accomplishedDate': goal['accomplishedDate']?.toIso8601String()}).toList());
      Navigator.of(context).pop(goalsJson);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please add at least one goal'), backgroundColor: Theme.of(context).colorScheme.error));
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
        title: Text(widget.isEdit ? 'Edit Goals' : 'Add Goals', style: Theme.of(context).textTheme.headlineMedium),
        actions: [IconButton(icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color), onPressed: _showAddGoalBottomSheet)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 24.h),
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Define Your Goals', style: Theme.of(context).textTheme.headlineLarge),
                  SizedBox(height: 8.h),
                  Text('List the goals that drive your professional aspirations.', style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 24.h),
                  if (_goals.isEmpty)
                    Text('No goals added yet. Tap the + icon to add one.', style: Theme.of(context).textTheme.bodyMedium)
                  else
                    Wrap(
                      spacing: 12.w, // Increased spacing for better separation
                      runSpacing: 12.h, // Increased run spacing for better vertical alignment
                      alignment: WrapAlignment.start, // Align chips to the start
                      children:
                          _goals.map((goal) {
                            return GestureDetector(
                              onTap: () => _toggleCrossIcon(goal['text']),
                              child: Chip(
                                label: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(goal['text'], style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface)),
                                    if (goal['accomplishedDate'] != null) Text('By: ${DateFormat.yMMMd().format(goal['accomplishedDate'])}', style: TextStyle(fontSize: 10.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                                  ],
                                ),
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.w),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h), // Increased padding for better readability
                                deleteIcon: Icon(Icons.close, size: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                                onDeleted: _showCrossIcon[goal['text']]! ? () => _deleteGoal(goal['text']) : null,
                              ),
                            );
                          }).toList(),
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
                        onPressed: _saveGoals,
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
    );
  }
}
