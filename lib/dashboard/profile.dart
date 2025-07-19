import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(debugShowCheckedModeBanner: false, home: PersonalInformationScreen());
      },
    );
  }
}

class PersonalInformationScreen extends StatefulWidget {
  @override
  _PersonalInformationScreenState createState() => _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final Map<String, bool> _expandedSections = {'overview': false, 'purpose': false, 'orgs': false, 'experience': false, 'social': false, 'activity': false};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A4971),
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF1A4971), Color(0xFF2C7BE5)], begin: Alignment.centerLeft, end: Alignment.centerRight))),
        title: Text('Personal Information', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white)),
        actions: [IconButton(icon: Icon(Icons.edit, color: Colors.white, size: 24.sp), onPressed: () {}), IconButton(icon: Icon(Icons.share, color: Colors.white, size: 24.sp), onPressed: () {})],
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(40.r), child: Image.network('https://picsum.photos/seed/profile/80', width: 80.w, height: 80.h, fit: BoxFit.cover)),
                SizedBox(height: 12.h),
                Text('John Doe', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
                SizedBox(height: 6.h),
                Text('@johndoe', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF718096))),
                SizedBox(height: 8.h),
                Text('Founder @SaveLife', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4A5568))),
                Text('+ 2 more', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2C7BE5))),
              ],
            ),
          ),
          _buildSection(
            title: 'My Profile Overview',
            key: 'overview',
            content: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 2.5,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              children: [
                _buildOverviewItem('My Orgs', '0', Icons.business),
                _buildOverviewItem('Goals', '0', Icons.flag),
                _buildOverviewItem('Connections', '120', Icons.people),
                _buildOverviewItem('Followers', '350', Icons.person_add),
                _buildOverviewItem('Joined Orgs', '0', Icons.group_work),
                _buildOverviewItem('Groups', '5', Icons.group),
                _buildOverviewItem('Posts', '42', Icons.article),
                _buildOverviewItem('Following', '180', Icons.person_pin),
              ],
            ),
          ),
          _buildSection(
            title: 'My Purpose, Goals, and Influencers',
            key: 'purpose',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPurposeCard(title: 'My Ultimate Purpose', data: ['Category: Social Impact', 'Subcategory: Community Building', 'Description: To create a positive impact through community-driven initiatives.']),
                SizedBox(height: 12.h),
                _buildPurposeCard(title: 'My Mission Statement', data: ['Category: Leadership', 'Subcategory: Empowerment', 'Description: Empowering individuals to achieve their full potential.']),
                SizedBox(height: 12.h),
                _buildPurposeCard(title: 'My Core Values', data: ['Integrity, Collaboration, Innovation']),
                SizedBox(height: 12.h),
                _buildPurposeCard(title: 'My Goals', data: ['Launch a non-profit by 2026', 'Mentor 100 young professionals']),
              ],
            ),
          ),
          _buildSection(title: 'My Organizations and Contributions', key: 'orgs', content: Padding(padding: EdgeInsets.all(12.w), child: Text('No contributions available.', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF718096))))),
          _buildSection(
            title: 'My Professional Experience',
            key: 'experience',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExperienceSection(
                  title: 'Education',
                  items: [
                    {'title': 'Bachelor of Science, Computer Science', 'subtitle': 'XYZ University', 'dates': '2015 - 2019', 'description': 'Graduated with honors, focused on software engineering.'},
                    {'title': 'Master of Business Administration', 'subtitle': 'ABC Institute', 'dates': '2020 - 2022', 'description': 'Specialized in Business Management and Leadership.'},
                  ],
                  viewAll: 'View All 5 Education',
                ),
                SizedBox(height: 20.h),
                _buildExperienceSection(
                  title: 'Experience',
                  items: [
                    {'title': 'Software Engineer', 'subtitle': 'Tech Corp', 'dates': '2019 - 2021', 'description': 'Developed scalable web applications and led a team of 5 developers.'},
                    {'title': 'Senior Developer', 'subtitle': 'Innovate Inc.', 'dates': '2021 - Present', 'description': 'Architected cloud-based solutions and mentored junior developers.'},
                  ],
                  viewAll: 'View All 4 Experience',
                ),
                SizedBox(height: 20.h),
                _buildSkillsSection(),
                SizedBox(height: 20.h),
                _buildExperienceSection(
                  title: 'Certifications',
                  items: [
                    {'title': 'Certified Scrum Master', 'subtitle': 'Scrum Alliance', 'dates': '2020', 'description': 'Certified in agile project management methodologies.'},
                    {'title': 'AWS Certified Developer', 'subtitle': 'Amazon', 'dates': '2021', 'description': 'Proficient in AWS cloud services and development.'},
                  ],
                  viewAll: 'View All 5 Certifications',
                ),
                SizedBox(height: 20.h),
                _buildExperienceSection(
                  title: 'Others',
                  items: [
                    {'title': 'Volunteer Work', 'subtitle': 'Community Tech Workshops', 'dates': '2018 - Present', 'description': 'Organized and led tech workshops to promote digital literacy in underserved communities.'},
                    {'title': 'Public Speaking', 'subtitle': 'Tech Conferences', 'dates': '2019 - 2023', 'description': 'Delivered talks on software development and innovation at 3 major tech conferences.'},
                  ],
                ),
              ],
            ),
          ),
          _buildSection(
            title: 'My Social Profile',
            key: 'social',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSocialSection(
                  title: 'My Interests (5)',
                  items: [
                    {'name': 'Technology'},
                    {'name': 'Entrepreneurship'},
                    {'name': 'Social Impact'},
                    {'name': 'Innovation'},
                    {'name': 'Education'},
                  ],
                ),
                SizedBox(height: 12.h),
                _buildSocialSection(
                  title: 'My Groups (3)',
                  items: [
                    {'name': 'Tech Innovators', 'image': 'https://picsum.photos/seed/group1/48'},
                    {'name': 'Community Builders', 'image': 'https://picsum.photos/seed/group2/48'},
                    {'name': 'Startup Hub', 'image': 'https://picsum.photos/seed/group3/48'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 12.h),
                _buildSocialSection(
                  title: 'My Connections (120)',
                  items: [
                    {'name': 'Jane Smith', 'image': 'https://picsum.photos/seed/conn1/48'},
                    {'name': 'Mike Johnson', 'image': 'https://picsum.photos/seed/conn2/48'},
                    {'name': 'Emily Brown', 'image': 'https://picsum.photos/seed/conn3/48'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 12.h),
                _buildSocialSection(
                  title: 'People I Follow (180)',
                  items: [
                    {'name': 'Alice Carter', 'image': 'https://picsum.photos/seed/follow1/48'},
                    {'name': 'Bob Wilson', 'image': 'https://picsum.photos/seed/follow2/48'},
                    {'name': 'Clara Davis', 'image': 'https://picsum.photos/seed/follow3/48'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 12.h),
                _buildSocialSection(
                  title: 'My Followers (350)',
                  items: [
                    {'name': 'David Lee', 'image': 'https://picsum.photos/seed/follower1/48'},
                    {'name': 'Sarah Miller', 'image': 'https://picsum.photos/seed/follower2/48'},
                    {'name': 'Tom Clark', 'image': 'https://picsum.photos/seed/follower3/48'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 12.h),
                _buildSocialSection(
                  title: 'Grow Your Network',
                  items: [
                    {'name': 'Lisa Adams', 'image': 'https://picsum.photos/seed/network1/48'},
                    {'name': 'James White', 'image': 'https://picsum.photos/seed/network2/48'},
                    {'name': 'Anna Green', 'image': 'https://picsum.photos/seed/network3/48'},
                  ],
                ),
              ],
            ),
          ),
          _buildSection(
            title: 'My Recent Social Activity',
            key: 'activity',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildActivityItem('Posted about a new community initiative on July 15, 2025.'), SizedBox(height: 12.h), _buildActivityItem('Shared an article on tech trends on July 10, 2025.')],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String key, required Widget content}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 1))]),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedSections[key] = !(_expandedSections[key] ?? false);
              });
            },
            child: Container(
              padding: EdgeInsets.all(12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A4971))),
                  Icon(_expandedSections[key] ?? false ? Icons.expand_less : Icons.expand_more, size: 20.sp, color: const Color(0xFF718096)),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Padding(padding: EdgeInsets.only(bottom: 12.h), child: content),
            crossFadeState: _expandedSections[key] ?? false ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String title, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8.r), color: Colors.white),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: const Color(0xFF718096)),
          SizedBox(width: 8.w),
          Expanded(child: Text('$title: ', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xFF2D3748)))),
          GestureDetector(onTap: () {}, child: Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2C7BE5)))),
        ],
      ),
    );
  }

  Widget _buildPurposeCard({required String title, required List<String> data}) {
    if (title == 'My Ultimate Purpose' || title == 'My Mission Statement') {
      String category = data.firstWhere((item) => item.startsWith('Category:'), orElse: () => 'Category: Unknown').split(': ')[1];
      String subcategory = data.firstWhere((item) => item.startsWith('Subcategory:'), orElse: () => 'Subcategory: Unknown').split(': ')[1];
      String description = data.firstWhere((item) => item.startsWith('Description:'), orElse: () => 'Description: Not provided').split(': ')[1];

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 1))], color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
            SizedBox(height: 8.h),
            Text(description, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF718096))),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(20.r), color: const Color(0xFF2C7BE5)),
                  child: Text(category, style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(20.r), color: const Color(0xFF2C7BE5)),
                  child: Text(subcategory, style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      );
    } else if (title == 'My Core Values') {
      List<String> values = data[0].split(', ').map((e) => e.trim()).toList();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 1))], color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  values
                      .map(
                        (value) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(20.r), color: Colors.white),
                          child: Text(value, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF2D3748))),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      );
    } else if (title == 'My Goals') {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 1))], color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  data
                      .map(
                        (goal) => Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(20.r), color: Colors.white),
                          child: Text(goal, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF2D3748))),
                        ),
                      )
                      .toList(),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 1))], color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
            SizedBox(height: 8.h),
            ...data.map((item) => Padding(padding: EdgeInsets.only(bottom: 4.h), child: Text(item, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF718096))))),
          ],
        ),
      );
    }
  }

  Widget _buildExperienceSection({required String title, required List<Map<String, String>> items, String? viewAll}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text(title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF2D3748))),
          SizedBox(height: 8.h),
          ...items.map(
            (item) => Container(
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.only(bottom: 10.h),
              decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 1))], color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] ?? '', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
                  SizedBox(height: 4.h),
                  Text(item['subtitle'] ?? '', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF4A5568))),
                  if (item['dates'] != null) ...[SizedBox(height: 4.h), Text(item['dates']!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: const Color(0xFF718096)))],
                  if (item['description'] != null) ...[SizedBox(height: 4.h), Text(item['description']!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: const Color(0xFF718096)))],
                ],
              ),
            ),
          ),
          if (viewAll != null) Padding(padding: EdgeInsets.only(top: 12.h), child: GestureDetector(onTap: () {}, child: Text(viewAll, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2C7BE5))))),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    final skills = ['Python', 'JavaScript', 'Project Management', 'Data Analysis', 'Team Leadership', 'UI/UX Design', 'Cloud Computing'];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Text('Skills', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: const Color(0xFF2D3748))),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...skills
                  .map(
                    (skill) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(20.r), color: Colors.white),
                      child: Text(skill, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: const Color(0xFF2D3748))),
                    ),
                  )
                  .toList(),
              Padding(padding: EdgeInsets.only(top: 12.h), child: GestureDetector(onTap: () {}, child: Text('View All 10 Skills', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2C7BE5))))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection({required String title, required List<Map<String, String>> items, String? viewAll}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  items
                      .map(
                        (item) => Container(
                          width: 120.w,
                          margin: EdgeInsets.only(right: 10.w),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), color: Colors.white),
                          child: Column(
                            children: [
                              if (item['image'] != null) ClipOval(child: Image.network(item['image']!, width: 48.w, height: 48.h, fit: BoxFit.cover)),
                              if (item['image'] != null) SizedBox(height: 6.h),
                              Text(item['name']!, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4A5568)), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          if (viewAll != null) Padding(padding: EdgeInsets.only(top: 10.h), child: GestureDetector(onTap: () {}, child: Text(viewAll, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2C7BE5))))),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text) {
    return Container(
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), color: Colors.white),
      child: Text(text, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4A5568))),
    );
  }
}
