import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizationGoalsScreen extends StatefulWidget {
  const OrganizationGoalsScreen({super.key});

  @override
  State<OrganizationGoalsScreen> createState() =>
      _OrganizationGoalsScreenState();
}

class _OrganizationGoalsScreenState extends State<OrganizationGoalsScreen> {
  final List<Map<String, dynamic>> _allGoals = [
    {
      'id': '1',
      'title': 'Achieve 10% market share in Q4',
      'description':
          'Expand our customer base by focusing on key demographics and launching a targeted marketing campaign.',
      'category': 'Marketing',
      'accomplishmentDate': DateTime(2025, 12, 31),
    },
    {
      'id': '2',
      'title': 'Launch new mobile app',
      'description':
          'Develop and release the new mobile application with all planned features by year-end.',
      'category': 'Product Development',
      'accomplishmentDate': DateTime(2025, 11, 15),
    },
    {
      'id': '3',
      'title': 'Increase sales by 20%',
      'description':
          'Implement new sales strategies and provide advanced training to the sales team to boost revenue.',
      'category': 'Sales',
      'accomplishmentDate': DateTime(2025, 12, 31),
    },
    {
      'id': '4',
      'title': 'Improve customer satisfaction score',
      'description':
          'Conduct a comprehensive review of support channels and implement new training protocols for the support team.',
      'category': 'Customer Support',
      'accomplishmentDate': DateTime(2025, 10, 30),
    },
  ];

  final List<String> _goalCategories = [
    'Sales',
    'Marketing',
    'Product Development',
    'Customer Support',
    'Financial',
    'Employee Wellness',
  ];

  void _showCreateGoalDialog({Map<String, dynamic>? goalToEdit}) {
    showDialog(
      context: context,
      builder: (context) {
        return _GoalCreationDialog(
          goalToEdit: goalToEdit,
          goalCategories: _goalCategories,
          onSave: (Map<String, dynamic> newGoal) {
            setState(() {
              if (goalToEdit == null) {
                _allGoals.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  ...newGoal,
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal created successfully!')),
                );
              } else {
                final index = _allGoals.indexWhere(
                  (element) => element['id'] == goalToEdit['id'],
                );
                if (index != -1) {
                  _allGoals[index] = {..._allGoals[index], ...newGoal};
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal updated successfully!')),
                );
              }
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _confirmDeleteGoal(String goalId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this goal?'),
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
                  _allGoals.removeWhere((goal) => goal['id'] == goalId);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Goal deleted successfully!')),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Organization Goals',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 24.sp),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child:
            _allGoals.isEmpty
                ? Center(
                  child: Text(
                    'No goals found. Tap the button to create one!',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
                : ListView.builder(
                  itemCount: _allGoals.length,
                  itemBuilder: (context, index) {
                    final goal = _allGoals[index];
                    final bool isLast = index == _allGoals.length - 1;
                    return _GoalTimelineItem(
                      goal: goal,
                      isLast: isLast,
                      onEdit: () => _showCreateGoalDialog(goalToEdit: goal),
                      onDelete: () => _confirmDeleteGoal(goal['id']),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGoalDialog(),
        label: const Text('Create Goal'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

class _GoalTimelineItem extends StatelessWidget {
  final Map<String, dynamic> goal;
  final bool isLast;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalTimelineItem({
    required this.goal,
    required this.isLast,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime accomplishmentDate = goal['accomplishmentDate'] as DateTime;
    final String formattedDate =
        '${accomplishmentDate.day}/${accomplishmentDate.month}/${accomplishmentDate.year}';
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2),
                    width: 4.w,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.4),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          // Goal content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Accomplishment Date
                  Text(
                    formattedDate,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          goal['title'] as String,
                          style: GoogleFonts.lato(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            onEdit();
                          } else if (value == 'delete') {
                            onDelete();
                          }
                        },
                        itemBuilder:
                            (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    goal['description'] as String,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.category,
                        size: 16.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        goal['category'] as String,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCreationDialog extends StatefulWidget {
  final Map<String, dynamic>? goalToEdit;
  final List<String> goalCategories;
  final Function(Map<String, dynamic>) onSave;

  const _GoalCreationDialog({
    this.goalToEdit,
    required this.goalCategories,
    required this.onSave,
  });

  @override
  __GoalCreationDialogState createState() => __GoalCreationDialogState();
}

class __GoalCreationDialogState extends State<_GoalCreationDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.goalToEdit != null) {
      _titleController.text = widget.goalToEdit!['title'] as String;
      _descriptionController.text = widget.goalToEdit!['description'] as String;
      _selectedCategory = widget.goalToEdit!['category'] as String;
      _selectedDate = widget.goalToEdit!['accomplishmentDate'] as DateTime;
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCategoryBottomSheet() {
    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return _CategorySelectionBottomSheet(categories: widget.goalCategories);
      },
    ).then((selected) {
      if (selected != null) {
        setState(() {
          _selectedCategory = selected;
        });
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.goalToEdit == null ? 'Create Goal' : 'Edit Goal',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final newGoal = {
                    'title': _titleController.text,
                    'description': _descriptionController.text,
                    'category': _selectedCategory,
                    'accomplishmentDate': _selectedDate,
                  };
                  widget.onSave(newGoal);
                }
              },
              icon: Icon(widget.goalToEdit == null ? Icons.add : Icons.save),
              label: Text(widget.goalToEdit == null ? 'Create' : 'Save'),
            ),
            SizedBox(width: 8.w),
          ],
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Goal Title',
                    hintText: 'e.g., Increase sales by 20%',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Title is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Provide a detailed description of the goal',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  maxLines: null, // Allow multiple lines
                ),
                SizedBox(height: 16.h),
                _buildSelectableField(
                  context,
                  label: 'Category',
                  value: _selectedCategory,
                  onTap: _showCategoryBottomSheet,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Category is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),
                _buildSelectableField(
                  context,
                  label: 'Accomplishment Date',
                  value:
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : null,
                  onTap: _selectDate,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Date is required';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectableField(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
    String? value,
    String? Function(String?)? validator,
  }) {
    return InkWell(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          controller: TextEditingController(text: value),
          readOnly: true,
          validator: validator,
        ),
      ),
    );
  }
}

class _CategorySelectionBottomSheet extends StatefulWidget {
  final List<String> categories;

  const _CategorySelectionBottomSheet({required this.categories});

  @override
  __CategorySelectionBottomSheetState createState() =>
      __CategorySelectionBottomSheetState();
}

class __CategorySelectionBottomSheetState
    extends State<_CategorySelectionBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories =
          widget.categories
              .where((category) => category.toLowerCase().contains(query))
              .toList();
    });
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
                'Select a Category',
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
                  hintText: 'Search categories...',
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
            Expanded(
              child: ListView.builder(
                itemCount: _filteredCategories.length,
                itemBuilder: (context, index) {
                  final category = _filteredCategories[index];
                  return ListTile(
                    title: Text(category),
                    onTap: () {
                      Navigator.pop(context, category);
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
