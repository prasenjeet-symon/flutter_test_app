import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Ensure intl is in pubspec.yaml

// --- Models ---
class MissionEntry {
  final String id;
  final String description;
  MissionEntry({required this.id, required this.description});
}

class GoalEntry {
  final String id;
  final String parentMissionId;
  final String category;
  final String subCategory;
  final String description;
  final DateTime accomplishmentDate;

  GoalEntry({
    required this.id,
    required this.parentMissionId,
    required this.category,
    required this.subCategory,
    required this.description,
    required this.accomplishmentDate,
  });
}

class ConfigureGoalsScreen extends StatefulWidget {
  const ConfigureGoalsScreen({super.key});

  @override
  State<ConfigureGoalsScreen> createState() => _ConfigureGoalsScreenState();
}

class _ConfigureGoalsScreenState extends State<ConfigureGoalsScreen> {
  final TextEditingController _goalController = TextEditingController();
  final List<GoalEntry> _allGoalsMasterList = [];

  MissionEntry? _selectedMission;
  String? _selectedCategory;
  String? _selectedSubCategory;
  DateTime? _selectedDate;

  // Mock Data
  final List<MissionEntry> _existingMissions = [
    MissionEntry(
      id: 'm1',
      description: "Launch weekly tech tutorials on LinkedIn.",
    ),
    MissionEntry(
      id: 'm2',
      description: "Engage with 50+ niche influencers monthly.",
    ),
  ];

  final List<String> _categories = [
    "Quantitative",
    "Qualitative",
    "Engagement",
  ];
  final List<String> _subCategories = ["KPIs", "User Growth", "Sentiment"];

  List<GoalEntry> get _currentMissionGoals {
    if (_selectedMission == null) return [];
    return _allGoalsMasterList
        .where((g) => g.parentMissionId == _selectedMission!.id)
        .toList();
  }

