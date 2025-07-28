import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Skill Model
class Skill {
  final String category;
  final String name;

  Skill({required this.category, required this.name});

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(category: json['category'] as String, name: json['name'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'category': category, 'name': name};
  }

  Skill copyWith({String? category, String? name}) {
    return Skill(category: category ?? this.category, name: name ?? this.name);
  }
}

class SkillsScreen extends StatefulWidget {
  final String? existingSkills;
  final bool isEdit;

  const SkillsScreen({Key? key, this.existingSkills, this.isEdit = false}) : super(key: key);

  @override
  _SkillsScreenState createState() => _SkillsScreenState();
}

class _SkillsScreenState extends State<SkillsScreen> {
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _skillNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Map<String, List<Skill>> _categorizedSkills = {}; // Group skills by category
  String? _skillInDeleteMode; // Stores the name of the skill currently in delete mode

  @override
  void initState() {
    super.initState();
    _loadSkillsData();
  }

  void _loadSkillsData() {
    if (widget.isEdit && widget.existingSkills != null) {
      try {
        final List<dynamic> decoded = jsonDecode(widget.existingSkills!);
        for (var item in decoded) {
          final skill = Skill.fromJson(item as Map<String, dynamic>);
          _categorizedSkills.putIfAbsent(skill.category, () => []).add(skill);
        }
      } catch (e) {
        _categorizedSkills = {};
        print('Error decoding existing skills: $e');
      }
    } else {
      // Dummy data for demonstration
      _categorizedSkills = {
        'Programming Languages': [
          Skill(category: 'Programming Languages', name: 'Dart'),
          Skill(category: 'Programming Languages', name: 'Python'),
          Skill(category: 'Programming Languages', name: 'Java'),
          Skill(category: 'Programming Languages', name: 'JavaScript'),
        ],
        'Frameworks & Libraries': [
          Skill(category: 'Frameworks & Libraries', name: 'Flutter'),
          Skill(category: 'Frameworks & Libraries', name: 'React'),
          Skill(category: 'Frameworks & Libraries', name: 'Node.js'),
          Skill(category: 'Frameworks & Libraries', name: 'Spring Boot'),
        ],
        'Tools & Technologies': [
          Skill(category: 'Tools & Technologies', name: 'Git'),
          Skill(category: 'Tools & Technologies', name: 'Docker'),
          Skill(category: 'Tools & Technologies', name: 'Firebase'),
          Skill(category: 'Tools & Technologies', name: 'AWS'),
        ],
        'Soft Skills': [Skill(category: 'Soft Skills', name: 'Teamwork'), Skill(category: 'Soft Skills', name: 'Communication'), Skill(category: 'Soft Skills', name: 'Problem-solving'), Skill(category: 'Soft Skills', name: 'Leadership')],
      };
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _skillNameController.dispose();
    super.dispose();
  }

  void _toggleDeleteOverlay(String skillName) {
    setState(() {
      _skillInDeleteMode = (_skillInDeleteMode == skillName) ? null : skillName;
    });
  }

  void _deleteSkill(String category, String skillName) {
    setState(() {
      _categorizedSkills[category]?.removeWhere((skill) => skill.name == skillName);
      // Remove category if it becomes empty
      if (_categorizedSkills[category]?.isEmpty ?? false) {
        _categorizedSkills.remove(category);
      }
      _skillInDeleteMode = null; // Exit delete mode after deletion
    });
  }

  void _showAddSkillBottomSheet() {
    _categoryController.clear();
    _skillNameController.clear();

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
                    Text('Add New Skill', style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 8.h),
                    Text('Enter the skill and its category.', style: Theme.of(context).textTheme.bodyLarge),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _skillNameController,
                      decoration: InputDecoration(labelText: 'Skill Name', helperText: 'e.g., UI/UX Design, Public Speaking', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a skill name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: _categoryController,
                      decoration: InputDecoration(labelText: 'Category', helperText: 'e.g., Programming Languages, Soft Skills (Case Sensitive)', labelStyle: Theme.of(context).textTheme.labelMedium),
                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a category';
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
                            _clearBottomSheetFields();
                          },
                          child: Text('Cancel', style: Theme.of(context).textTheme.labelMedium),
                        ),
                        SizedBox(width: 16.w),
                        FilledButton.icon(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              final newSkillName = _skillNameController.text.trim();
                              final newCategory = _categoryController.text.trim();

                              final newSkill = Skill(category: newCategory, name: newSkillName);

                              setState(() {
                                _categorizedSkills.putIfAbsent(newCategory, () => []).add(newSkill);
                              });
                              Navigator.of(context).pop();
                              _clearBottomSheetFields();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                          icon: Icon(Icons.add, size: 18.sp, color: Theme.of(context).colorScheme.onPrimary),
                          label: Text('Add Skill', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
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

  void _clearBottomSheetFields() {
    _categoryController.clear();
    _skillNameController.clear();
  }

  void _saveSkills() {
    // Flatten the map into a list of Skill objects for JSON encoding
    final List<Skill> allSkills = [];
    _categorizedSkills.forEach((category, skills) {
      allSkills.addAll(skills);
    });
    final skillsJson = jsonEncode(allSkills.map((skill) => skill.toJson()).toList());
    Navigator.of(context).pop(skillsJson);
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
            onPressed: _saveSkills, // Back button always saves and pops
          ),
          title: Text(widget.isEdit ? 'Edit Skills' : 'Skills', style: Theme.of(context).textTheme.headlineMedium),
          centerTitle: true,
          actions: [IconButton(icon: Icon(Icons.add, size: 24.sp, color: Theme.of(context).colorScheme.onSurface), onPressed: _showAddSkillBottomSheet)],
        ),
      ),
      body:
          _categorizedSkills.isEmpty
              ? const EmptySkillsWidget()
              : SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children:
                        _categorizedSkills.keys.map((category) {
                          final skills = _categorizedSkills[category]!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(padding: EdgeInsets.only(top: 8.h, bottom: 8.h), child: Text(category, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface))),
                              Wrap(
                                spacing: 8.w, // Horizontal spacing between chips
                                runSpacing: 8.h, // Vertical spacing between rows of chips
                                children:
                                    skills.map((skill) {
                                      final bool isSkillSelectedForDelete = _skillInDeleteMode == skill.name;
                                      return GestureDetector(
                                        onTap: () => _toggleDeleteOverlay(skill.name),
                                        child: Chip(
                                          elevation: 2.0, // Slight elevation for chips
                                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                          backgroundColor: Theme.of(context).colorScheme.secondaryContainer, // Darker background for chips
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20.r), // Rounded corners for chips
                                          ),
                                          label: Text(skill.name, style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSecondaryContainer, fontWeight: FontWeight.w500)),
                                          // Show delete icon as a trailing icon if in delete mode
                                          deleteIcon: isSkillSelectedForDelete ? Icon(Icons.cancel, size: 18.sp, color: Theme.of(context).colorScheme.error) : null,
                                          onDeleted: isSkillSelectedForDelete ? () => _deleteSkill(category, skill.name) : null,
                                          side: isSkillSelectedForDelete ? BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5) : BorderSide.none,
                                        ),
                                      );
                                    }).toList(),
                              ),
                              SizedBox(height: 16.h), // Spacing between categories
                            ],
                          );
                        }).toList(),
                  ),
                ),
              ),
    );
  }
}

class EmptySkillsWidget extends StatelessWidget {
  const EmptySkillsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 48.h, left: 16.w, right: 16.w, bottom: 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline, // Icon for skills
            size: 64.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text('No Skills Added Yet', style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center),
          SizedBox(height: 8.h),
          Text('Tap the + icon in the top right to add your professional skills.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
