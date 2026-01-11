import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Model ---
class InfluencerUser {
  final String fullName;
  final String userId;
  final String? profilePicUrl;
  final String gender;

  InfluencerUser({
    required this.fullName,
    required this.userId,
    this.profilePicUrl,
    required this.gender,
  });
}

class SearchExistingInfluencerScreen extends StatefulWidget {
  const SearchExistingInfluencerScreen({super.key});

  @override
  State<SearchExistingInfluencerScreen> createState() =>
      _SearchExistingInfluencerScreenState();
}

class _SearchExistingInfluencerScreenState
    extends State<SearchExistingInfluencerScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<InfluencerUser> _allUsers = [];
  List<InfluencerUser> _filteredUsers = [];
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _loadDummyUsers();
    _searchController.addListener(_onSearchChanged);
  }

  void _loadDummyUsers() {
    _allUsers = [
      InfluencerUser(
        fullName: 'Marcus Aurelius',
        userId: 'marcus_philosopher',
        gender: 'Male',
        profilePicUrl: 'https://picsum.photos/id/1011/200/200',
      ),
      InfluencerUser(
        fullName: 'Ada Lovelace',
        userId: 'ada_codes',
        gender: 'Female',
        profilePicUrl: 'https://picsum.photos/id/64/200/200',
      ),
      InfluencerUser(
        fullName: 'Socrates Greek',
        userId: 'socrates_wisdom',
        gender: 'Male',
        profilePicUrl: 'https://picsum.photos/id/1027/200/200',
      ),
      InfluencerUser(
        fullName: 'Marie Curie',
        userId: 'marie_rad',
        gender: 'Female',
        profilePicUrl: 'https://picsum.photos/id/1025/200/200',
      ),
      InfluencerUser(
        fullName: 'Hypatia Alex',
        userId: 'hypatia_math',
        gender: 'Female',
        profilePicUrl: 'https://picsum.photos/id/325/200/200',
      ),
    ];
    _filteredUsers = _allUsers;
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers =
          _allUsers.where((u) {
            return u.fullName.toLowerCase().contains(query) ||
                u.userId.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        toolbarHeight: 56.h,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.sp,
            color: colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Find Influencer",
          style: GoogleFonts.lato(fontSize: 20.sp, fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          // --- Compact Search Header ---
          Container(
            color: colorScheme.surface,
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.lato(fontSize: 14.sp),
              decoration: InputDecoration(
                hintText: "Search name or @userid",
                hintStyle: GoogleFonts.lato(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                  size: 20.sp,
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
              ),
            ),
          ),

          Divider(
            height: 1.h,
            thickness: 1,
            color: colorScheme.outline.withOpacity(0.05),
          ),

          // --- Compact User List ---
          Expanded(
            child:
                _filteredUsers.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                      itemCount: _filteredUsers.length,
                      itemBuilder:
                          (context, index) =>
                              _buildCompactUserCard(_filteredUsers[index]),
                    ),
          ),
        ],
      ),
      bottomNavigationBar:
          _selectedUserId != null ? _buildCompactStickyButton() : null,
    );
  }

  Widget _buildCompactUserCard(InfluencerUser user) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _selectedUserId == user.userId;

    return GestureDetector(
      onTap: () => setState(() => _selectedUserId = user.userId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 1.5.w,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? colorScheme.primary.withOpacity(0.08)
                      : Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // --- Smaller Avatar ---
              _buildCompactProfilePic(user.profilePicUrl),

              SizedBox(width: 12.w),

              // --- Details ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: GoogleFonts.lato(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "@${user.userId}",
                      style: GoogleFonts.lato(
                        fontSize: 12.sp,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    _buildCompactGenderBadge(user.gender),
                  ],
                ),
              ),

              // --- Streamlined Radio Indicator ---
              Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color:
                        isSelected
                            ? colorScheme.primary
                            : colorScheme.outline.withOpacity(0.2),
                    width: 1.5.w,
                  ),
                ),
                child:
                    isSelected
                        ? Icon(
                          Icons.check_rounded,
                          color: colorScheme.onPrimary,
                          size: 14.sp,
                        )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactProfilePic(String? url) {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child:
            url != null
                ? Image.network(url, fit: BoxFit.cover)
                : Icon(
                  Icons.person_outline_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  size: 24.sp,
                ),
      ),
    );
  }

  Widget _buildCompactGenderBadge(String gender) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        gender,
        style: GoogleFonts.lato(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildCompactStickyButton() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: colorScheme.outline.withOpacity(0.08)),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50.h,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          child: Text(
            "Add Selected User",
            style: GoogleFonts.lato(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48.sp,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          ),
          SizedBox(height: 12.h),
          Text(
            "No matches found",
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
