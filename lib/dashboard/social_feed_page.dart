import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

// --- Main Application Entry Point ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit is used to make the UI responsive across different screen sizes.
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Example design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(debugShowCheckedModeBanner: false, title: 'Flutter Social Feed', theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light), useMaterial3: true), home: child);
      },
      child: const SocialFeedPage(),
    );
  }
}

// --- 1. Data Models ---
class Organization {
  final String id;
  final String name;
  final String shortName;
  final String type;
  final String logoUrl;

  Organization({required this.id, required this.name, required this.shortName, required this.type, this.logoUrl = 'https://via.placeholder.com/40'});
}

class Topic {
  final String id;
  final String name;
  final String orgId;

  Topic({required this.id, required this.name, required this.orgId});
}

// --- 2. Main Social Feed Page ---
class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({Key? key}) : super(key: key);

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  // Mock Data
  final List<Organization> _organizations = [
    Organization(id: 'org1', name: 'Global Tech Solutions', shortName: 'GTS', type: 'Technology'),
    Organization(id: 'org2', name: 'Health & Wellness Co.', shortName: 'HWC', type: 'Healthcare'),
    Organization(id: 'org3', name: 'Artistic Creations Studio', shortName: 'ACS', type: 'Arts & Culture'),
    Organization(id: 'org4', name: 'Eco-Friendly Living', shortName: 'EFL', type: 'Environment'),
    Organization(id: 'org5', name: 'Future Education Hub', shortName: 'FEH', type: 'Education'),
  ];

  late final List<Topic> _topics;

  // Global Keys to reference the position of each UI element
  final Map<String, GlobalKey> _organizationKeys = {};
  final Map<String, GlobalKey> _topicChipKeys = {};

  // Scroll Controllers
  final ScrollController _mainFeedScrollController = ScrollController();
  final ScrollController _topicsBarScrollController = ScrollController();

  // State variables
  String? _selectedTopicId;
  bool _isScrollingProgrammatically = false;

  @override
  void initState() {
    super.initState();
    _topics = [
      Topic(id: 'topic1', name: 'Innovations', orgId: 'org1'),
      Topic(id: 'topic2', name: 'Daily Habits', orgId: 'org2'),
      Topic(id: 'topic3', name: 'Digital Art', orgId: 'org3'),
      Topic(id: 'topic4', name: 'Recycling Tips', orgId: 'org4'),
      Topic(id: 'topic5', name: 'Online Courses', orgId: 'org5'),
      Topic(id: 'topic6', name: 'AI Ethics', orgId: 'org1'),
      Topic(id: 'topic7', name: 'Mental Health', orgId: 'org2'),
      Topic(id: 'topic8', name: 'Sculpture', orgId: 'org3'),
    ];

    // Initialize GlobalKeys for each organization and topic
    for (var org in _organizations) {
      _organizationKeys[org.id] = GlobalKey();
    }
    for (var topic in _topics) {
      _topicChipKeys[topic.id] = GlobalKey();
    }

    // Set the first topic as selected initially
    if (_topics.isNotEmpty) {
      _selectedTopicId = _topics.first.id;
    }
  }

  @override
  void dispose() {
    _mainFeedScrollController.dispose();
    _topicsBarScrollController.dispose();
    super.dispose();
  }

  // Function to scroll the main feed to a specific organization's section
  Future<void> _scrollToOrganization(String orgId) async {
    final key = _organizationKeys[orgId];
    if (key != null && key.currentContext != null) {
      await Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, alignment: 0.0);
    }
  }

  // Function to scroll the topics bar to bring a specific chip into view
  void _scrollToChip(String topicId) {
    final key = _topicChipKeys[topicId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        alignment: 0.5, // Center the chip
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Social Feed', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 20.sp)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Horizontal Scrollable Topics Bar
          Container(
            height: 60.h,
            color: Theme.of(context).colorScheme.surface,
            child: ListView.builder(
              controller: _topicsBarScrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                final topic = _topics[index];
                final organization = _organizations.firstWhere((org) => org.id == topic.orgId);
                final bool isSelected = topic.id == _selectedTopicId;

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ActionChip(
                    key: _topicChipKeys[topic.id],
                    avatar: Icon(Icons.topic_outlined, size: 20.sp, color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topic.name, style: GoogleFonts.lato(fontSize: 13.sp, color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                        Text('(${organization.shortName})', style: GoogleFonts.lato(fontSize: 10.sp, color: isSelected ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8) : Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    onPressed: () async {
                      setState(() {
                        _isScrollingProgrammatically = true;
                        _selectedTopicId = topic.id;
                      });
                      _scrollToChip(topic.id);
                      await _scrollToOrganization(topic.orgId);
                      if (mounted) {
                        setState(() {
                          _isScrollingProgrammatically = false;
                        });
                      }
                    },
                    backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r), side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.5))),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1.h, color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),

          // Main Scrollable Feed Content
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification && _isScrollingProgrammatically) {
                  if (mounted) {
                    setState(() {
                      _isScrollingProgrammatically = false;
                    });
                  }
                }
                return false;
              },
              child: ListView.builder(
                controller: _mainFeedScrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: _organizations.length,
                itemBuilder: (context, index) {
                  final organization = _organizations[index];
                  return VisibilityDetector(
                    key: ValueKey('org_section_${organization.id}'),
                    onVisibilityChanged: (visibilityInfo) {
                      if (!_isScrollingProgrammatically && visibilityInfo.visibleFraction > 0.4) {
                        final relevantTopic = _topics.firstWhere((t) => t.orgId == organization.id, orElse: () => _topics.first);

                        if (_selectedTopicId != relevantTopic.id) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                _selectedTopicId = relevantTopic.id;
                              });
                              _scrollToChip(relevantTopic.id);
                            }
                          });
                        }
                      }
                    },
                    // CHANGE: Pass the topics list and selected topic ID down to the section widget
                    child: OrganizationFeedSection(key: _organizationKeys[organization.id], organization: organization, topics: _topics, selectedTopicId: _selectedTopicId),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. Organization Feed Section Widget (MODIFIED) ---
