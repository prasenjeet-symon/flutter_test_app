import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // Make sure you've added this to your pubspec.yaml

// --- Activity Data Model ---
enum ActivityType {
  post,
  comment,
  like,
  follow,
  share,
  milestone, // e.g., "reached 100 followers"
  joinOrg, // e.g., "joined Tech Innovations Inc."
  event, // e.g., "attended 'Future of AI' workshop"
  badge, // e.g., "earned 'Community Builder' badge"
  reorder, // e.g., "reordered their interests"
  addLink, // e.g., "added a new social link"
}

class Activity {
  final String id;
  final String actorName; // Name of the user/entity performing the action
  final String actorAvatarUrl; // URL of the actor's profile picture
  final ActivityType type;
  final String description; // A concise summary of the activity
  final DateTime timestamp;
  final String? relatedContentPreview; // Short text preview or image URL if applicable
  final String? targetName; // e.g., "Jane Smith" (if followed), "My New Idea" (if liked a post)
  final String? targetId; // ID of the target entity (optional)

  Activity({required this.id, required this.actorName, required this.actorAvatarUrl, required this.type, required this.description, required this.timestamp, this.relatedContentPreview, this.targetName, this.targetId});
}

// --- User Activity Timeline Screen ---
class UserActivityTimelineScreen extends StatelessWidget {
  const UserActivityTimelineScreen({Key? key}) : super(key: key);

  // Helper to generate dummy activity data for demonstration
  List<Activity> _generateDummyActivities() {
    final now = DateTime.now();
    return [
      Activity(
        id: 'a1',
        actorName: 'You',
        actorAvatarUrl: 'https://picsum.photos/id/1005/50/50',
        type: ActivityType.post,
        description: 'You posted a new update',
        timestamp: now.subtract(const Duration(minutes: 5)),
        relatedContentPreview: 'Excited to announce our new project!',
      ),
      Activity(
        id: 'a2',
        actorName: 'Jane Doe',
        actorAvatarUrl: 'https://picsum.photos/id/1025/50/50',
        type: ActivityType.comment,
        description: 'Jane Doe commented on your post',
        timestamp: now.subtract(const Duration(minutes: 15)),
        targetName: 'your post "Excited to announce..."',
      ),
      Activity(
        id: 'a3',
        actorName: 'You',
        actorAvatarUrl: 'https://picsum.photos/id/1005/50/50',
        type: ActivityType.like,
        description: 'You liked a post by Tech Innovations Inc.',
        timestamp: now.subtract(const Duration(hours: 1)),
        targetName: 'Tech Innovations Inc.',
      ),
      Activity(id: 'a4', actorName: 'John Smith', actorAvatarUrl: 'https://picsum.photos/id/1027/50/50', type: ActivityType.follow, description: 'John Smith started following you', timestamp: now.subtract(const Duration(hours: 3))),
      Activity(id: 'a5', actorName: 'You', actorAvatarUrl: 'https://picsum.photos/id/1005/50/50', type: ActivityType.reorder, description: 'You reordered your social interests', timestamp: now.subtract(const Duration(hours: 5))),
      Activity(
        id: 'a6',
        actorName: 'Community Outreach Foundation',
        actorAvatarUrl: 'https://picsum.photos/id/402/50/50',
        type: ActivityType.event,
        description: 'Community Outreach Foundation is hosting "Clean Up Drive"',
        timestamp: now.subtract(const Duration(days: 1)),
        relatedContentPreview: 'Join us this Saturday for a community cleanup.',
      ),
      Activity(
        id: 'a7',
        actorName: 'You',
        actorAvatarUrl: 'https://picsum.photos/id/1005/50/50',
        type: ActivityType.addLink,
        description: 'You added a new social media link',
        timestamp: now.subtract(const Duration(days: 2, hours: 2)),
        relatedContentPreview: 'LinkedIn profile added.',
      ),
      Activity(
        id: 'a8',
        actorName: 'Global Spiritual Network',
        actorAvatarUrl: 'https://picsum.photos/id/401/50/50',
        type: ActivityType.milestone,
        description: 'Global Spiritual Network reached 10,000 members',
        timestamp: now.subtract(const Duration(days: 3)),
      ),
      Activity(id: 'a9', actorName: 'You', actorAvatarUrl: 'https://picsum.photos/id/1005/50/50', type: ActivityType.badge, description: 'You earned the "Early Supporter" badge', timestamp: now.subtract(const Duration(days: 5))),
      Activity(
        id: 'a10',
        actorName: 'Creative Arts Collective',
        actorAvatarUrl: 'https://picsum.photos/id/403/50/50',
        type: ActivityType.post,
        description: 'Creative Arts Collective shared a new gallery',
        timestamp: now.subtract(const Duration(days: 7)),
        relatedContentPreview: 'Check out our latest digital art collection!',
      ),
    ];
  }

