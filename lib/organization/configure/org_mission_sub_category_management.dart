import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizationMissionSubCategoriesScreen extends StatefulWidget {
  final String parentCategory;

  const OrganizationMissionSubCategoriesScreen({
    super.key,
    required this.parentCategory,
  });

  @override
  _OrganizationMissionSubCategoriesScreenState createState() =>
      _OrganizationMissionSubCategoriesScreenState();
}

class _OrganizationMissionSubCategoriesScreenState
    extends State<OrganizationMissionSubCategoriesScreen> {
  final List<Map<String, dynamic>> _allMissionSubCategories = [
    {
      'id': '1',
      'name': 'Long-term Goals',
      'isPredefined': true,
      'description': 'Sub-category for goals spanning more than one year.',
      'parent': 'Strategic Planning',
    },
    {
      'id': '2',
      'name': 'Quarterly Objectives',
      'isPredefined': true,
      'description': 'Specific, measurable objectives for each quarter.',
      'parent': 'Strategic Planning',
    },
    {
      'id': '3',
      'name': 'Supply Chain Optimization',
      'isPredefined': true,
      'description': 'Improving the efficiency and flow of the supply chain.',
      'parent': 'Operational Excellence',
    },
    {
      'id': '4',
      'name': 'Internal Process Automation',
      'isPredefined': true,
      'description': 'Automating repetitive tasks to increase productivity.',
      'parent': 'Operational Excellence',
    },
    {
      'id': '5',
      'name': 'Customer Feedback Analysis',
      'isPredefined': true,
      'description':
          'Analyzing customer feedback to identify areas for improvement.',
      'parent': 'Customer Focus',
    },
    {
      'id': '6',
      'name': 'Team Skill Enhancement',
      'isPredefined': false,
      'description':
          'Custom sub-category for team-specific training and development initiatives.',
      'parent': 'Employee Development',
    },
  ];

  List<Map<String, dynamic>> _filteredMissionSubCategories = [];
  String _currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _filterSubCategoriesByParent();
  }

  void _filterSubCategoriesByParent() {
    _filteredMissionSubCategories =
        _allMissionSubCategories
            .where((cat) => cat['parent'] == widget.parentCategory)
            .toList();
    _applyFilter(_currentFilter);
  }

  void _showAddSubCategoryBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddSubCategoryBottomSheet(
          existingCategories:
              _allMissionSubCategories
                  .where((cat) => cat['parent'] == widget.parentCategory)
                  .map((e) => e['name'] as String)
                  .toList(),
          onCategoryCreated: (String newCategory) {
            setState(() {
              _allMissionSubCategories.add({
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': newCategory,
                'isPredefined': false,
                'description': '',
                'parent': widget.parentCategory,
              });
              _applyFilter(_currentFilter);
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('"$newCategory" sub-category added!')),
            );
          },
        );
      },
    );
  }

  void _showUpdateSubCategoryDialog(Map<String, dynamic> category) {
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
            'Edit Sub-Category',
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
                    labelText: 'Sub-Category Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sub-category name is required';
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
                    final index = _allMissionSubCategories.indexWhere(
                      (element) => element['id'] == category['id'],
                    );
                    if (index != -1) {
                      _allMissionSubCategories[index] = {
                        ..._allMissionSubCategories[index],
                        'name': nameController.text,
                        'description': descController.text,
                      };
                    }
                    _applyFilter(_currentFilter);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sub-category updated successfully!'),
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
      List<Map<String, dynamic>> subCategoriesForParent =
          _allMissionSubCategories
              .where((cat) => cat['parent'] == widget.parentCategory)
              .toList();

      if (filter == 'All') {
        _filteredMissionSubCategories = subCategoriesForParent;
      } else if (filter == 'Pre-defined') {
        _filteredMissionSubCategories =
            subCategoriesForParent
                .where((cat) => cat['isPredefined'] == true)
                .toList();
      } else if (filter == 'Custom') {
        _filteredMissionSubCategories =
            subCategoriesForParent
                .where((cat) => cat['isPredefined'] == false)
                .toList();
      }
    });
  }

  void _confirmDeleteSubCategory(String subCategoryId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
            'Are you sure you want to delete this sub-category?',
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
                  _allMissionSubCategories.removeWhere(
                    (cat) => cat['id'] == subCategoryId,
                  );
                  _applyFilter(_currentFilter);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Sub-category deleted successfully!'),
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
          '${widget.parentCategory} Sub-Categories',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20.sp),
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
                  _filteredMissionSubCategories.isEmpty
                      ? Center(
                        child: Text(
                          'No sub-categories found for this mission. Tap the button to create one!',
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
                        itemCount: _filteredMissionSubCategories.length,
                        itemBuilder: (context, index) {
                          final category = _filteredMissionSubCategories[index];
                          return _MissionSubCategoryItem(
                            category: category,
                            onTap: () => _showUpdateSubCategoryDialog(category),
                            onDelete:
                                () => _confirmDeleteSubCategory(category['id']),
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
        onPressed: _showAddSubCategoryBottomSheet,
        label: const Text('Add Sub-Category'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

class _MissionSubCategoryItem extends StatelessWidget {
  final Map<String, dynamic> category;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _MissionSubCategoryItem({
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
            isPredefined ? Icons.location_city : Icons.category_rounded,
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

class _AddSubCategoryBottomSheet extends StatefulWidget {
  final List<String> existingCategories;
  final Function(String) onCategoryCreated;

  const _AddSubCategoryBottomSheet({
    required this.existingCategories,
    required this.onCategoryCreated,
  });

  @override
  __AddSubCategoryBottomSheetState createState() =>
      __AddSubCategoryBottomSheetState();
}

class __AddSubCategoryBottomSheetState
    extends State<_AddSubCategoryBottomSheet> {
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
                'Add Sub-Category',
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
                  hintText: 'Search or create a new sub-category...',
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
