import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

class OrganizationProfileScreen extends StatelessWidget {
  const OrganizationProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data for demonstration
    final Map<String, dynamic> organizationData = {
      'logoUrl': 'https://picsum.photos/200',
      'name': 'Tech for Good Foundation',
      'type': 'Non-profit Organization',
      'orgId': 'TFG-2023-001',
      'shortName': 'TFG',
      'bio':
          'We are a non-profit organization dedicated to leveraging technology to solve global challenges. Our work focuses on digital literacy, environmental conservation, and social equity.',
      'founder': {
        'name': 'Jane Doe',
        'profilePicUrl': 'https://picsum.photos/200/200?random=1',
        'userId': 'janedoe123',
        'position': 'Founder',
        'isVerified': true,
      },
      'teamMembers': [
        {
          'name': 'John Smith',
          'profilePicUrl': 'https://picsum.photos/200/200?random=2',
          'userId': 'johnsmith',
          'position': 'Chief Technology Officer',
          'isVerified': true,
        },
        {
          'name': 'Emily White',
          'profilePicUrl': 'https://picsum.photos/200/200?random=3',
          'userId': 'emilywhite',
          'position': 'Head of Marketing',
          'isVerified': false,
        },
        {
          'name': 'David Chen',
          'profilePicUrl': 'https://picsum.photos/200/200?random=4',
          'userId': 'davidchen',
          'position': 'Lead Designer',
          'isVerified': true,
        },
        {
          'name': 'Sarah Lee',
          'profilePicUrl': 'https://picsum.photos/200/200?random=5',
          'userId': 'sarahlee',
          'position': 'Community Manager',
          'isVerified': true,
        },
        {
          'name': 'Chris Evans',
          'profilePicUrl': 'https://picsum.photos/200/200?random=6',
          'userId': 'chrisevans',
          'position': 'Senior Developer',
          'isVerified': false,
        },
      ],
      'mission':
          'To empower every citizen with the tools of technology to build a better future. We believe in **digital inclusion** and providing access to **education** for all, regardless of background or economic status.',
      'missionCategory': 'Technology',
      'missionSubCategory': 'Digital Literacy',
      'purpose':
          'To drive **innovation** and create products that empower individuals to achieve their full potential. We are committed to **sustainable growth** and ethical business practices.',
      'purposeCategory': 'Innovation',
      'purposeSubCategory': 'Product Development',
      'goals': [
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
      ],
      'productCategories': [
        {
          "name": "Products",
          "count": 125,
          "status": "Active",
          "icon": Icons.shopping_bag_outlined,
        },
        {
          "name": "Rental",
          "count": 48,
          "status": "Inactive",
          "icon": Icons.local_shipping_outlined,
        },
        {
          "name": "Services",
          "count": 72,
          "status": "Active",
          "icon": Icons.support_agent_outlined,
        },
        {
          "name": "Digital Products",
          "count": 210,
          "status": "Active",
          "icon": Icons.cloud_download_outlined,
        },
        {
          "name": "Real Estate",
          "count": 15,
          "status": "Active",
          "icon": Icons.home_work_outlined,
        },
      ],
    };

