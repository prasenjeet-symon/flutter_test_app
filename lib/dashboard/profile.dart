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
  final Map<String, bool> _expandedSections = {'overview': true, 'purpose': true, 'orgs': true, 'experience': true, 'social': true, 'activity': true, 'social_links': true};
  bool isPrivateMode = true;
  String connectionStatus = 'Follow'; // Can be 'Follow', 'Following', or 'Connected'
  final TextEditingController _linkedinUrlController = TextEditingController();
  final Map<String, bool> _selectedItems = {};
  final TextEditingController _purposeCategoryController = TextEditingController();
  final TextEditingController _purposeSubcategoryController = TextEditingController();
  final TextEditingController _purposeDescriptionController = TextEditingController();
  final TextEditingController _valuesController = TextEditingController();
  final TextEditingController _goalTitleController = TextEditingController();
  final TextEditingController _goalDeadlineController = TextEditingController();
  final TextEditingController _socialLinkController = TextEditingController();

  @override
  void dispose() {
    _linkedinUrlController.dispose();
    _purposeCategoryController.dispose();
    _purposeSubcategoryController.dispose();
    _purposeDescriptionController.dispose();
    _valuesController.dispose();
    _goalTitleController.dispose();
    _goalDeadlineController.dispose();
    _socialLinkController.dispose();
    super.dispose();
  }

  void _showLinkedInImportDialog(BuildContext context) {
    if (!isPrivateMode) return; // Prevent dialog in public mode
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          backgroundColor: Colors.white,
          elevation: 8,
          contentPadding: EdgeInsets.all(20.w),
          title: Row(
            children: [
              Image.network('https://finlink.co.uk/wp-content/uploads/2023/11/LinkedIn-Logo-e1700490108143.png', width: 24.w, height: 24.h),
              SizedBox(width: 8.w),
              Text('Import from LinkedIn', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Easily import your professional details directly from your LinkedIn profile to keep your information up-to-date.', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF718096), height: 1.5)),
              SizedBox(height: 16.h),
              TextField(
                controller: _linkedinUrlController,
                decoration: InputDecoration(
                  labelText: 'LinkedIn Profile URL',
                  labelStyle: TextStyle(color: const Color(0xFF718096)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                ),
                style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D3748)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF718096))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), elevation: 0),
              child: Container(
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2C7BE5), Color(0xFF1A4971)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Text('Import Now', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPurposeBottomSheet(BuildContext context, {required String section, bool isEdit = false, Map<String, String>? existingData}) {
    if (!isPrivateMode) return; // Prevent bottom sheet in public mode
    if (isEdit && existingData != null) {
      if (section == 'Core Values') {
        _valuesController.text = existingData['values'] ?? '';
      } else if (section == 'Goals') {
        _goalTitleController.text = existingData['title'] ?? '';
        _goalDeadlineController.text = existingData['deadline'] ?? '';
      } else {
        _purposeCategoryController.text = existingData['category'] ?? '';
        _purposeSubcategoryController.text = existingData['subcategory'] ?? '';
        _purposeDescriptionController.text = existingData['description'] ?? '';
      }
    } else {
      _purposeCategoryController.clear();
      _purposeSubcategoryController.clear();
      _purposeDescriptionController.clear();
      _valuesController.clear();
      _goalTitleController.clear();
      _goalDeadlineController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16.w, right: 16.w, top: 16.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Edit $section' : 'Add $section', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
                SizedBox(height: 16.h),
                if (section == 'Core Values') ...[
                  TextField(
                    controller: _valuesController,
                    decoration: InputDecoration(
                      labelText: 'Values (comma-separated)',
                      labelStyle: TextStyle(color: const Color(0xFF718096)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D3748)),
                  ),
                ] else if (section == 'Goals') ...[
                  TextField(
                    controller: _goalTitleController,
                    decoration: InputDecoration(
                      labelText: 'Goal Title',
                      labelStyle: TextStyle(color: const Color(0xFF718096)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D3748)),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _goalDeadlineController,
                    decoration: InputDecoration(
                      labelText: 'Deadline (e.g., 2026-12-31)',
                      labelStyle: TextStyle(color: const Color(0xFF718096)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D3748)),
                  ),
                ] else ...[
                  TextField(
                    controller: _purposeCategoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: const Color(0xFF718096)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D3748)),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _purposeSubcategoryController,
                    decoration: InputDecoration(
                      labelText: 'Subcategory',
                      labelStyle: TextStyle(color: const Color(0xFF718096)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D3748)),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _purposeDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: const Color(0xFF718096)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    ),
                    style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D3748)),
                    maxLines: 3,
                  ),
                ],
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF718096))),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), elevation: 0),
                      child: Container(
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2C7BE5), Color(0xFF1A4971)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        child: Text('Save', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSocialLinkBottomSheet(BuildContext context, {bool isEdit = false, String? existingLink}) {
    if (!isPrivateMode) return; // Prevent bottom sheet in public mode
    if (isEdit && existingLink != null) {
      _socialLinkController.text = existingLink;
    } else {
      _socialLinkController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16.w, right: 16.w, top: 16.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Edit Social Link' : 'Add Social Link', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
                SizedBox(height: 16.h),
                TextField(
                  controller: _socialLinkController,
                  decoration: InputDecoration(
                    labelText: 'Social Media URL',
                    labelStyle: TextStyle(color: const Color(0xFF718096)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFF2C7BE5), width: 2)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  ),
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D3748)),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF718096))),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, foregroundColor: Colors.white, padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), elevation: 0),
                      child: Container(
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2C7BE5), Color(0xFF1A4971)], begin: Alignment.centerLeft, end: Alignment.centerRight), borderRadius: BorderRadius.circular(10.r)),
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                        child: Text('Save', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('@johndoe', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
        leading: BackButton(color: const Color(0xFF2D3748)),
        actions: [
          if (!isPrivateMode) ...[
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (connectionStatus == 'Follow') {
                    connectionStatus = 'Following';
                  } else if (connectionStatus == 'Following') {
                    connectionStatus = 'Connected';
                  } else {
                    connectionStatus = 'Follow';
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    connectionStatus == 'Connected'
                        ? const Color(0xFF4CAF50)
                        : connectionStatus == 'Following'
                        ? Colors.transparent
                        : const Color(0xFF2C7BE5),
                foregroundColor: connectionStatus == 'Following' ? const Color(0xFF2C7BE5) : Colors.white,
                minimumSize: Size(80.w, 28.h),
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r), side: connectionStatus == 'Following' ? const BorderSide(color: Color(0xFF2C7BE5)) : BorderSide.none),
                elevation: 0,
                textStyle: TextStyle(fontSize: 12.sp),
              ),
              child: Text(connectionStatus),
            ),
            SizedBox(width: 8.w),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: const Color(0xFF2D3748), size: 24.sp),
              onSelected: (String value) {
                if (value == 'block') {
                  // Handle block action
                } else if (value == 'share') {
                  // Handle share action
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(value: 'block', child: Row(children: [Icon(Icons.block, size: 16.sp, color: const Color(0xFF2D3748)), SizedBox(width: 8.w), Text('Block', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D3748)))])),
                  PopupMenuItem<String>(value: 'share', child: Row(children: [Icon(Icons.share, size: 16.sp, color: const Color(0xFF2D3748)), SizedBox(width: 8.w), Text('Share', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF2D3748)))])),
                ];
              },
            ),
          ],
        ],
        elevation: 0,
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            color: Colors.white,
            child: Column(
              children: [
                CircleAvatar(backgroundColor: Colors.white, radius: 40.r, backgroundImage: NetworkImage('https://picsum.photos/seed/profile/80')),
                SizedBox(height: 12.h),
                Text('John Doe', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2D3748))),
                SizedBox(height: 2.h),
                Text('@johndoe', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF718096))),
                SizedBox(height: 5.h),
                Text('Founder @SaveLife', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4A5568))),
                Text('+ 2 more', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2C7BE5))),
              ],
            ),
          ),
          _buildSection(
            title: 'Profile Overview',
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
                _buildOverviewItem('Orgs', '3', Icons.business),
                _buildOverviewItem('Goals', '5', Icons.flag),
                _buildOverviewItem('Connections', '120', Icons.people),
                _buildOverviewItem('Followers', '350', Icons.person_add),
                _buildOverviewItem('Joined Orgs', '2', Icons.group_work),
                _buildOverviewItem('Groups', '5', Icons.group),
                _buildOverviewItem('Posts', '42', Icons.article),
                _buildOverviewItem('Following', '180', Icons.person_pin),
              ],
            ),
          ),
          _buildSection(
            title: 'Purpose & Goals',
            key: 'purpose',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPurposeCard(title: 'Ultimate Purpose', data: ['Category: Social Impact', 'Subcategory: Community Development', 'Description: Empower communities through sustainable initiatives and education.']),
                SizedBox(height: 12.h),
                _buildPurposeCard(title: 'Mission Statement', data: ['Category: Leadership', 'Subcategory: Innovation', 'Description: Drive innovation to create positive change in society.']),
                SizedBox(height: 12.h),
                _buildPurposeCard(title: 'Core Values', data: ['Integrity, Collaboration, Innovation']),
                SizedBox(height: 12.h),
                _buildPurposeCard(title: 'Goals', data: ['Launch a non-profit by 2026|2026-12-31', 'Mentor 100 young professionals|2025-12-31', 'Raise for charity|2027-06-30']),
              ],
            ),
          ),
          _buildSection(
            title: 'Organizations',
            key: 'orgs',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExperienceSection(
                  title: 'Organizations',
                  items: [
                    {'title': 'SaveLife', 'subtitle': 'Founder', 'dates': 'Jan 2020 - Present', 'description': 'Leading initiatives to support community welfare.'},
                    {'title': 'TechOrg', 'subtitle': 'Advisor', 'dates': 'Mar 2022 - Present', 'description': 'Providing strategic guidance on tech projects.'},
                  ],
                ),
              ],
            ),
          ),
          _buildSection(
            title: 'Experience',
            key: 'experience',
            showLinkedInIcon: isPrivateMode,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExperienceSection(
                  title: 'Education',
                  items: [
                    {'title': 'BSc Computer Science', 'subtitle': 'Stanford University', 'dates': '2015 - 2019', 'description': 'Graduated with honors.'},
                    {'title': 'MBA', 'subtitle': 'Harvard Business School', 'dates': '2020 - 2022', 'description': 'Focused on entrepreneurship.'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 20.h),
                _buildExperienceSection(
                  title: 'Experience',
                  items: [
                    {'title': 'Senior Developer', 'subtitle': 'TechCorp', 'dates': '2019 - 2021', 'description': 'Led development of a scalable SaaS platform.'},
                    {'title': 'Product Manager', 'subtitle': 'Innovate Inc.', 'dates': '2021 - 2023', 'description': 'Managed product lifecycle for mobile apps.'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 20.h),
                _buildSkillsSection(),
                SizedBox(height: 20.h),
                _buildExperienceSection(
                  title: 'Certifications',
                  items: [
                    {'title': 'Certified ScrumMaster', 'subtitle': 'Scrum Alliance', 'dates': '2022', 'description': 'Certified in agile project management.'},
                    {'title': 'AWS Solutions Architect', 'subtitle': 'Amazon Web Services', 'dates': '2023', 'description': 'Expertise in cloud architecture.'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 20.h),
                _buildExperienceSection(
                  title: 'Others',
                  items: [
                    {'title': 'Volunteer Mentor', 'subtitle': 'Youth Empowerment Program', 'dates': '2020 - Present', 'description': 'Mentoring young professionals.'},
                    {'title': 'Guest Speaker', 'subtitle': 'Tech Summit 2024', 'dates': '2024', 'description': 'Spoke on AI in social impact.'},
                  ],
                ),
              ],
            ),
          ),
          _buildSection(
            title: 'Social Profile',
            key: 'social',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSocialSection(
                  title: 'Interests',
                  items: [
                    {'name': 'Sustainable Tech', 'org': 'GreenTech'},
                    {'name': 'AI Ethics', 'org': 'AI4Good'},
                  ],
                ),
                SizedBox(height: 16.h),
                _buildSocialSection(
                  title: 'Groups',
                  items: [
                    {'name': 'Tech Innovators', 'image': 'https://picsum.photos/seed/group1/80', 'username': '@techinnovators'},
                    {'name': 'Social Impact Hub', 'image': 'https://picsum.photos/seed/group2/80', 'username': '@socialimpact'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 16.h),
                _buildSocialSection(
                  title: 'Connections',
                  items: [
                    {'name': 'Jane Smith', 'image': 'https://picsum.photos/seed/jane/80', 'username': '@janesmith', 'status': 'connected'},
                    {'name': 'Mike Johnson', 'image': 'https://picsum.photos/seed/mike/80', 'username': '@mikejohnson', 'status': 'connected'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 16.h),
                _buildSocialSection(
                  title: 'Following',
                  items: [
                    {'name': 'Tech Trends', 'image': 'https://picsum.photos/seed/tech/80', 'username': '@techtrends', 'status': 'following'},
                    {'name': 'Innovate Daily', 'image': 'https://picsum.photos/seed/innovate/80', 'username': '@innovatedaily', 'status': 'following'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 16.h),
                _buildSocialSection(
                  title: 'Followers',
                  items: [
                    {'name': 'Sarah Lee', 'image': 'https://picsum.photos/seed/sarah/80', 'username': '@sarahlee', 'status': 'follow'},
                    {'name': 'Tom Brown', 'image': 'https://picsum.photos/seed/tom/80', 'username': '@tombrown', 'status': 'follow'},
                  ],
                  viewAll: 'View All',
                ),
                SizedBox(height: 16.h),
                _buildSocialSection(
                  title: 'Grow Your Network',
                  items: [
                    {'name': 'Emily Davis', 'image': 'https://picsum.photos/seed/emily/80', 'username': '@emilydavis', 'status': 'follow'},
                    {'name': 'David Wilson', 'image': 'https://picsum.photos/seed/david/80', 'username': '@davidwilson', 'status': 'follow'},
                  ],
                ),
              ],
            ),
          ),
          _buildSection(
            title: 'Social Links',
            key: 'social_links',
            showAddIcon: isPrivateMode,
            content: _buildSocialLinksSection(
              items: [
                {'platform': 'LinkedIn', 'url': 'https://linkedin.com/in/johndoe'},
                {'platform': 'Twitter', 'url': 'https://twitter.com/johndoe'},
                {'platform': 'GitHub', 'url': 'https://github.com/johndoe'},
              ],
            ),
          ),
          _buildSection(
            title: 'Recent Activity',
            key: 'activity',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...[
                  'Posted about a new community initiative on July 15, 2025.',
                  'Shared an article on tech trends on July 10, 2025.',
                  'Commented on a post about sustainability on July 8, 2025.',
                  'Joined a group discussion on July 5, 2025.',
                  'Updated profile details on July 1, 2025.',
                ].asMap().entries.take(5).map((entry) => Padding(padding: EdgeInsets.only(bottom: 12.h), child: _buildActivityItem(entry.value))),
                Center(child: Padding(padding: EdgeInsets.only(top: 12.h), child: GestureDetector(onTap: () {}, child: Text('View All Activities', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2C7BE5)))))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required String key, required Widget content, bool showLinkedInIcon = false, bool showAddIcon = false}) {
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
                  Expanded(child: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A4971)))),
                  Row(
                    children: [
                      if (showLinkedInIcon)
                        IconButton(
                          icon: Image.network('https://finlink.co.uk/wp-content/uploads/2023/11/LinkedIn-Logo-e1700490108143.png', width: 20.w, height: 20.h),
                          onPressed: () => _showLinkedInImportDialog(context),
                          tooltip: 'Import from LinkedIn',
                        ),
                      if (showAddIcon) IconButton(icon: Icon(Icons.add, color: const Color(0xFF2C7BE5), size: 24.sp), onPressed: () => _showSocialLinkBottomSheet(context), tooltip: 'Add Social Link'),
                      Icon(_expandedSections[key] ?? false ? Icons.expand_less : Icons.expand_more, size: 20.sp, color: const Color(0xFF718096)),
                    ],
                  ),
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
    if (title == 'Ultimate Purpose' || title == 'Mission Statement') {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
                if (isPrivateMode) // Show buttons only in private mode
                  Row(
                    children: [
                      IconButton(icon: Icon(Icons.add, size: 16.sp, color: const Color(0xFF2C7BE5)), onPressed: () => _showPurposeBottomSheet(context, section: title), tooltip: 'Add $title'),
                      IconButton(
                        icon: Icon(Icons.edit, size: 16.sp, color: const Color(0xFF2C7BE5)),
                        onPressed: () => _showPurposeBottomSheet(context, section: title, isEdit: true, existingData: {'category': category, 'subcategory': subcategory, 'description': description}),
                        tooltip: 'Edit $title',
                      ),
                    ],
                  ),
              ],
            ),
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
    } else if (title == 'Core Values') {
      List<String> values = data[0].split(', ').map((e) => e.trim()).toList();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 1))], color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
                if (isPrivateMode) // Show buttons only in private mode
                  Row(
                    children: [
                      IconButton(icon: Icon(Icons.add, size: 16.sp, color: const Color(0xFF2C7BE5)), onPressed: () => _showPurposeBottomSheet(context, section: title), tooltip: 'Add Core Values'),
                      IconButton(
                        icon: Icon(Icons.edit, size: 16.sp, color: const Color(0xFF2C7BE5)),
                        onPressed: () => _showPurposeBottomSheet(context, section: title, isEdit: true, existingData: {'values': values.join(', ')}),
                        tooltip: 'Edit Core Values',
                      ),
                    ],
                  ),
              ],
            ),
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
    } else if (title == 'Goals') {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.w),
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 1))], color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
                if (isPrivateMode) // Show button only in private mode
                  Row(children: [IconButton(icon: Icon(Icons.add, size: 16.sp, color: const Color(0xFF2C7BE5)), onPressed: () => _showPurposeBottomSheet(context, section: title), tooltip: 'Add Goal')]),
              ],
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children:
                  data.asMap().entries.map((entry) {
                    final index = entry.key;
                    final goalData = entry.value.split('|');
                    final goalTitle = goalData[0];
                    final goalDeadline = goalData.length > 1 ? goalData[1] : 'No deadline';
                    final itemKey = 'goal-$index';
                    final isSelected = _selectedItems[itemKey] ?? false;

                    return GestureDetector(
                      onTap:
                          isPrivateMode
                              ? () {
                                setState(() {
                                  _selectedItems[itemKey] = !isSelected;
                                });
                              }
                              : null, // Disable tap in public mode
                      child: Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(20.r), color: isSelected ? const Color(0xFF718096).withOpacity(0.7) : Colors.white),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(goalTitle, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
                                SizedBox(height: 4.h),
                                Text('Achieve by: $goalDeadline', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF718096))),
                              ],
                            ),
                          ),
                          if (isSelected && isPrivateMode) // Show close button only in private mode
                            Positioned(
                              top: 0.5.h,
                              right: 0.5.w,
                              child: Container(
                                padding: EdgeInsets.all(1.w),
                                decoration: const BoxDecoration(color: Color(0xFF2D3748), shape: BoxShape.circle),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedItems.remove(itemKey);
                                    });
                                  },
                                  child: Icon(Icons.close, color: Colors.white, size: 12.w),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    }
    return Container();
  }

  Widget _buildExperienceSection({required String title, required List<Map<String, String>> items, String? viewAll}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
              if (isPrivateMode) // Show button only in private mode
                Tooltip(message: 'Add Item', child: IconButton(icon: Icon(Icons.add, color: const Color(0xFF2C7BE5), size: 24.sp), onPressed: () {})),
            ],
          ),
          SizedBox(height: 8.h),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final itemKey = '$title-$index';
            final isSelected = _selectedItems[itemKey] ?? false;

            return GestureDetector(
              onTap:
                  isPrivateMode
                      ? () {
                        setState(() {
                          _selectedItems[itemKey] = !isSelected;
                        });
                      }
                      : null, // Disable tap in public mode
              child: Stack(
                children: [
                  Container(
                    width: double.infinity, // Ensure full width
                    padding: EdgeInsets.all(12.w),
                    margin: EdgeInsets.only(bottom: 10.h), // Remove horizontal margin
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 1))],
                      color: isSelected ? const Color(0xFF718096).withOpacity(0.7) : Colors.white,
                    ),
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
                  if (isSelected && isPrivateMode) // Show close button only in private mode
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: const BoxDecoration(color: Color(0xFF2D3748), shape: BoxShape.circle),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedItems.remove(itemKey);
                            });
                          },
                          child: Icon(Icons.close, color: Colors.white, size: 16.w),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Skills', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
              if (isPrivateMode) // Show button only in private mode
                Tooltip(message: 'Add Item', child: IconButton(icon: Icon(Icons.add, color: const Color(0xFF2C7BE5), size: 24.sp), onPressed: () {})),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ...skills.asMap().entries.map((entry) {
                final index = entry.key;
                final skill = entry.value;
                final itemKey = 'skill-$index';
                final isSelected = _selectedItems[itemKey] ?? false;

                return GestureDetector(
                  onTap:
                      isPrivateMode
                          ? () {
                            setState(() {
                              _selectedItems[itemKey] = !isSelected;
                            });
                          }
                          : null, // Disable tap in public mode
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(20.r), color: isSelected ? const Color(0xFF718096).withOpacity(0.7) : Colors.white),
                        child: Text(skill, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400, color: const Color(0xFF2D3748))),
                      ),
                      if (isSelected && isPrivateMode) // Show close button only in private mode
                        Positioned(
                          top: 0.5.h,
                          right: 0.5.w,
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: const BoxDecoration(color: Color(0xFF2D3748), shape: BoxShape.circle),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedItems.remove(itemKey);
                                });
                              },
                              child: Icon(Icons.close, color: Colors.white, size: 12.w),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
              Padding(padding: EdgeInsets.only(top: 12.h), child: GestureDetector(onTap: () {}, child: Text('View All', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF2C7BE5))))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection({required String title, required List<Map<String, String>> items, String? viewAll}) {
    final displayTitle = title.contains('Interests') || title.contains('Groups') || title.contains('Connections') || title.contains('Following') || title.contains('Followers') ? '$title (${items.length})' : title;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(displayTitle, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748))),
              if (viewAll != null && items.isNotEmpty) GestureDetector(onTap: () {}, child: Text(viewAll, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2C7BE5)))),
            ],
          ),
          SizedBox(height: 8.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  items
                      .map(
                        (item) => Container(
                          width: 140.w,
                          margin: EdgeInsets.only(right: 10.w),
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), color: Colors.white),
                          child: Column(
                            children: [
                              if (item['image'] != null) CircleAvatar(radius: 24.r, backgroundImage: NetworkImage(item['image']!)),
                              if (item['image'] != null) SizedBox(height: 6.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(child: Text(item['name']!, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4A5568)), textAlign: TextAlign.center, overflow: TextOverflow.ellipsis)),
                                  if (title.contains('Connections') || title.contains('Following') || title.contains('Followers')) Padding(padding: EdgeInsets.only(left: 4.w), child: Icon(Icons.verified, size: 14.sp, color: const Color(0xFF2C7BE5))),
                                ],
                              ),
                              if (item['org'] != null) ...[SizedBox(height: 4.h), Text(item['org']!, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF718096)), textAlign: TextAlign.center)],
                              if (item['username'] != null) ...[SizedBox(height: 4.h), Text(item['username']!, style: TextStyle(fontSize: 10.sp, color: const Color(0xFF718096)), textAlign: TextAlign.center)],
                              if (item['status'] != null) ...[
                                SizedBox(height: 8.h),
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        item['status'] == 'connected'
                                            ? const Color(0xFF4CAF50)
                                            : item['status'] == 'following'
                                            ? Colors.transparent
                                            : const Color(0xFF2C7BE5),
                                    foregroundColor:
                                        item['status'] == 'connected'
                                            ? Colors.white
                                            : item['status'] == 'follow'
                                            ? Colors.white
                                            : const Color(0xFF2C7BE5),
                                    minimumSize: Size(100.w, 28.h),
                                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r), side: item['status'] == 'following' ? const BorderSide(color: Color(0xFF2C7BE5)) : BorderSide.none),
                                    elevation: 0,
                                    textStyle: TextStyle(fontSize: 10.sp),
                                  ),
                                  child: Text(
                                    item['status'] == 'connected'
                                        ? 'Connected'
                                        : item['status'] == 'following'
                                        ? 'Following'
                                        : 'Follow',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLinksSection({required List<Map<String, String>> items}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final itemKey = 'social_link-$index';
                  final isSelected = _selectedItems[itemKey] ?? false;

                  return GestureDetector(
                    onTap:
                        isPrivateMode
                            ? () {
                              setState(() {
                                _selectedItems[itemKey] = !isSelected;
                              });
                            }
                            : null, // Disable tap in public mode
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                          decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(20.r), color: isSelected ? const Color(0xFF718096).withOpacity(0.7) : Colors.white),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                item['platform'] == 'LinkedIn'
                                    ? Icons.email
                                    : item['platform'] == 'Twitter'
                                    ? Icons.alternate_email
                                    : Icons.link,
                                size: 16.sp,
                                color: const Color(0xFF2C7BE5),
                              ),
                              SizedBox(width: 8.w),
                              Flexible(child: Text(item['platform']!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: const Color(0xFF2D3748)), overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                        if (isSelected && isPrivateMode) // Show close button only in private mode
                          Positioned(
                            top: 0.5.h,
                            right: 0.5.w,
                            child: Container(
                              padding: EdgeInsets.all(1.w),
                              decoration: const BoxDecoration(color: Color(0xFF2D3748), shape: BoxShape.circle),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedItems.remove(itemKey);
                                  });
                                },
                                child: Icon(Icons.close, color: Colors.white, size: 12.w),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String text) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      margin: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(10.r), color: Colors.white),
      child: Text(text, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF4A5568))),
    );
  }
}
