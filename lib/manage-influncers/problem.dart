import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Models ---
class GoalEntry {
  final String id;
  final String description;
  GoalEntry({required this.id, required this.description});
}

class ProblemEntry {
  final String id;
  final String parentGoalId;
  final String category;
  final String subCategory;
  final String description;

  ProblemEntry({
    required this.id,
    required this.parentGoalId,
    required this.category,
    required this.subCategory,
    required this.description,
  });
}

class ConfigureProblemsScreen extends StatefulWidget {
  const ConfigureProblemsScreen({super.key});

  @override
  State<ConfigureProblemsScreen> createState() =>
      _ConfigureProblemsScreenState();
}

class _ConfigureProblemsScreenState extends State<ConfigureProblemsScreen> {
  final TextEditingController _problemController = TextEditingController();

  // State lists
  final List<ProblemEntry> _allProblemsMasterList = [];

  GoalEntry? _selectedGoal;
  String? _selectedCategory;
  String? _selectedSubCategory;

  // Mock Data
  final List<GoalEntry> _existingGoals = [
    GoalEntry(id: 'g1', description: "Reach 10k followers by Q3."),
    GoalEntry(
      id: 'g2',
      description: "Maintain 5% engagement rate on tutorials.",
    ),
  ];

  final List<String> _categories = [
    "Market",
    "Technical",
    "Resource",
    "Content",
  ];
  final List<String> _subCategories = [
    "High Competition",
    "Algorithm Shift",
    "Budget",
    "Production",
  ];

  // Logic: Filter based on selected Goal
  List<ProblemEntry> get _currentGoalProblems {
    if (_selectedGoal == null) return [];
    return _allProblemsMasterList
        .where((p) => p.parentGoalId == _selectedGoal!.id)
        .toList();
  }

  void _addProblem() {
    if (_problemController.text.isNotEmpty &&
        _selectedGoal != null &&
        _selectedCategory != null &&
        _selectedSubCategory != null) {
      setState(() {
        _allProblemsMasterList.insert(
          0,
          ProblemEntry(
            id: DateTime.now().toString(),
            parentGoalId: _selectedGoal!.id,
            category: _selectedCategory!,
            subCategory: _selectedSubCategory!,
            description: _problemController.text.trim(),
          ),
        );
        _problemController.clear();
        _selectedCategory = null;
        _selectedSubCategory = null;
      });
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

                  // --- Parent Goal Selector ---
                  _buildSelectorTile(
                    "Target Goal",
                    _selectedGoal?.description,
                    _openGoalSheet,
                    isDarker: false,
                    hint: "Select goal to identify problems",
                    icon: Icons.track_changes_rounded,
                  ),

                  SizedBox(height: 24.h),

                  // --- Problem Input Card ---
                  Opacity(
                    opacity: _selectedGoal == null ? 0.5 : 1.0,
                    child: IgnorePointer(
                      ignoring: _selectedGoal == null,
                      child: _buildInputCard(context),
                    ),
                  ),

                  SizedBox(height: 32.h),
                  _buildSummaryHeader(colorScheme),
                  SizedBox(height: 16.h),

                  if (_selectedGoal == null)
                    _buildPlaceholderState(
                      "Select a goal above to view problems",
                    )
                  else if (_currentGoalProblems.isEmpty)
                    _buildPlaceholderState(
                      "No problems identified for this goal",
                    )
                  else
                    ..._currentGoalProblems
                        .map((e) => _buildProblemListItem(context, e))
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

  // --- REFINED INPUT CARD ---
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
                  "Sub Category",
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
          SizedBox(height: 20.h),
          Text(
            "Problem Description",
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _problemController,
            maxLines: 3,
            style: GoogleFonts.lato(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: "What challenges are you facing?",
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.35),
              ),
              filled: true,
              // --- REDUCED BACKGROUND & VISIBLE BORDER ---
              fillColor: colorScheme.onSurface.withOpacity(0.02),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: colorScheme.primary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              contentPadding: EdgeInsets.all(16.w),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _addProblem,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "Add Problem",
                style: GoogleFonts.lato(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REFINED SELECTOR TILE ---
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
              // --- REDUCED BACKGROUND & VISIBLE BORDER ---
              color:
                  isDarker
                      ? colorScheme.onSurface.withOpacity(0.02)
                      : colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
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
                              ? colorScheme.onSurfaceVariant.withOpacity(0.5)
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

  Widget _buildProblemListItem(BuildContext context, ProblemEntry entry) {
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
                onTap:
                    () => setState(
                      () => _allProblemsMasterList.removeWhere(
                        (p) => p.id == entry.id,
                      ),
                    ),
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
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- Static UI Components ---

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      "STRATEGY",
      style: GoogleFonts.lato(
        fontSize: 13.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
    centerTitle: true,
  );

  Widget _buildHeader(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Roadmap Obstacles",
        style: GoogleFonts.lato(
          fontSize: 28.sp,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
      ),
      SizedBox(height: 4.h),
      Text(
        "Identify challenges linked to your strategic goals.",
        style: GoogleFonts.lato(
          fontSize: 15.sp,
          color: Theme.of(
            context,
          ).colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
      ),
    ],
  );

  Widget _buildSmallBadge(String text, Color color) => Container(
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

  Widget _buildSummaryHeader(ColorScheme colorScheme) => Row(
    children: [
      Icon(
        Icons.report_problem_rounded,
        size: 18.sp,
        color: colorScheme.primary,
      ),
      SizedBox(width: 8.w),
      Text(
        "Defined Problems",
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
          onPressed: _allProblemsMasterList.isEmpty ? null : () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 0,
          ),
          child: Text(
            "Finalize Configuration",
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  // --- Bottom Sheets ---

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

  void _openGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _GoalSelectionSheet(
            goals: _existingGoals,
            onSelect: (g) => setState(() => _selectedGoal = g),
          ),
    );
  }
}

// --- Specific Selection Sheets (UI Preserved) ---
class _GoalSelectionSheet extends StatelessWidget {
  final List<GoalEntry> goals;
  final Function(GoalEntry) onSelect;
  const _GoalSelectionSheet({required this.goals, required this.onSelect});
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
            "Target Goal",
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 16.h),
          ...goals.map(
            (g) => ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 4.h,
              ),
              title: Text(
                g.description,
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
              ),
              onTap: () {
                onSelect(g);
                Navigator.pop(context);
              },
            ),
          ),
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
