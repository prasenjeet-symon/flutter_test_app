import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Models ---
class PurposeEntry {
  final String id;
  final String description;
  PurposeEntry({required this.id, required this.description});
}

class MissionEntry {
  final String id;
  final String parentPurposeId;
  final String category;
  final String subCategory;
  final String description;

  MissionEntry({
    required this.id,
    required this.parentPurposeId,
    required this.category,
    required this.subCategory,
    required this.description,
  });
}

class ConfigureMissionScreen extends StatefulWidget {
  const ConfigureMissionScreen({super.key});

  @override
  State<ConfigureMissionScreen> createState() => _ConfigureMissionScreenState();
}

class _ConfigureMissionScreenState extends State<ConfigureMissionScreen> {
  final TextEditingController _missionController = TextEditingController();

  // Master list of all missions across all purposes
  final List<MissionEntry> _allMissionsMasterList = [];

  PurposeEntry? _selectedPurpose;
  String? _selectedCategory;
  String? _selectedSubCategory;

  // Mock Data from Step 1
  final List<PurposeEntry> _existingPurposes = [
    PurposeEntry(
      id: '1',
      description: "Increase brand awareness in niche tech community.",
    ),
    PurposeEntry(
      id: '2',
      description: "Drive high-quality lead conversion for SaaS product.",
    ),
  ];

  final List<String> _categories = [
    "Operational",
    "Strategic",
    "Tactical",
    "Growth",
  ];
  final List<String> _subCategories = [
    "Daily Tasks",
    "Product Launch",
    "Campaigns",
    "Retention",
  ];

  // Logic: Get only missions for the active purpose
  List<MissionEntry> get _currentPurposeMissions {
    if (_selectedPurpose == null) return [];
    return _allMissionsMasterList
        .where((m) => m.parentPurposeId == _selectedPurpose!.id)
        .toList();
  }

  void _addMission() {
    if (_missionController.text.isNotEmpty &&
        _selectedPurpose != null &&
        _selectedCategory != null &&
        _selectedSubCategory != null) {
      setState(() {
        _allMissionsMasterList.insert(
          0,
          MissionEntry(
            id: DateTime.now().toString(),
            parentPurposeId: _selectedPurpose!.id,
            category: _selectedCategory!,
            subCategory: _selectedSubCategory!,
            description: _missionController.text.trim(),
          ),
        );
        _missionController.clear();
        _selectedCategory = null;
        _selectedSubCategory = null;
      });
    }
  }

  void _deleteMission(String id) {
    setState(() {
      _allMissionsMasterList.removeWhere((m) => m.id == id);
    });
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

                  // --- Target Purpose Selector ---
                  _buildSelectorTile(
                    "Target Purpose",
                    _selectedPurpose?.description,
                    _openPurposeSheet,
                    isDarker: false,
                    hint: "Select purpose to configure missions",
                  ),

                  SizedBox(height: 24.h),

                  // --- Mission Input Card ---
                  Opacity(
                    opacity: _selectedPurpose == null ? 0.5 : 1.0,
                    child: IgnorePointer(
                      ignoring: _selectedPurpose == null,
                      child: _buildInputCard(context),
                    ),
                  ),

                  SizedBox(height: 32.h),
                  _buildSummaryHeader(colorScheme),
                  SizedBox(height: 16.h),

                  // --- Filtered List Display ---
                  if (_selectedPurpose == null)
                    _buildPlaceholderState(
                      "Select a purpose above to view missions",
                    )
                  else if (_currentPurposeMissions.isEmpty)
                    _buildPlaceholderState("No missions added for this purpose")
                  else
                    ..._currentPurposeMissions
                        .map((e) => _buildMissionListItem(context, e))
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

  // --- UI Components ---

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        "CONFIGURATOR",
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
          "Define Missions",
          style: GoogleFonts.lato(
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          "Create actionable steps tied to your selected purpose.",
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
            "Description",
            style: GoogleFonts.lato(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _missionController,
            maxLines: 3,
            style: GoogleFonts.lato(fontSize: 14.sp),
            decoration: InputDecoration(
              hintText: "What actions will be taken?",
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withOpacity(0.4),
              ),
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
              onPressed: _addMission,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "Add to Roadmap",
                style: GoogleFonts.lato(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTile(
    String label,
    String? value,
    VoidCallback onTap, {
    bool isDarker = true,
    String hint = "Select",
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
                Icon(
                  Icons.unfold_more_rounded,
                  size: 18.sp,
                  color: colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionListItem(BuildContext context, MissionEntry entry) {
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
                onTap: () => _deleteMission(entry.id),
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

  Widget _buildSummaryHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(
          Icons.rocket_launch_rounded,
          size: 18.sp,
          color: colorScheme.primary,
        ),
        SizedBox(width: 8.w),
        Text(
          "Roadmap Summary",
          style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _buildPlaceholderState(String message) {
    return Padding(
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
  }

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
          onPressed:
              _allMissionsMasterList.isEmpty
                  ? null
                  : () {
                    // Logic for Step 3: Goals
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 0,
          ),
          child: Text(
            "Proceed to Goals",
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  // --- Search & Selection Sheets ---

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

  void _openPurposeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _PurposeSelectionSheet(
            purposes: _existingPurposes,
            onSelect: (p) => setState(() => _selectedPurpose = p),
          ),
    );
  }
}

// --- Specific Purpose Picker Sheet ---
class _PurposeSelectionSheet extends StatelessWidget {
  final List<PurposeEntry> purposes;
  final Function(PurposeEntry) onSelect;

  const _PurposeSelectionSheet({
    required this.purposes,
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
            "Target Purpose",
            style: GoogleFonts.lato(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 16.h),
          ...purposes
              .map(
                (p) => ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 4.h,
                  ),
                  title: Text(
                    p.description,
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
                    onSelect(p);
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

// --- Generic Generic Search Sheet ---
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
                  icon: Icon(Icons.close_rounded),
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
                prefixIcon: Icon(Icons.search_rounded),
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
