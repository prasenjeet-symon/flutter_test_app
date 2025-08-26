import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class ManagePurposeScreen extends StatefulWidget {
  const ManagePurposeScreen({super.key});

  @override
  _ManagePurposeScreenState createState() => _ManagePurposeScreenState();
}

class _ManagePurposeScreenState extends State<ManagePurposeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _purposeTextController = TextEditingController();

  String? _selectedCategory;
  String? _selectedSubCategory;
  bool _isEditingMode = false;
  bool _isPreviewMode = false;

  final List<String> _categories = [
    'Social Impact',
    'Economic Growth',
    'Sustainability',
    'Innovation',
    'Customer Focus',
    'Operational Excellence',
  ];
  final Map<String, List<String>> _subCategories = {
    'Social Impact': [
      'Community Empowerment',
      'Human Rights',
      'Charitable Giving',
    ],
    'Economic Growth': [
      'Job Creation',
      'Market Leadership',
      'Wealth Distribution',
    ],
    'Sustainability': [
      'Environmental Protection',
      'Ethical Sourcing',
      'Renewable Energy',
    ],
    'Innovation': ['Product Development', 'R&D', 'Technological Advancement'],
    'Customer Focus': [
      'Customer Satisfaction',
      'Brand Loyalty',
      'Service Quality',
    ],
    'Operational Excellence': [
      'Process Efficiency',
      'Supply Chain Management',
      'Risk Management',
    ],
  };

  @override
  void initState() {
    super.initState();
    _fetchExistingPurpose();
  }

  void _fetchExistingPurpose() {
    const existingPurpose =
        "### Our Core Purpose\nTo drive **innovation** and create products that empower individuals to achieve their full potential. We are committed to **sustainable growth** and ethical business practices.";
    if (existingPurpose.isNotEmpty) {
      setState(() {
        _purposeTextController.text = existingPurpose;
        _selectedCategory = 'Innovation';
        _selectedSubCategory = 'Product Development';
        _isEditingMode = true;
      });
    }
  }

  @override
  void dispose() {
    _purposeTextController.dispose();
    super.dispose();
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return _CategorySelectionSheet(
          title: 'Select Purpose Category',
          items: _categories,
          onItemSelected: (category) {
            setState(() {
              _selectedCategory = category;
              _selectedSubCategory =
                  null; // Reset sub-category on new category selection
            });
          },
        );
      },
    );
  }

  void _showSubCategorySelector() {
    if (_selectedCategory == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return _CategorySelectionSheet(
          title: 'Select Sub-category',
          items: _subCategories[_selectedCategory] ?? [],
          onItemSelected: (subCategory) {
            setState(() {
              _selectedSubCategory = subCategory;
            });
          },
        );
      },
    );
  }

  void _savePurpose() {
    bool isPurposeValid =
        _isPreviewMode
            ? _purposeTextController.text.isNotEmpty
            : _formKey.currentState!.validate();

    if (isPurposeValid &&
        _selectedCategory != null &&
        _selectedSubCategory != null) {
      print('Purpose Text: ${_purposeTextController.text}');
      print('Category: $_selectedCategory');
      print('Sub-Category: $_selectedSubCategory');

      final String action = _isEditingMode ? 'updated' : 'created';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Purpose successfully $action!')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all required fields.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          _isEditingMode
              ? 'Edit Organization Purpose'
              : 'Create Organization Purpose',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isPreviewMode ? Icons.edit : Icons.remove_red_eye_outlined,
            ),
            tooltip:
                _isPreviewMode
                    ? 'Switch to Edit Mode'
                    : 'Switch to Preview Mode',
            onPressed: () {
              setState(() {
                _isPreviewMode = !_isPreviewMode;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isEditingMode) _buildStatusCard(),
                      SizedBox(height: 20.h),
                      _buildPurposeInputSection(),
                      SizedBox(height: 24.h),
                      _buildCategorySelector(),
                      SizedBox(height: 16.h),
                      if (_selectedCategory != null)
                        _buildSubCategorySelector(),
                    ],
                  ),
                ),
              ),
            ),
            _buildCtaButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Your organization\'s purpose has already been created. You can update it here.',
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurposeInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organization Purpose',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        _isPreviewMode
            ? Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: MarkdownBody(
                data:
                    _purposeTextController.text.isEmpty
                        ? '*Purpose preview will appear here.*'
                        : _purposeTextController.text,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  h1: GoogleFonts.lato(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  h2: GoogleFonts.lato(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  h3: GoogleFonts.lato(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  p: GoogleFonts.lato(fontSize: 16.sp),
                  strong: GoogleFonts.lato(fontWeight: FontWeight.bold),
                ),
              ),
            )
            : TextFormField(
              controller: _purposeTextController,
              maxLines: 10,
              minLines: 5,
              decoration: InputDecoration(
                hintText:
                    'Describe your organization\'s purpose and objectives...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the purpose text.';
                }
                return null;
              },
            ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purpose Category',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: _showCategorySelector,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Select a purpose category',
              prefixIcon: const Icon(Icons.category_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            child: Text(
              _selectedCategory ?? 'Select',
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Purpose Sub-category',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 12.h),
        InkWell(
          onTap: _showSubCategorySelector,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Select a purpose sub-category',
              prefixIcon: const Icon(Icons.class_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            child: Text(
              _selectedSubCategory ?? 'Select',
              style: GoogleFonts.lato(
                fontSize: 16.sp,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCtaButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _savePurpose,
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            _isEditingMode ? 'Update Purpose' : 'Create Purpose',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySelectionSheet extends StatefulWidget {
  final String title;
  final List<String> items;
  final Function(String) onItemSelected;

  const _CategorySelectionSheet({
    required this.title,
    required this.items,
    required this.onItemSelected,
  });

  @override
  _CategorySelectionSheetState createState() => _CategorySelectionSheetState();
}

class _CategorySelectionSheetState extends State<_CategorySelectionSheet> {
  final _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems =
          widget.items
              .where((item) => item.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          top: 24.h,
          left: 24.w,
          right: 24.w,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            if (_filteredItems.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Center(
                  child: Text(
                    'No items found.',
                    style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return ListTile(
                    leading: const Icon(Icons.assignment_turned_in_outlined),
                    title: Text(item),
                    onTap: () {
                      widget.onItemSelected(item);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
