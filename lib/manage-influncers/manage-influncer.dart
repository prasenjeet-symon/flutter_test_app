import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Models ---
enum InfluencerStatus { underReview, rejected, approved }

class Influencer {
  final String fullName;
  final String? profilePicUrl;
  final String dob;
  final String domain;
  final String subDomain;
  final String bio;
  final String gender;
  final InfluencerStatus status;

  Influencer({
    required this.fullName,
    this.profilePicUrl,
    required this.dob,
    required this.domain,
    required this.subDomain,
    required this.bio,
    required this.gender,
    required this.status,
  });
}

// --- Main Screen ---
class InfluencerListScreen extends StatefulWidget {
  const InfluencerListScreen({super.key});

  @override
  State<InfluencerListScreen> createState() => _InfluencerListScreenState();
}

class _InfluencerListScreenState extends State<InfluencerListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  List<Influencer> _allInfluencers = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;

  static const Color _emerald = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && !_isLoading) _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      _allInfluencers = _generateDummyData(0, 10);
      _isLoading = false;
    });
  }

  Future<void> _loadMoreData() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final newData = _generateDummyData(_allInfluencers.length, 10);
    setState(() {
      _allInfluencers.addAll(newData);
      _isLoadingMore = false;
    });
  }

  List<Influencer> _getFilteredList() {
    if (_tabController.index == 0) return _allInfluencers;
    final statusMap = {
      1: InfluencerStatus.approved,
      2: InfluencerStatus.underReview,
      3: InfluencerStatus.rejected,
    };
    return _allInfluencers
        .where((i) => i.status == statusMap[_tabController.index])
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final filteredList = _getFilteredList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        color: colorScheme.primary,
        onRefresh: _loadInitialData,
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : filteredList.isEmpty
                ? _buildEmptyStateTutorial(context)
                : ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                  itemCount: filteredList.length + (_isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == filteredList.length) {
                      return _buildLoadingIndicator();
                    }
                    return _buildInfluencerCard(context, filteredList[index]);
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        icon: Icon(Icons.add_rounded, size: 24.sp),
        label: Text(
          'Add Influencer',
          style: GoogleFonts.lato(fontSize: 15.sp, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Text(
        'Influencers',
        style: GoogleFonts.lato(fontSize: 22.sp, fontWeight: FontWeight.bold),
      ),
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(52.h),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.center,
                indicatorColor: colorScheme.primary,
                indicatorWeight: 3,
                dividerColor: Colors.transparent,
                labelColor: colorScheme.onSurface,
                unselectedLabelColor: colorScheme.onSurfaceVariant.withOpacity(
                  0.4,
                ),
                labelStyle: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: "All Activity"),
                  Tab(text: "Verified"),
                  Tab(text: "Pending"),
                  Tab(text: "Rejected"),
                ],
              ),
            ),
            Divider(
              height: 1.h,
              thickness: 1,
              color: colorScheme.outline.withOpacity(0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfluencerCard(BuildContext context, Influencer influencer) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.45),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                _buildAvatar(context, influencer.profilePicUrl),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        influencer.fullName,
                        style: GoogleFonts.lato(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        "${influencer.domain} — ${influencer.subDomain}",
                        style: GoogleFonts.lato(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusDot(context, influencer.status),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    context,
                    Icons.history_toggle_off_rounded,
                    "Origin",
                    influencer.dob,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildInfoRow(
                    context,
                    _getGenderIcon(influencer.gender),
                    "Gender",
                    influencer.gender,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            child: Text(
              influencer.bio,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateTutorial(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 60.h),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 50.sp,
                color: colorScheme.primary.withOpacity(0.3),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Directory is empty",
              style: GoogleFonts.lato(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Follow these steps to build your directory:",
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 48.h),
            _buildStep(
              context,
              "1",
              "Add Influencer",
              "Create a profile for historical legends or modern stars.",
              true,
            ),
            _buildStep(
              context,
              "2",
              "Admin Verification",
              "Our team will review the details for historical accuracy.",
              true,
            ),
            _buildStep(
              context,
              "3",
              "Go Public",
              "Once verified, the talent is ready for campaigns.",
              false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    String number,
    String title,
    String desc,
    bool hasConnector,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              if (hasConnector)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    color: colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  style: GoogleFonts.lato(
                    fontSize: 13.sp,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 18.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 10.sp,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.lato(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getGenderIcon(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return Icons.male_rounded;
      case 'female':
        return Icons.female_rounded;
      default:
        return Icons.transgender_rounded;
    }
  }

  Widget _buildStatusDot(BuildContext context, InfluencerStatus status) {
    Color color;
    switch (status) {
      case InfluencerStatus.approved:
        color = _emerald;
        break;
      case InfluencerStatus.rejected:
        color = Theme.of(context).colorScheme.error;
        break;
      case InfluencerStatus.underReview:
        color = Colors.orangeAccent;
        break;
    }
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.2), width: 3.w),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String? url) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child:
            url != null
                ? Image.network(url, fit: BoxFit.cover)
                : Icon(
                  Icons.person_outline_rounded,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  size: 28.sp,
                ),
      ),
    );
  }

  Widget _buildLoadingIndicator() => Padding(
    padding: EdgeInsets.symmetric(vertical: 20.h),
    child: const Center(child: CircularProgressIndicator.adaptive()),
  );

  List<Influencer> _generateDummyData(int start, int count) {
    final realisticData = [
      {
        'name': 'Socrates',
        'dob': '470 BC',
        'domain': 'Philosophy',
        'subDomain': 'Ethics',
        'gender': 'Male',
        'bio': 'Foundational figure in Western philosophy and moral thought.',
        'picId': '1027',
      },
      {
        'name': 'Marie Curie',
        'dob': '1867',
        'domain': 'Science',
        'subDomain': 'Physics',
        'gender': 'Female',
        'bio': 'Pioneered radioactivity research; winner of two Nobel Prizes.',
        'picId': '1025',
      },
      {
        'name': 'Marcus Aurelius',
        'dob': '121 AD',
        'domain': 'Politics',
        'subDomain': 'Stoicism',
        'gender': 'Male',
        'bio': 'Roman Emperor and philosopher known for his Meditations.',
        'picId': '1011',
      },
      {
        'name': 'Ada Lovelace',
        'dob': '1815',
        'domain': 'Tech',
        'subDomain': 'Computing',
        'gender': 'Female',
        'bio': "Recognized as the world's first computer programmer.",
        'picId': '64',
      },
      {
        'name': 'Albert Einstein',
        'dob': '1879',
        'domain': 'Science',
        'subDomain': 'Physics',
        'gender': 'Male',
        'bio': 'Developed the theory of relativity; Nobel Prize winner.',
        'picId': '445',
      },
    ];

    return List.generate(count, (i) {
      final data = realisticData[i % realisticData.length];
      return Influencer(
        fullName: data['name']!,
        dob: data['dob']!,
        domain: data['domain']!,
        subDomain: data['subDomain']!,
        bio: data['bio']!,
        gender: data['gender']!,
        status: InfluencerStatus.values[i % 3],
        profilePicUrl: 'https://picsum.photos/id/${data['picId']}/200/200',
      );
    });
  }
}