  // Helper function to get an appropriate icon for each activity type
  IconData _getIconForActivityType(ActivityType type) {
    switch (type) {
      case ActivityType.post:
        return Icons.article;
      case ActivityType.comment:
        return Icons.comment;
      case ActivityType.like:
        return Icons.favorite;
      case ActivityType.follow:
        return Icons.person_add;
      case ActivityType.share:
        return Icons.share;
      case ActivityType.milestone:
        return Icons.star;
      case ActivityType.joinOrg:
        return Icons.group_add;
      case ActivityType.event:
        return Icons.event;
      case ActivityType.badge:
        return Icons.emoji_events;
      case ActivityType.reorder:
        return Icons.sort;
      case ActivityType.addLink:
        return Icons.link;
      default:
        return Icons.info_outline;
    }
  }

  // Helper function to format timestamp into a user-friendly relative string
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).ceil();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      // For older activities, use a standard date format
      return DateFormat.yMMMd().format(timestamp); // e.g., "Jul 24, 2024"
    }
  }

  @override
  Widget build(BuildContext context) {
    // Generate dummy activities for display
    final activities = _generateDummyActivities();

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Activity Timeline', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back to the previous screen
          },
        ),
      ),
      body: SafeArea(
        // Ensures content is not obscured by system UI (e.g., notches)
        child:
            activities
                    .isEmpty // Display a message if there are no activities
                ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_empty, size: 80.sp, color: Theme.of(context).colorScheme.outline),
                        SizedBox(height: 16.h),
                        Text('No activity to display yet.', style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )
                : ListView.builder(
                  // Use ListView.builder for efficient display of a list
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    // Determine if this is the last item to hide the vertical line below it
                    final isLast = index == activities.length - 1;

                    return _ActivityTimelineItem(activity: activity, isLast: isLast, getIconForActivityType: _getIconForActivityType, formatTimestamp: _formatTimestamp);
                  },
                ),
      ),
    );
  }
}

// --- Widget for a single timeline item ---
class _ActivityTimelineItem extends StatelessWidget {
  final Activity activity;
  final bool isLast; // Controls if the vertical line extends below this item
  final IconData Function(ActivityType) getIconForActivityType;
  final String Function(DateTime) formatTimestamp;

  const _ActivityTimelineItem({Key? key, required this.activity, required this.isLast, required this.getIconForActivityType, required this.formatTimestamp}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      // Ensures the Row children take up the height of the tallest child
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Make children stretch vertically to align timeline
        children: [
          // Timeline Indicator Column (Fixed width for alignment)
          SizedBox(
            width: 48.w, // Fixed width for the timeline column
            child: Column(
              children: [
                // Activity Dot/Icon
                Container(
                  width: 32.sp,
                  height: 32.sp,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primaryContainer),
                  child: Icon(getIconForActivityType(activity.type), color: Theme.of(context).colorScheme.onPrimaryContainer, size: 18.sp),
                ),
                // Vertical Line (extends down unless it's the last item)
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2.w, // Thickness of the timeline line
                      color: Theme.of(context).colorScheme.outlineVariant, // Color of the line
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 12.w), // Space between timeline line and activity content
          // Activity Content Column (Takes remaining width)
          Expanded(
            child: Padding(
              // Add bottom padding to separate items, but not for the very last one
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.description, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4.h), // Small spacing between description and timestamp
                  Text(formatTimestamp(activity.timestamp), style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 11.sp)),
                  // Display related content preview if available
                  if (activity.relatedContentPreview != null && activity.relatedContentPreview!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant, borderRadius: BorderRadius.circular(8.r)),
                        child: Text(activity.relatedContentPreview!, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  // Display actor's avatar and name if relevant (e.g., if another user performed action)
                  if (activity.actorName != 'You')
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Row(
                        children: [
                          CircleAvatar(radius: 12.r, backgroundImage: NetworkImage(activity.actorAvatarUrl), backgroundColor: Theme.of(context).colorScheme.surfaceVariant),
                          SizedBox(width: 8.w),
                          Text(activity.actorName, style: Theme.of(context).textTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
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