    // Sort goals by date in descending order (latest date at top)
    final sortedGoals =
        (organizationData['goals'] as List).cast<Map<String, dynamic>>()..sort(
          (a, b) => (b['accomplishmentDate'] as DateTime).compareTo(
            a['accomplishmentDate'] as DateTime,
          ),
        );

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          '@${organizationData['orgId']}',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Handle settings action
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Handle more options action
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, organizationData),
              SizedBox(height: 24.h),
              _buildFounderInfo(context, organizationData['founder']),
              SizedBox(height: 16.h),
              _buildOurMembersSection(context, organizationData['teamMembers']),
              SizedBox(height: 24.h),
              _buildProductCategoriesSection(
                context,
                organizationData['productCategories'],
              ),
              SizedBox(height: 24.h),
              _buildBioSection(context, organizationData['bio']),
              SizedBox(height: 24.h),
              _buildMarkdownSection(
                context,
                'Mission',
                organizationData['mission'],
                organizationData['missionCategory'],
                organizationData['missionSubCategory'],
              ),
              SizedBox(height: 24.h),
              _buildMarkdownSection(
                context,
                'Purpose',
                organizationData['purpose'],
                organizationData['purposeCategory'],
                organizationData['purposeSubCategory'],
              ),
              SizedBox(height: 24.h),
              _buildGoalsSection(context, sortedGoals),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Map<String, dynamic> data) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50.r,
            backgroundImage: NetworkImage(data['logoUrl']),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                data['name'],
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 22.sp,
                ),
              ),
              if (data['isVerified'] == true) ...[
                SizedBox(width: 8.w),
                Icon(
                  Icons.verified,
                  size: 22.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            data['type'],
            style: GoogleFonts.lato(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFounderInfo(BuildContext context, Map<String, dynamic> founder) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: ListTile(
          leading: CircleAvatar(
            radius: 24.r,
            backgroundImage: NetworkImage(founder['profilePicUrl']),
          ),
          title: Row(
            children: [
              Text(
                founder['name'],
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                ),
              ),
              if (founder['isVerified'] == true) ...[
                SizedBox(width: 4.w),
                Icon(
                  Icons.verified,
                  size: 16.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ],
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '@${founder['userId']}',
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                'Founder',
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOurMembersSection(
    BuildContext context,
    List<dynamic> teamMembers,
  ) {
    final int displayLimit = 4;
    final List<Map<String, dynamic>> displayedMembers =
        teamMembers
            .sublist(
              0,
              teamMembers.length > displayLimit
                  ? displayLimit
                  : teamMembers.length,
            )
            .cast<Map<String, dynamic>>();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Our Members',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 8.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: displayedMembers.length,
              itemBuilder: (context, index) {
                final member = displayedMembers[index];
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20.r,
                        backgroundImage: NetworkImage(member['profilePicUrl']),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  member['name'],
                                  style: GoogleFonts.lato(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                if (member['isVerified'] == true) ...[
                                  SizedBox(width: 4.w),
                                  Icon(
                                    Icons.verified,
                                    size: 14.sp,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              '@${member['userId']}',
                              style: GoogleFonts.lato(
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            Text(
                              member['position'] ?? '',
                              style: GoogleFonts.lato(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            if (teamMembers.length > displayLimit)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // Handle "View All" button action
                  },
                  child: Text(
                    'View all (${teamMembers.length})',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioSection(BuildContext context, String bio) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bio',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(bio, style: GoogleFonts.lato(fontSize: 14.sp, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkdownSection(
    BuildContext context,
    String title,
    String markdown,
    String category,
    String subCategory,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 12.h),
            MarkdownBody(
              data: markdown,
              selectable: true,
              styleSheet: MarkdownStyleSheet(
                h1: GoogleFonts.lato(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
                h2: GoogleFonts.lato(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                h3: GoogleFonts.lato(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
                p: GoogleFonts.lato(fontSize: 14.sp, height: 1.5),
                strong: GoogleFonts.lato(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.bottomRight,
              child: Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: [
                  _buildOutlinedChip(context, category),
                  _buildOutlinedChip(context, subCategory),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedChip(BuildContext context, String text) {
    return Chip(
      label: Text(text),
      labelStyle: GoogleFonts.lato(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.primary,
      ),
      backgroundColor: Colors.transparent,
      side: BorderSide(color: Theme.of(context).colorScheme.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
    );
  }

  Widget _buildGoalsSection(
    BuildContext context,
    List<Map<String, dynamic>> goals,
  ) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goals',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 8.h),
            if (goals.isEmpty)
              Center(
                child: Text(
                  'No goals found.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final bool isLast = index == goals.length - 1;
                  return _GoalTimelineItem(goal: goal, isLast: isLast);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _GoalTimelineItem extends StatelessWidget {
  final Map<String, dynamic> goal;
  final bool isLast;

  const _GoalTimelineItem({required this.goal, required this.isLast});

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
                  Text(
                    goal['title'] as String,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
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
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        goal['category'] as String,
                        style: GoogleFonts.lato(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.primary,
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

Widget _buildProductCategoriesSection(
  BuildContext context,
  List<Map<String, dynamic>> categories,
) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    elevation: 2,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Products & Services',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
            ),
          ),
          SizedBox(height: 8.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final item = categories[index];
              return _buildListTileWithCount(
                context,
                item['name'],
                item['icon'],
                item['count'],
                item['status'],
              );
            },
          ),
        ],
      ),
    ),
  );
}

Widget _buildListTileWithCount(
  BuildContext context,
  String name,
  IconData icon,
  int count,
  String status,
) {
  final bool isActive = status == 'Active';
  final Color statusColor = isActive ? Colors.green : Colors.red;

  return ListTile(
    contentPadding: EdgeInsets.symmetric(
      horizontal: 0.w,
      vertical: 2.h,
    ), // Reduced padding
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(
      name,
      style: GoogleFonts.lato(
        fontSize: 15.sp, // Reduced font size
        fontWeight: FontWeight.w600,
      ),
    ),
    subtitle: Text(
      '$count items',
      style: GoogleFonts.lato(
        fontSize: 13.sp, // Reduced font size
        color: Colors.grey.shade600,
      ),
    ),
    trailing: Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        status,
        style: GoogleFonts.lato(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    ),
    onTap: () {
      // This is where you would handle navigation to the new screen
    },
  );
}
