import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test_app/date-input.dart';
import 'package:flutter_test_app/dropdown.dart' show OrbitDropdown, DropdownOption;
import 'package:flutter_test_app/file-input.dart';
import 'package:flutter_test_app/orbit-multi-select.dart';
import 'package:flutter_test_app/orbit-time.dart';
import 'package:flutter_test_app/password.widget.dart';
import 'package:flutter_test_app/phone_input.dart';
import 'package:flutter_test_app/search-input.dart';
import 'package:flutter_test_app/test/japa_history.dart';
import 'package:flutter_test_app/text-input.dart';
import 'package:flutter_test_app/text-area.dart';
import 'package:flutter_test_app/utils.dart';
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF8207E0),
              primary: const Color(0xFF8207E0),
              surfaceVariant: const Color(0xFFF0F0F0),
              onSurfaceVariant: Colors.grey[600],
              error: const Color(0xFFFB6363),
              outlineVariant: Colors.grey[400]!,
            ),
            textTheme: TextTheme(titleMedium: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400), labelMedium: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500), bodySmall: TextStyle(fontSize: 12.sp)),
          ),
          home: child,
        );
      },
      child: JapaHistoryScreen(
        defaultDateRange: DateTimeRange(start: DateTime.now().subtract(const Duration(days: 7)), end: DateTime.now()),
        transactions: [
          MalaTransaction(startDateTime: DateTime(2023, 8, 1, 9, 0), endDateTime: DateTime(2023, 8, 1, 11, 0), malaCount: 5, id: '1'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 2, 9, 0), endDateTime: DateTime(2023, 8, 2, 11, 0), malaCount: 10, id: '2'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 3, 9, 0), endDateTime: DateTime(2023, 8, 3, 11, 0), malaCount: 15, id: '3'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 4, 9, 0), endDateTime: DateTime(2023, 8, 4, 11, 0), malaCount: 20, id: '4'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 5, 9, 0), endDateTime: DateTime(2023, 8, 5, 11, 0), malaCount: 25, id: '5'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 6, 9, 0), endDateTime: DateTime(2023, 8, 6, 11, 0), malaCount: 30, id: '6'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 7, 9, 0), endDateTime: DateTime(2023, 8, 7, 11, 0), malaCount: 35, id: '7'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 8, 9, 0), endDateTime: DateTime(2023, 8, 8, 11, 0), malaCount: 40, id: '8'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 9, 9, 0), endDateTime: DateTime(2023, 8, 9, 11, 0), malaCount: 45, id: '9'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 10, 9, 0), endDateTime: DateTime(2023, 8, 10, 11, 0), malaCount: 50, id: '10'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 11, 9, 0), endDateTime: DateTime(2023, 8, 11, 11, 0), malaCount: 55, id: '11'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 12, 9, 0), endDateTime: DateTime(2023, 8, 12, 11, 0), malaCount: 60, id: '12'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 13, 9, 0), endDateTime: DateTime(2023, 8, 13, 11, 0), malaCount: 65, id: '13'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 14, 9, 0), endDateTime: DateTime(2023, 8, 14, 11, 0), malaCount: 70, id: '14'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 15, 9, 0), endDateTime: DateTime(2023, 8, 15, 11, 0), malaCount: 75, id: '15'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 16, 9, 0), endDateTime: DateTime(2023, 8, 16, 11, 0), malaCount: 80, id: '16'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 17, 9, 0), endDateTime: DateTime(2023, 8, 17, 11, 0), malaCount: 85, id: '17'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 18, 9, 0), endDateTime: DateTime(2023, 8, 18, 11, 0), malaCount: 90, id: '18'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 19, 9, 0), endDateTime: DateTime(2023, 8, 19, 11, 0), malaCount: 95, id: '19'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 20, 9, 0), endDateTime: DateTime(2023, 8, 20, 11, 0), malaCount: 100, id: '20'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 21, 9, 0), endDateTime: DateTime(2023, 8, 21, 11, 0), malaCount: 105, id: '21'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 22, 9, 0), endDateTime: DateTime(2023, 8, 22, 11, 0), malaCount: 110, id: '22'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 23, 9, 0), endDateTime: DateTime(2023, 8, 23, 11, 0), malaCount: 115, id: '23'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 24, 9, 0), endDateTime: DateTime(2023, 8, 24, 11, 0), malaCount: 120, id: '24'),
          MalaTransaction(startDateTime: DateTime(2023, 8, 25, 9, 0), endDateTime: DateTime(2023, 8, 25, 11, 0), malaCount: 125, id: '25'),
        ],
      ),
    );
  }
}

class TestFormScreen extends StatefulWidget {
  const TestFormScreen({super.key});

