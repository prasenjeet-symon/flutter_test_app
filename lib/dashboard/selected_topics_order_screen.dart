import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// --- Data Model (duplicated here for independent dummy data generation) ---
// In a real app, this should ideally be in a shared models file.
class SocialTopic {
  final String id;
  final String name;
  bool isSelected; // Keeping this property, though its use might be minimal here
  final String organizationName;
  final String organizationId;

  SocialTopic({required this.id, required this.name, this.isSelected = false, required this.organizationName, required this.organizationId});
}
// -------------------------------------------------------------------

class SelectedTopicsOrderScreen extends StatefulWidget {
  // We'll make initialSelectedTopics optional, so it can be used for dummy data
  final List<SocialTopic>? initialSelectedTopics;

  const SelectedTopicsOrderScreen({
    Key? key,
    this.initialSelectedTopics, // Made optional
  }) : super(key: key);

  @override
  State<SelectedTopicsOrderScreen> createState() => _SelectedTopicsOrderScreenState();
}

class _SelectedTopicsOrderScreenState extends State<SelectedTopicsOrderScreen> {
  late List<SocialTopic> _orderedTopics;

  @override
  void initState() {
    super.initState();
    // Use provided data if available and not empty, otherwise generate dummy data
    _orderedTopics = widget.initialSelectedTopics != null && widget.initialSelectedTopics!.isNotEmpty ? List<SocialTopic>.from(widget.initialSelectedTopics!) : _generateDummySelectedTopics(); // Call new dummy data method
  }

  // --- Dummy Data Generation for SelectedTopicsOrderScreen ---
  List<SocialTopic> _generateDummySelectedTopics() {
    return [
      SocialTopic(id: 't1', name: 'Artificial Intelligence', organizationName: 'Tech Innovations Inc.', organizationId: 'org1', isSelected: true),
      SocialTopic(id: 't5', name: 'Software Development', organizationName: 'Tech Innovations Inc.', organizationId: 'org1', isSelected: true),
      SocialTopic(id: 't8', name: 'Yoga & Wellness', organizationName: 'Global Spiritual Network', organizationId: 'org2', isSelected: true),
      SocialTopic(id: 't11', name: 'Local Volunteering', organizationName: 'Community Outreach Foundation', organizationId: 'org3', isSelected: true),
      SocialTopic(id: 't16', name: 'Digital Art', organizationName: 'Creative Arts Collective', organizationId: 'org4', isSelected: true),
      SocialTopic(id: 't20', name: 'Web Development', organizationName: 'Tech Innovations Inc.', organizationId: 'org1', isSelected: true),
      SocialTopic(id: 't23', name: 'Community Events', organizationName: 'Community Outreach Foundation', organizationId: 'org3', isSelected: true),
      SocialTopic(id: 't10', name: 'Spiritual Growth', organizationName: 'Global Spiritual Network', organizationId: 'org2', isSelected: true),
      SocialTopic(id: 't17', name: 'Music Production', organizationName: 'Creative Arts Collective', organizationId: 'org4', isSelected: true),
      SocialTopic(id: 't3', name: 'Cybersecurity', organizationName: 'Tech Innovations Inc.', organizationId: 'org1', isSelected: true),
    ];
  }
  // ------------------------------------------------------------------

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final SocialTopic item = _orderedTopics.removeAt(oldIndex);
      _orderedTopics.insert(newIndex, item);
    });
  }

  // Helper to generate a short name from the organization's full name
  String _getOrganizationShortName(String orgName) {
    final parts = orgName.split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.length > 1) {
      return parts.map((part) => part[0].toUpperCase()).join('');
    }
    return orgName.length > 5 ? '${orgName.substring(0, 5)}...' : orgName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reorder Your Interests', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.of(context).pop(_orderedTopics);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, size: 24.sp, color: Theme.of(context).colorScheme.primary),
            onPressed: () {
              // TODO: Here you would typically save the _orderedTopics list
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Topics order saved!')));
              Navigator.of(context).pop(_orderedTopics);
            },
          ),
        ],
      ),
      // Wrap the body content with SafeArea
      body: SafeArea(
        child:
            _orderedTopics.isEmpty
                ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, size: 80.sp, color: Theme.of(context).colorScheme.outline),
                        SizedBox(height: 16.h),
                        Text('No topics selected to reorder.', style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
                : Column(
                  // Use Column to stack the description and the reorderable list
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      child: Text(
                        'Reorder your selected topics by dragging them. The order here will determine how topics are prioritized and displayed in your personalized feed.',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      // ReorderableListView needs to take up the remaining available space
                      child: ReorderableListView.builder(
                        padding: EdgeInsets.all(16.w), // Apply padding to the list itself
                        itemCount: _orderedTopics.length,
                        itemBuilder: (context, index) {
                          final topic = _orderedTopics[index];
                          return Card(
                            key: ValueKey(topic.id), // Unique key for reordering items
                            margin: EdgeInsets.symmetric(vertical: 6.h),
                            color: Theme.of(context).colorScheme.surfaceContainerHigh,
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(topic.name, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                                        SizedBox(height: 4.h),
                                        Text(_getOrganizationShortName(topic.organizationName), style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12.sp)),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.drag_handle, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 24.sp),
                                ],
                              ),
                            ),
                          );
                        },
                        onReorder: _onReorder,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