class OrganizationFeedSection extends StatelessWidget {
  final Organization organization;
  final List<Topic> topics;
  final String? selectedTopicId;

  const OrganizationFeedSection({Key? key, required this.organization, required this.topics, required this.selectedTopicId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Find the full object for the selected topic
    final Topic? selectedTopic = topics.where((t) => t.id == selectedTopicId).isNotEmpty ? topics.firstWhere((t) => t.id == selectedTopicId) : null;

    // Check if the currently selected topic belongs to THIS organization
    final bool isTopicForThisOrg = selectedTopic?.orgId == organization.id;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align items to the top
            children: [
              CircleAvatar(radius: 18.r, backgroundImage: NetworkImage(organization.logoUrl), backgroundColor: Theme.of(context).colorScheme.primaryContainer),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(organization.name, style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(organization.type, style: GoogleFonts.lato(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                    // NEW: Conditionally display the selected topic's name
                    if (isTopicForThisOrg && selectedTopic != null)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text('Topic: ${selectedTopic.name}', style: GoogleFonts.lato(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('View All posts from ${organization.name}')));
                },
                child: Text('View All', style: GoogleFonts.lato(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12.w, mainAxisSpacing: 12.h, childAspectRatio: 0.8),
            itemCount: 4, // Placeholder for 4 posts per organization
            itemBuilder: (context, index) {
              return PlaceholderPost(postNumber: index + 1);
            },
          ),
        ],
      ),
    );
  }
}

// --- 4. Placeholder Post Widget ---
class PlaceholderPost extends StatelessWidget {
  final int postNumber;

  const PlaceholderPost({Key? key, required this.postNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5), borderRadius: BorderRadius.circular(10.r), border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3))),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_outlined, size: 36.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
          SizedBox(height: 6.h),
          Text('Post $postNumber', style: GoogleFonts.lato(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
          Text('Preview text here...', textAlign: TextAlign.center, style: GoogleFonts.lato(fontSize: 11.sp, color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
