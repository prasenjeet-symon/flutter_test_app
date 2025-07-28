import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // For date formatting

// Model for User Goal
class UserGoal {
  String id; // Unique ID for each goal, useful for list operations
  String goalText;
  DateTime achieveByDate;

  UserGoal({required this.id, required this.goalText, required this.achieveByDate});

  // Factory constructor for creating a UserGoal from a JSON map
  factory UserGoal.fromJson(Map<String, dynamic> json) {
    return UserGoal(id: json['id'] as String, goalText: json['goalText'] as String, achieveByDate: DateTime.parse(json['achieveByDate'] as String));
  }

  // Method for converting a UserGoal to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalText': goalText,
      'achieveByDate': achieveByDate.toIso8601String(), // Store as ISO 8601 string
    };
  }
}

class GoalScreen extends StatefulWidget {
  // Now expects a List of existing goals
  final List<Map<String, dynamic>>? existingData;

  const GoalScreen({Key? key, this.existingData}) : super(key: key);

  @override
  _GoalScreenState createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final TextEditingController _goalTextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedAchieveByDate;

  List<UserGoal> _userGoals = []; // List to hold multiple goals

  @override
  void initState() {
    super.initState();
    _loadGoalData();
  }

  void _loadGoalData() {
    if (widget.existingData != null) {
      _userGoals = widget.existingData!.map((data) => UserGoal.fromJson(data)).toList();
    }
  }

  @override
  void dispose() {
    _goalTextController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedAchieveByDate ?? DateTime.now(),
      firstDate: DateTime.now(), // Cannot pick a date in the past
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary, // Header background color
              onPrimary: Theme.of(context).colorScheme.onPrimary, // Header text color
              onSurface: Theme.of(context).colorScheme.onSurface, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedAchieveByDate) {
      setState(() {
        _selectedAchieveByDate = picked;
      });
    }
  }

  // Simplified to only add new goals
  void _showAddGoalFormBottomSheet() {
    _goalTextController.clear();
    _selectedAchieveByDate = null; // Reset date for new entry

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
                    Text('Add New Goal', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text('Define a specific, measurable goal and when you plan to achieve it.', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _goalTextController,
                      decoration: InputDecoration(labelText: 'What is your goal?', helperText: 'e.g., Run a marathon, Learn a new language, Save for a down payment', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your goal';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(_selectedAchieveByDate == null ? 'Achieve By: Select Date' : 'Achieve By: ${DateFormat.yMMMd().format(_selectedAchieveByDate!)}', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface)),
                      trailing: Icon(Icons.calendar_today, size: 20.sp, color: Theme.of(context).colorScheme.primary),
                      onTap: () => _selectDate(context),
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _goalTextController.clear();
                            _selectedAchieveByDate = null; // Clear selected date on cancel
                          },
                          child: Text('Cancel', style: Theme.of(context).textTheme.labelMedium),
                        ),
                        SizedBox(width: 16.w),
                        FilledButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate() && _selectedAchieveByDate != null) {
                              setState(() {
                                _userGoals.add(
                                  UserGoal(
                                    id: DateTime.now().microsecondsSinceEpoch.toString(), // Unique ID
                                    goalText: _goalTextController.text.trim(),
                                    achieveByDate: _selectedAchieveByDate!,
                                  ),
                                );
                              });
                              Navigator.of(context).pop();
                              _goalTextController.clear();
                              _selectedAchieveByDate = null; // Clear selected date after saving
                            } else if (_selectedAchieveByDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select an "Achieve By" date.'), backgroundColor: Theme.of(context).colorScheme.error));
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: Icon(
                            Icons.add, // Always "Add" icon
                            size: 18.sp,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          label: Text(
                            'Add Goal', // Always "Add Goal"
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary),
                          ),
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

  void _confirmDeleteGoal(UserGoal goalToDelete) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Goal?', style: Theme.of(context).textTheme.titleLarge),
            content: Text('Are you sure you want to delete "${goalToDelete.goalText}"?', style: Theme.of(context).textTheme.bodyMedium),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge)),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _userGoals.removeWhere((goal) => goal.id == goalToDelete.id);
                  });
                  Navigator.of(context).pop();
                },
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r))),
                child: Text('Delete', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onError, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
    );
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
            onPressed: () {
              // On back, return the list of goals data
              Navigator.of(context).pop(_userGoals.map((goal) => goal.toJson()).toList());
            },
          ),
          title: Text(
            'My Goals', // Title adjusted for multiple goals
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(Icons.add, size: 24.sp, color: Theme.of(context).colorScheme.onSurface),
              onPressed: () => _showAddGoalFormBottomSheet(), // Always adds a new goal
            ),
          ],
        ),
      ),
      body:
          _userGoals.isEmpty
              ? const EmptyGoalWidget()
              : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Wrap(
                  spacing: 6.w, // Reduced horizontal space between chips
                  runSpacing: 6.h, // Reduced vertical space between rows of chips
                  children:
                      _userGoals.map((goal) {
                        return Chip(
                          visualDensity: VisualDensity.compact, // Make the chip itself more compact
                          avatar: Icon(
                            Icons.star_outline, // Star icon on the left
                            size: 18.sp, // Slightly smaller icon
                            color: Theme.of(context).colorScheme.primary, // Consistent with Core Values avatar color
                          ),
                          labelPadding: EdgeInsets.symmetric(horizontal: 4.w), // Reduced padding around label
                          label: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min, // To keep column compact
                            children: [
                              Text(
                                goal.goalText,
                                style: TextStyle(
                                  fontSize: 13.sp, // Slightly smaller font size
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 2, // Allow goal text to wrap
                                overflow: TextOverflow.ellipsis, // Add ellipsis if too long
                              ),
                              SizedBox(height: 1.h), // Reduced space
                              Text(
                                'By: ${DateFormat.yMMMd().format(goal.achieveByDate)}',
                                style: TextStyle(
                                  fontSize: 10.sp, // Even smaller for date
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer, // Same as Core Values chips
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.r), // Slightly more compact rounding
                          ),
                          side: BorderSide.none, // No border, consistent with Core Values
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h), // Reduced overall chip padding
                          onDeleted: () => _confirmDeleteGoal(goal), // Delete icon on the right
                          deleteIcon: Icon(Icons.close, size: 16.sp, color: Theme.of(context).colorScheme.error), // Cross icon, slightly smaller
                        );
                      }).toList(),
                ),
              ),
    );
  }
}

class EmptyGoalWidget extends StatelessWidget {
  const EmptyGoalWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 48.h, left: 16.w, right: 16.w, bottom: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline, // Icon for empty state goal
            size: 64.sp,
            color: Theme.of(context).colorScheme.tertiary, // tertiary color for goal-related icons
          ),
          SizedBox(height: 16.h),
          Text(
            'Set Your Goals', // Title adjusted for multiple goals
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text('What do you want to achieve? Tap the + icon to add your first goal and set a target date.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
