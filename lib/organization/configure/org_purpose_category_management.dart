import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizationPurposeCategoriesScreen extends StatefulWidget {
  const OrganizationPurposeCategoriesScreen({super.key});

  @override
  _OrganizationPurposeCategoriesScreenState createState() =>
      _OrganizationPurposeCategoriesScreenState();
}

class _OrganizationPurposeCategoriesScreenState
    extends State<OrganizationPurposeCategoriesScreen> {
  final List<Map<String, dynamic>> _allPurposeCategories = [
    {
      'id': '1',
      'name': 'Customer Satisfaction',
      'isPredefined': true,
      'description':
          'Purpose driven by exceeding customer expectations and needs.',
    },
    {
      'id': '2',
      'name': 'Societal Impact',
      'isPredefined': true,
      'description':
          'Focused on creating a positive influence on the community and society.',
    },
    {
      'id': '3',
      'name': 'Innovation & Growth',
      'isPredefined': true,
      'description':
          'The core purpose of pioneering new solutions and continuous business growth.',
    },
    {
      'id': '4',
      'name': 'Employee Well-being',
      'isPredefined': true,
      'description':
          'A purpose centered on nurturing a healthy and supportive work environment.',
    },
    {
      'id': '5',
      'name': 'Sustainability',
      'isPredefined': true,
      'description':
          'A mission to operate in an environmentally and socially responsible manner.',
    },
    {
      'id': '6',
      'name': 'Internal Team Cohesion',
      'isPredefined': false,
      'description':
          'A custom purpose to strengthen internal relationships and teamwork.',
    },
  ];

  List<Map<String, dynamic>> _filteredPurposeCategories = [];
  String _currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _applyFilter(_currentFilter);
  }

  void _showAddPurposeCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddPurposeCategoryBottomSheet(
          existingCategories:
              _allPurposeCategories.map((e) => e['name'] as String).toList(),
          onCategoryCreated: (String newCategory) {
            setState(() {
              _allPurposeCategories.add({
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': newCategory,
                'isPredefined': false,
                'description': '',
              });
              _applyFilter(_currentFilter);
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('"$newCategory" category added!')),
            );
          },
        );
      },
    );
  }

  void _showUpdatePurposeCategoryDialog(Map<String, dynamic> category) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController(
      text: category['name'],
    );
    final TextEditingController descController = TextEditingController(
      text: category['description'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Category',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Category Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    final index = _allPurposeCategories.indexWhere(
                      (element) => element['id'] == category['id'],
                    );
                    if (index != -1) {
                      _allPurposeCategories[index] = {
                        ..._allPurposeCategories[index],
                        'name': nameController.text,
                        'description': descController.text,
                      };
                    }
                    _applyFilter(_currentFilter);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category updated successfully!'),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      if (filter == 'All') {
        _filteredPurposeCategories = _allPurposeCategories;
      } else if (filter == 'Pre-defined') {
        _filteredPurposeCategories =
            _allPurposeCategories
                .where((cat) => cat['isPredefined'] == true)
                .toList();
      } else if (filter == 'Custom') {
        _filteredPurposeCategories =
            _allPurposeCategories
                .where((cat) => cat['isPredefined'] == false)
                .toList();
      }
    });
  }

  void _confirmDeletePurposeCategory(String categoryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this purpose category?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                setState(() {
                  _allPurposeCategories.removeWhere(
                    (cat) => cat['id'] == categoryId,
                  );
                  _applyFilter(_currentFilter);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Purpose category deleted successfully!'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isFilterActive = _currentFilter != 'All';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Purpose Categories',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 24.sp),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: _applyFilter,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'All', child: Text('All')),
                  const PopupMenuItem(
                    value: 'Pre-defined',
                    child: Text('Pre-defined'),
                  ),
                  const PopupMenuItem(value: 'Custom', child: Text('Custom')),
                ],
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter categories',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            if (isFilterActive)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text(
                      _currentFilter,
                      style: GoogleFonts.lato(fontSize: 14.sp),
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                    shape: StadiumBorder(),
                    deleteIcon: Icon(Icons.close, size: 18.sp),
                    onDeleted: () => _applyFilter('All'),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                  ),
                ),
              ),
            Expanded(
              child:
                  _filteredPurposeCategories.isEmpty
                      ? Center(
                        child: Text(
                          'No purpose categories found. Tap the button to create one!',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : ListView.separated(
                        itemCount: _filteredPurposeCategories.length,
                        itemBuilder: (context, index) {
                          final category = _filteredPurposeCategories[index];
                          return _PurposeCategoryItem(
                            category: category,
                            onTap:
                                () =>
                                    _showUpdatePurposeCategoryDialog(category),
                            onDelete:
                                () => _confirmDeletePurposeCategory(
                                  category['id'],
                                ),
                          );
                        },
                        separatorBuilder:
                            (context, index) => Divider(
                              height: 1.h,
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.3),
                            ),
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddPurposeCategoryBottomSheet,
        label: const Text('Add Category'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

class _PurposeCategoryItem extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _PurposeCategoryItem({
    required this.category,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPredefined = category['isPredefined'] as bool;
    final String name = category['name'] as String;
    final String description = category['description'] as String;

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          backgroundColor:
              isPredefined
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.secondary.withOpacity(0.1),
          child: Icon(
            isPredefined ? Icons.favorite_border : Icons.category_rounded,
            color:
                isPredefined
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isPredefined)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Chip(
                  label: Text(
                    'Pre-defined',
                    style: GoogleFonts.lato(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onTap();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
        ),
      ),
    );
  }
}

class _AddPurposeCategoryBottomSheet extends StatefulWidget {
  final List<String> existingCategories;
  final Function(String) onCategoryCreated;

  const _AddPurposeCategoryBottomSheet({
    required this.existingCategories,
    required this.onCategoryCreated,
  });

  @override
  __AddPurposeCategoryBottomSheetState createState() =>
      __AddPurposeCategoryBottomSheetState();
}

class __AddPurposeCategoryBottomSheetState
    extends State<_AddPurposeCategoryBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCategories = [];
  bool _showCreateNewButton = false;

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.existingCategories;
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCategories);
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories =
          widget.existingCategories
              .where((category) => category.toLowerCase().contains(query))
              .toList();
      _showCreateNewButton = query.isNotEmpty && _filteredCategories.isEmpty;
    });
  }

  void _createNewCategory() {
    final newCategoryName = _searchController.text;
    if (newCategoryName.isNotEmpty) {
      widget.onCategoryCreated(newCategoryName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Add Purpose Category',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search or create a new category...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
              ),
            ),
            if (_showCreateNewButton)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: ElevatedButton.icon(
                  onPressed: _createNewCategory,
                  icon: const Icon(Icons.add),
                  label: Text(
                    'Create "${_searchController.text}"',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 48.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = _filteredCategories[index];
                    return ListTile(
                      title: Text(category),
                      onTap: () {
                        widget.onCategoryCreated(category);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
