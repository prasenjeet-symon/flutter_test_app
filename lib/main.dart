import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test_app/date-input.dart';
import 'package:flutter_test_app/dropdown.dart' show OrbitDropdown, DropdownOption;
import 'package:flutter_test_app/file-input.dart';
import 'package:flutter_test_app/orbit-multi-select.dart';
import 'package:flutter_test_app/orbit-time.dart';
import 'package:flutter_test_app/search-input.dart';
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
      child: const TestFormScreen(),
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
  final _fileController = TextEditingController();
  final _searchController = TextEditingController(text: "1");
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
      body: Padding(
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
                isLocal: false,
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
                hintText: 'Enter your name',
                leftIcon: Icons.person,
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
                  print('Text input: $value');
                },
              ),
              SizedBox(height: 16.h),
              OrbitTextArea(
                controller: _descriptionController,
                isCompact: true,
                hintText: 'Enter a description',
                leftIcon: Icons.description,
                minLines: 3,
                maxLines: 5,
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
              OrbitFileInput(
                controller: _fileController,
                isCompact: true,
                hintText: 'Select an image or PDF',
                labelText: 'Upload File',
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
                orbitFormManager: _formManager,
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
                orbitFormManager: _formManager,
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
                    print('Name: ${_textController.text}');
                    print('Description: ${_descriptionController.text}');
                    print('Date: ${_dateController.text}');
                    print('Time: ${_timeController.text}');
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
    );
  }
}
