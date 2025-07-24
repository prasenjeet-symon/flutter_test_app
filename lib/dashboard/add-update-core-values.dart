import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
          home: CoreValuesScreen(),
        );
      },
    );
  }
}

class CoreValuesScreen extends StatefulWidget {
  final String? existingValues; // For editing existing core values
  final bool isEdit; // Flag to determine add or edit mode

  const CoreValuesScreen({Key? key, this.existingValues, this.isEdit = false}) : super(key: key);

  @override
  _CoreValuesScreenState createState() => _CoreValuesScreenState();
}

class _CoreValuesScreenState extends State<CoreValuesScreen> {
  final TextEditingController _newValueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<String> _coreValues = [];
  Map<String, bool> _showCrossIcon = {};

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.existingValues != null) {
      _coreValues = widget.existingValues!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      _coreValues.forEach((value) => _showCrossIcon[value] = false);
    }
  }

  @override
  void dispose() {
    _newValueController.dispose();
    super.dispose();
  }

  void _toggleCrossIcon(String value) {
    setState(() {
      _showCrossIcon[value] = !_showCrossIcon[value]!;
    });
  }

  void _deleteValue(String value) {
    setState(() {
      _coreValues.remove(value);
      _showCrossIcon.remove(value);
    });
  }

  void _showAddValueBottomSheet() {
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
                    Text('Add Core Value', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text('Enter a new core value to add to your list.', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 24.h),
                    TextFormField(
                      controller: _newValueController,
                      decoration: InputDecoration(labelText: 'Core Value', helperText: 'e.g., Integrity', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a core value';
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
                            _newValueController.clear();
                          },
                          child: Text('Cancel', style: Theme.of(context).textTheme.bodySmall),
                        ),
                        SizedBox(width: 16.w),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              setState(() {
                                _coreValues.add(_newValueController.text.trim());
                                _showCrossIcon[_newValueController.text.trim()] = false;
                              });
                              Navigator.of(context).pop();
                              _newValueController.clear();
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

  void _saveCoreValues() {
    if (_coreValues.isNotEmpty) {
      // Return data to previous screen
      Navigator.of(context).pop(_coreValues.join(', '));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please add at least one core value'), backgroundColor: Theme.of(context).colorScheme.error));
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
        title: Text(widget.isEdit ? 'Edit Core Values' : 'Add Core Values', style: Theme.of(context).textTheme.headlineMedium),
        actions: [IconButton(icon: Icon(Icons.add, color: Theme.of(context).iconTheme.color), onPressed: _showAddValueBottomSheet)],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 24.h),
          child: Card(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Define Your Core Values', style: Theme.of(context).textTheme.headlineLarge),
                  SizedBox(height: 8.h),
                  Text('List the core values that guide your professional decisions and actions.', style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(height: 24.h),
                  if (_coreValues.isEmpty)
                    Text('No core values added yet. Tap the + icon to add one.', style: Theme.of(context).textTheme.bodyMedium)
                  else
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children:
                          _coreValues.map((value) {
                            return GestureDetector(
                              onTap: () => _toggleCrossIcon(value),
                              child: Chip(
                                label: Text(value, style: TextStyle(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurface)),
                                backgroundColor: Theme.of(context).colorScheme.surface,
                                side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.w),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                deleteIcon: Icon(Icons.close, size: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                                onDeleted: _showCrossIcon[value]! ? () => _deleteValue(value) : null,
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
                        onPressed: _saveCoreValues,
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
