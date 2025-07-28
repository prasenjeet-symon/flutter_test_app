import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// --- Data Models (can be moved to separate files in a real project) ---
class Organization {
  final String id;
  final String name;
  final String logoUrl; // Organization logo URL
  final bool isVerified; // Verified status for the organization
  final String type; // Type of organization (e.g., "Tech Company", "Non-profit")
  final List<SocialTopic> topics;

  Organization({required this.id, required this.name, required this.logoUrl, required this.isVerified, required this.type, required this.topics});
}

class SocialTopic {
  final String id;
  final String name;
  bool isSelected;

  SocialTopic({required this.id, required this.name, this.isSelected = false});
}
// -------------------------------------------------------------------

class SocialTopicsSelectionScreen extends StatefulWidget {
  const SocialTopicsSelectionScreen({Key? key}) : super(key: key);

  @override
  State<SocialTopicsSelectionScreen> createState() => _SocialTopicsSelectionScreenState();
}

class _SocialTopicsSelectionScreenState extends State<SocialTopicsSelectionScreen> {
  List<Organization> _organizations = [];

  @override
  void initState() {
    super.initState();
    _organizations = _generateDummyData(); // Populate with initial dummy data
  }

  // Helper method to toggle the selection state of a topic
  void _toggleTopicSelection(String organizationId, String topicId) {
    setState(() {
      for (var org in _organizations) {
        if (org.id == organizationId) {
          for (var topic in org.topics) {
            if (topic.id == topicId) {
              topic.isSelected = !topic.isSelected;
              break;
            }
          }
          break;
        }
      }
    });
  }

  // Method to generate dummy data for organizations and their topics
  List<Organization> _generateDummyData() {
    return [
      Organization(
        id: 'org1',
        name: 'Tech Innovations Inc.',
        logoUrl: 'https://picsum.photos/id/400/200/200',
        isVerified: true,
        type: 'Tech Company',
        topics: [
          SocialTopic(id: 't1', name: 'Artificial Intelligence', isSelected: true),
          SocialTopic(id: 't2', name: 'Blockchain Technology'),
          SocialTopic(id: 't3', name: 'Cybersecurity'),
          SocialTopic(id: 't4', name: 'Quantum Computing'),
          SocialTopic(id: 't5', name: 'Software Development', isSelected: true),
          SocialTopic(id: 't6', name: 'Data Science'),
          SocialTopic(id: 't20', name: 'Web Development'),
          SocialTopic(id: 't21', name: 'Mobile App Development'),
          SocialTopic(id: 't26', name: 'Cloud Computing'),
          SocialTopic(id: 't27', name: 'DevOps'),
          SocialTopic(id: 't28', name: 'Game Development'),
        ],
      ),
      Organization(
        id: 'org2',
        name: 'Global Spiritual Network',
        logoUrl: 'https://picsum.photos/id/401/200/200',
        isVerified: false,
        type: 'Non-profit',
        topics: [
          SocialTopic(id: 't7', name: 'Meditation Practices'),
          SocialTopic(id: 't8', name: 'Yoga & Wellness', isSelected: true),
          SocialTopic(id: 't9', name: 'Mindfulness Living'),
          SocialTopic(id: 't10', name: 'Spiritual Growth'),
          SocialTopic(id: 't22', name: 'Holistic Health'),
          SocialTopic(id: 't29', name: 'Energy Healing'),
        ],
      ),
      Organization(
        id: 'org3',
        name: 'Community Outreach Foundation',
        logoUrl: 'https://picsum.photos/id/402/200/200',
        isVerified: true,
        type: 'Non-profit',
        topics: [
          SocialTopic(id: 't11', name: 'Local Volunteering', isSelected: true),
          SocialTopic(id: 't12', name: 'Environmental Protection'),
          SocialTopic(id: 't13', name: 'Youth Mentorship'),
          SocialTopic(id: 't14', name: 'Homeless Support'),
          SocialTopic(id: 't15', name: 'Food Security'),
          SocialTopic(id: 't23', name: 'Community Events'),
        ],
      ),
      Organization(
        id: 'org4',
        name: 'Creative Arts Collective',
        logoUrl: 'https://picsum.photos/id/403/200/200',
        isVerified: false,
        type: 'Art Community',
        topics: [
          SocialTopic(id: 't16', name: 'Digital Art', isSelected: true),
          SocialTopic(id: 't17', name: 'Music Production'),
          SocialTopic(id: 't18', name: 'Creative Writing'),
          SocialTopic(id: 't19', name: 'Photography'),
          SocialTopic(id: 't24', name: 'Performing Arts'),
          SocialTopic(id: 't25', name: 'Fine Arts'),
          SocialTopic(id: 't30', name: 'Sculpture'),
        ],
      ),
    ];
  }