  void _addGoal() {
    if (_goalController.text.isNotEmpty &&
        _selectedMission != null &&
        _selectedCategory != null &&
        _selectedSubCategory != null &&
        _selectedDate != null) {
      setState(() {
        _allGoalsMasterList.insert(
          0,
          GoalEntry(
            id: DateTime.now().toString(),
            parentMissionId: _selectedMission!.id,
            category: _selectedCategory!,
            subCategory: _selectedSubCategory!,
            description: _goalController.text.trim(),
            accomplishmentDate: _selectedDate!,
          ),
        );
        _goalController.clear();
        _selectedCategory = null;
        _selectedSubCategory = null;
        _selectedDate = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 120.h),
                children: [
                  _buildHeader(context),
                  SizedBox(height: 24.h),

                  _buildSelectorTile(
                    "Target Mission",
                    _selectedMission?.description,
                    _openMissionSheet,
                    isDarker: false,
                    hint: "Select mission to define goals",
                    icon: Icons.rocket_launch_rounded,
                  ),

                  SizedBox(height: 24.h),

                  Opacity(
                    opacity: _selectedMission == null ? 0.5 : 1.0,
                    child: IgnorePointer(
                      ignoring: _selectedMission == null,
                      child: _buildInputCard(context),
                    ),
                  ),

                  SizedBox(height: 32.h),
                  _buildSummaryHeader(colorScheme),
                  SizedBox(height: 16.h),

                  if (_selectedMission == null)
                    _buildPlaceholderState(
                      "Select a mission above to view goals",
                    )
                  else if (_currentMissionGoals.isEmpty)
                    _buildPlaceholderState("No goals defined for this mission")
                  else
                    ..._currentMissionGoals
                        .map((e) => _buildGoalListItem(context, e))
                        .toList(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildInputCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSelectorTile(
                  "Category",
                  _selectedCategory,
                  () => _openSelectionSheet(
                    "Category",
                    _categories,
                    (val) => setState(() => _selectedCategory = val),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildSelectorTile(
                  "Sub Type",
                  _selectedSubCategory,
                  () => _openSelectionSheet(
                    "Sub Category",
                    _subCategories,
                    (val) => setState(() => _selectedSubCategory = val),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // --- Accomplishment Date Selector ---
          _buildSelectorTile(
            "Accomplishment Date",
            _selectedDate != null
                ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                : null,
            () => _selectDate(context),
            icon: Icons.calendar_today_rounded,
          ),
          SizedBox(height: 20.h),
          Text(
            "Goal Description",
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _goalController,
            maxLines: 2,
            style: GoogleFonts.lato(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: "Enter measurable goal...",
              filled: true,
              fillColor: colorScheme.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _addGoal,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "Set Goal",
                style: GoogleFonts.lato(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalListItem(BuildContext context, GoalEntry entry) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildSmallBadge(entry.category, colorScheme.primary),
                  SizedBox(width: 8.w),
                  _buildSmallBadge(entry.subCategory, colorScheme.secondary),
                ],
              ),
              GestureDetector(
                onTap: () => setState(() => _allGoalsMasterList.remove(entry)),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.sp,
                    color: colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            entry.description,
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              color: colorScheme.onSurface,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          // --- Date Metadata Row ---
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                size: 14.sp,
                color: colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                "Due by ${DateFormat('MMM dd, yyyy').format(entry.accomplishmentDate)}",
                style: GoogleFonts.lato(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Reusable Helper UI ---

  Widget _buildSelectorTile(
    String label,
    String? value,
    VoidCallback onTap, {
    bool isDarker = true,
    String hint = "Select",
    IconData icon = Icons.unfold_more_rounded,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color:
                  isDarker
                      ? colorScheme.surfaceContainerHigh
                      : colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
              boxShadow:
                  !isDarker
                      ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                      : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: GoogleFonts.lato(
                      fontSize: 13.sp,
                      color:
                          value == null
                              ? colorScheme.onSurfaceVariant.withOpacity(0.6)
                              : colorScheme.onSurface,
                      fontWeight:
                          value == null ? FontWeight.normal : FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 18.sp, color: colorScheme.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "STEP 03",
        style: GoogleFonts.lato(
          fontSize: 13.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Target Goals",
          style: GoogleFonts.lato(
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          "Set clear timelines and measurable metrics.",
          style: GoogleFonts.lato(
            fontSize: 15.sp,
            color: Theme.of(
              context,
            ).colorScheme.onSurfaceVariant.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.lato(
          fontSize: 9.sp,
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(ColorScheme colorScheme) => Row(
    children: [
      Icon(
        Icons.track_changes_rounded,
        size: 18.sp,
        color: colorScheme.primary,
      ),
      SizedBox(width: 8.w),
      Text(
        "Success Targets",
        style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.w900),
      ),
    ],
  );

  Widget _buildPlaceholderState(String message) => Padding(
    padding: EdgeInsets.symmetric(vertical: 40.h),
    child: Center(
      child: Text(
        message,
        style: GoogleFonts.lato(
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
      ),
    ),
  );

  Widget _buildBottomBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 34.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: _allGoalsMasterList.isEmpty ? null : () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 0,
          ),
          child: Text(
            "Proceed to Problems",
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  void _openSelectionSheet(
    String title,
    List<String> options,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _SearchSelectionSheet(
            title: title,
            options: options,
            onSelect: onSelect,
          ),
    );
  }

  void _openMissionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _MissionSelectionSheet(
            missions: _existingMissions,
            onSelect: (m) => setState(() => _selectedMission = m),
          ),
    );
  }
}

// --- Sheets remain identical to the previous implementation ---
class _MissionSelectionSheet extends StatelessWidget {
  final List<MissionEntry> missions;
  final Function(MissionEntry) onSelect;
  const _MissionSelectionSheet({
    required this.missions,
    required this.onSelect,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Text(
            "Target Mission",
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 16.h),
          ...missions
              .map(
                (m) => ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 4.h,
                  ),
                  title: Text(
                    m.description,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onTap: () {
                    onSelect(m);
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}

class _SearchSelectionSheet extends StatefulWidget {
  final String title;
  final List<String> options;
  final Function(String) onSelect;
  const _SearchSelectionSheet({
    required this.title,
    required this.options,
    required this.onSelect,
  });
  @override
  State<_SearchSelectionSheet> createState() => _SearchSelectionSheetState();
}

class _SearchSelectionSheetState extends State<_SearchSelectionSheet> {
  late List<String> filteredOptions;
  final TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    filteredOptions = widget.options;
    searchController.addListener(() {
      setState(
        () =>
            filteredOptions =
                widget.options
                    .where(
                      (e) => e.toLowerCase().contains(
                        searchController.text.toLowerCase(),
                      ),
                    )
                    .toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select ${widget.title}",
                  style: GoogleFonts.lato(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: TextField(
              controller: searchController,
              style: GoogleFonts.lato(fontSize: 15.sp),
              decoration: InputDecoration(
                hintText: "Search items...",
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredOptions.length,
              itemBuilder:
                  (context, index) => ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 24.w),
                    title: Text(
                      filteredOptions[index],
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.sp,
                      ),
                    ),
                    onTap: () {
                      widget.onSelect(filteredOptions[index]);
                      Navigator.pop(context);
                    },
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