  @override
  State<TestFormScreen> createState() => _TestFormScreenState();
}

class _TestFormScreenState extends State<TestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textController = TextEditingController(text: 'Harry');
  final _descriptionController = TextEditingController(text: 'Lorem ipsum dolor sit amet');
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _phoneController = TextEditingController(text: '+12025550123'); // Full phone number with country code
  final _passwordController = TextEditingController(text: 'Password123!');
  final _fileController = TextEditingController();
  final _searchController = TextEditingController(text: '1');
  final _categoryController = TextEditingController(text: 'electronics');
  final _subCategoryController = TextEditingController(text: 'smartphones,laptops');
  final _formManager = OrbitFormManager();

  // Static category options
  final List<DropdownOption> _categoryOptions = [
    DropdownOption(id: 'electronics', title: 'Electronics', subtitle: 'Gadgets and devices'),
    DropdownOption(id: 'clothing', title: 'Clothing', subtitle: 'Apparel and accessories'),
    DropdownOption(id: 'books', title: 'Books', subtitle: 'Literature and textbooks'),
  ];

  // Mock async data for subcategories
  Future<List<DropdownOption>> _fetchSubCategories(dynamic parentValue) async {
    print('Fetching subcategories for ${parentValue?.id}');
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    if (parentValue?.id == 'electronics') {
      return [
        DropdownOption(id: 'smartphones', title: 'Smartphones', subtitle: 'Mobile devices'),
        DropdownOption(id: 'laptops', title: 'Laptops', subtitle: 'Portable computers'),
        DropdownOption(id: 'tablets', title: 'Tablets', subtitle: 'Portable touch devices'),
      ];
    } else if (parentValue?.id == 'clothing') {
      return [DropdownOption(id: 'shirts', title: 'Shirts', subtitle: 'Casual and formal'), DropdownOption(id: 'shoes', title: 'Shoes', subtitle: 'Footwear'), DropdownOption(id: 'jackets', title: 'Jackets', subtitle: 'Outerwear')];
    } else {
      return [];
    }
  }

  // Mock search data, dependent on parent category
  Future<List<SearchResult>> _mockSearch(String query) async {
    final parentValue = _formManager.get('category').value;
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    final results = [
      if (parentValue?.id == 'electronics' || parentValue == null) ...[
        SearchResult(id: '1', title: 'Smartphone Pro', subtitle: 'Latest model', profilePicture: 'https://picsum.photos/200', isVerified: true),
        SearchResult(id: '2', title: 'Laptop Ultra', subtitle: 'High performance', profilePicture: 'https://picsum.photos/200', isVerified: false),
        SearchResult(id: '3', title: 'Laptop Ultra', subtitle: 'High performance', profilePicture: 'https://picsum.photos/200', isVerified: false),
        SearchResult(id: '4', title: 'Laptop Ultra', subtitle: 'High performance', profilePicture: 'https://picsum.photos/200', isVerified: false),
        SearchResult(id: '5', title: 'Laptop Ultra', subtitle: 'High performance', profilePicture: 'https://picsum.photos/200', isVerified: false),
        SearchResult(id: '6', title: 'Laptop Ultra', subtitle: 'High performance', profilePicture: 'https://picsum.photos/200', isVerified: false),
        SearchResult(id: '7', title: 'Laptop Ultra', subtitle: 'High performance', profilePicture: 'https://picsum.photos/200', isVerified: false),
        SearchResult(id: '8', title: 'Laptop Ultra', subtitle: 'High performance', profilePicture: 'https://picsum.photos/200', isVerified: false),
      ],
      if (parentValue?.id == 'clothing' || parentValue == null) ...[
        SearchResult(id: '3', title: 'Designer Shirt', subtitle: 'Casual wear', profilePicture: 'https://example.com/shirt.jpg', isVerified: true),
        SearchResult(id: '4', title: 'Running Shoes', subtitle: 'Athletic footwear', profilePicture: 'https://example.com/shoes.jpg', isVerified: false),
      ],
      if (parentValue?.id == 'books' || parentValue == null) ...[
        SearchResult(id: '5', title: 'Sci-Fi Novel', subtitle: 'Bestseller', profilePicture: 'https://example.com/book.jpg', isVerified: true),
        SearchResult(id: '6', title: 'Textbook', subtitle: 'Academic', profilePicture: null, isVerified: false),
      ],
    ];
    if (query.isEmpty) return results;
    return results.where((result) => result.title.toLowerCase().contains(query.toLowerCase()) || result.subtitle!.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _textController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _fileController.dispose();
    _searchController.dispose();
    _categoryController.dispose();
    _subCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Orbit Inputs')),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                OrbitSearchInput(
                  orbitKey: 'search',
                  orbitParentKey: 'category',
                  orbitFormManager: _formManager,
                  controller: _searchController,
                  isCompact: true,
                  hintText: 'Search items...',
                  labelText: 'Search Query',
                  isLocal: false,
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  verticalMargin: 8.h,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a search query';
                    }
                    return null;
                  },
                  onSearch: _mockSearch,
                ),
                SizedBox(height: 16.h),
                OrbitTextInput(
                  controller: _textController,
                  isCompact: true,
                  hintText: 'Enter event name',
                  labelText: 'Event Name',
                  leftIcon: Icons.event,
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 12.w),
                  verticalMargin: 10.h,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print('Event Name: $value');
                  },
                ),
                SizedBox(height: 16.h),
                OrbitTextArea(
                  controller: _descriptionController,
                  isCompact: true,
                  hintText: 'Enter a description',
                  labelText: 'Event Description',
                  leftIcon: Icons.description,
                  minLines: 3,
                  maxLines: 5,
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  verticalMargin: 8.h,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    if (value.length < 10) {
                      return 'Description must be at least 10 characters';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print('Description: $value');
                  },
                ),
                SizedBox(height: 16.h),
                OrbitDateInput(
                  controller: _dateController,
                  isCompact: true,
                  hintText: 'Select a date',
                  labelText: 'Event Date',
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  verticalMargin: 8.h,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                  onDateSelected: (date) {
                    print('Date selected: $date');
                  },
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                ),
                SizedBox(height: 16.h),
                OrbitTimeInput(
                  controller: _timeController,
                  isCompact: true,
                  hintText: 'Select a time',
                  labelText: 'Event Time',
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  verticalMargin: 8.h,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a time';
                    }
                    return null;
                  },
                  onTimeSelected: (time) {
                    print('Time selected: ${time.format(context)}');
                  },
                  initialTime: const TimeOfDay(hour: 12, minute: 0),
                ),
                SizedBox(height: 16.h),
                OrbitPhoneInput(
                  controller: _phoneController,
                  isCompact: true,
                  hintText: 'Enter phone number',
                  labelText: 'Contact Number',
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  verticalMargin: 8.h,
                  onChanged: (value) {
                    print('Phone Number: $value');
                  },
                ),
                SizedBox(height: 16.h),
                OrbitPasswordInput(
                  controller: _passwordController,
                  isCompact: true,
                  hintText: 'Enter password',
                  labelText: 'Password',
                  leftIcon: Icons.lock,
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  verticalMargin: 8.h,
                  onChanged: (value) {
                    print('Password: $value');
                  },
                ),
                SizedBox(height: 16.h),
                OrbitFileInput(
                  controller: _fileController,
                  isCompact: true,
                  hintText: 'Select an image or PDF',
                  labelText: 'Event Document',
                  allowedMimeTypes: ['image/*', 'application/pdf'],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please upload a file';
                    }
                    return null;
                  },
                  onFileUploaded: (result, file) {
                    print('File uploaded: ${result.name}, S3 Key: ${result.s3Key}, Type: ${result.type}, Progress: ${result.progress}');
                  },
                ),
                SizedBox(height: 16.h),
                OrbitDropdown<DropdownOption>(
                  orbitKey: 'category',
                  options: _categoryOptions,
                  isCompact: true,
                  controller: _categoryController,
                  hintText: 'Select a category',
                  labelText: 'Category',
                  orbitFormManager: _formManager,
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  verticalMargin: 8.h,
                  validator: (value) {
                    if (value == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print('Category selected: ${value?.title}');
                  },
                ),
                SizedBox(height: 16.h),
                OrbitMultiSelectDropdown<DropdownOption>(
                  orbitKey: 'subcategory',
                  orbitParentKey: 'category',
                  data: (p) => _fetchSubCategories(p),
                  options: const [],
                  isCompact: true,
                  controller: _subCategoryController,
                  hintText: 'Select subcategories',
                  labelText: 'Subcategories',
                  orbitFormManager: _formManager,
                  padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                  verticalMargin: 8.h,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select at least one subcategory';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    print('Subcategories selected: ${value.map((e) => e.title).join(', ')}');
                  },
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      print('Form is valid');
                      print('Search Query: ${_searchController.text}');
                      print('Event Name: ${_textController.text}');
                      print('Description: ${_descriptionController.text}');
                      print('Date: ${_dateController.text}');
                      print('Time: ${_timeController.text}');
                      print('Phone Number: ${_phoneController.text}');
                      print('Password: ${_passwordController.text}');
                      print('File S3 Key: ${_fileController.text}');
                      print('Category: ${_categoryController.text}');
                      print('Subcategories: ${_subCategoryController.text}');
                    } else {
                      print('Form has errors');
                    }
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