  // Helper to collect all currently selected topics (e.g., for saving)
  List<SocialTopic> _getSelectedTopics() {
    List<SocialTopic> selectedTopics = [];
    for (var org in _organizations) {
      for (var topic in org.topics) {
        if (topic.isSelected) {
          selectedTopics.add(topic);
        }
      }
    }
    return selectedTopics;
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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 24.sp, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('Select Your Interests', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          centerTitle: true,
          actions: [
            // NEW: Tooltip and Icon for changing topics order
            Tooltip(
              message: 'Sort topics', // Tooltip message
              child: IconButton(
                icon: Icon(Icons.sort, size: 24.sp, color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  // TODO: Implement logic to change/sort topics order
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sort topics action triggered!')));
                },
              ),
            ),
          ],
        ),
      ),
      body:
          _organizations.isEmpty
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.interests_outlined, size: 80.sp, color: Theme.of(context).colorScheme.outline),
                      SizedBox(height: 16.h),
                      Text('No Organizations or Topics Found', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                      SizedBox(height: 8.h),
                      Text('It looks like you\'re not part of any organizations with social topics yet.', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                itemCount: _organizations.length,
                itemBuilder: (context, index) {
                  final organization = _organizations[index];
                  return _OrganizationTopicsSection(organization: organization, onTopicToggle: _toggleTopicSelection);
                },
              ),
    );
  }
}

// Widget to display a single organization's details and its horizontal topics list
class _OrganizationTopicsSection extends StatelessWidget {
  final Organization organization;
  final Function(String organizationId, String topicId) onTopicToggle;

  const _OrganizationTopicsSection({Key? key, required this.organization, required this.onTopicToggle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double chipEffectiveHeight = 36.h;
    final double threeLineAreaHeight = (3 * chipEffectiveHeight) + (2 * 8.h);
    final double totalSizedBoxHeight = threeLineAreaHeight + 16.h;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Organization Header (Logo, Name, Verified, Type)
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(radius: 24.r, backgroundImage: NetworkImage(organization.logoUrl), backgroundColor: Theme.of(context).colorScheme.surfaceVariant),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(child: Text(organization.name, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
                        if (organization.isVerified) Padding(padding: EdgeInsets.only(left: 4.w), child: Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 16.sp)),
                      ],
                    ),
                    Text(organization.type, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h), // Spacing between header and topics
          // Pinterest-like Horizontal Scrolling Topics using MasonryGridView.count
          SizedBox(
            height: totalSizedBoxHeight, // Set height based on 3 lines + buffer
            child: MasonryGridView.count(
              crossAxisCount: 3, // Exactly 3 vertical lines (rows) of chips
              itemCount: organization.topics.length,
              scrollDirection: Axis.horizontal, // Scroll horizontally
              itemBuilder: (BuildContext context, int index) {
                final topic = organization.topics[index];
                return FilterChip(
                  label: Text(topic.name),
                  selected: topic.isSelected,
                  onSelected: (bool selected) {
                    onTopicToggle(organization.id, topic.id);
                  },
                  labelStyle: TextStyle(fontSize: 14.sp, color: topic.isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r), side: BorderSide(color: topic.isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline, width: 1.w)),
                  checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                );
              },
              mainAxisSpacing: 8.w, // Horizontal spacing between chips
              crossAxisSpacing: 8.h, // Vertical spacing between lines of chips
            ),
          ),
          SizedBox(height: 16.h), // Spacing between topics and the divider
          Divider(
            // Very light bottom border
            color: Theme.of(context).colorScheme.outlineVariant, // A subtle, light color for the line
            height: 1.h, // Controls the total height of the divider widget (including internal padding)
            thickness: 1.h, // Controls the actual thickness of the line
            indent: 0, // No indent from the left
            endIndent: 0, // No indent from the right
          ),
          SizedBox(height: 24.h), // Spacing after the divider, between organization sections
        ],
      ),
    );
  }
}
