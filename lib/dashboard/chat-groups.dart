import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // For formatting timestamps

// 1. Data Model for a Chat Group
class ChatGroup {
  final String id;
  final String name;
  final String imageUrl; // Can be a group icon or participant's image
  final String? lastMessage;
  final String? lastMessageSender;
  final DateTime? lastMessageTimestamp;
  final int unreadCount;

  ChatGroup({required this.id, required this.name, required this.imageUrl, this.lastMessage, this.lastMessageSender, this.lastMessageTimestamp, this.unreadCount = 0});
}

// 2. Main Screen to display chat groups
class ChatGroupsScreen extends StatefulWidget {
  const ChatGroupsScreen({Key? key}) : super(key: key);

  @override
  State<ChatGroupsScreen> createState() => _ChatGroupsScreenState();
}

class _ChatGroupsScreenState extends State<ChatGroupsScreen> {
  List<ChatGroup> _chatGroups = [];

  @override
  void initState() {
    super.initState();
    _chatGroups = _generateDummyData(); // Populate with dummy data
  }

  // Generate some dummy chat group data
  List<ChatGroup> _generateDummyData() {
    return [
      ChatGroup(
        id: 'cg1',
        name: 'Project Alpha Team',
        imageUrl: 'https://picsum.photos/id/200/200/200',
        lastMessage: 'Let\'s finalize the presentation slides.',
        lastMessageSender: 'Alice',
        lastMessageTimestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 3,
      ),
      ChatGroup(
        id: 'cg2',
        name: 'Family Chat',
        imageUrl: 'https://picsum.photos/id/201/200/200',
        lastMessage: 'Happy weekend everyone!',
        lastMessageSender: 'Mom',
        lastMessageTimestamp: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 0,
      ),
      ChatGroup(
        id: 'cg3',
        name: 'Gaming Squad',
        imageUrl: 'https://picsum.photos/id/202/200/200',
        lastMessage: 'Who\'s online for a match tonight?',
        lastMessageSender: 'GamerDude',
        lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 1,
      ),
      ChatGroup(
        id: 'cg4',
        name: 'Travel Buddies',
        imageUrl: 'https://picsum.photos/id/203/200/200',
        lastMessage: 'Don\'t forget your passports!',
        lastMessageSender: 'Sarah',
        lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 3)),
        unreadCount: 0,
      ),
      ChatGroup(
        id: 'cg5',
        name: 'Book Club',
        imageUrl: 'https://picsum.photos/id/204/200/200',
        lastMessage: 'Next meeting is on Tuesday.',
        lastMessageSender: 'Michael',
        lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 7)),
        unreadCount: 0,
      ),
      ChatGroup(
        id: 'cg6',
        name: 'Fitness Friends',
        imageUrl: 'https://picsum.photos/id/205/200/200',
        lastMessage: 'New workout routine just dropped!',
        lastMessageSender: 'Coach',
        lastMessageTimestamp: DateTime.now().subtract(const Duration(days: 5)),
        unreadCount: 2,
      ),
    ];
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
          bottom: PreferredSize(preferredSize: Size.fromHeight(1.h), child: Container(color: Theme.of(context).colorScheme.outline, height: 1.h)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 24.sp, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: Text('Group Chats', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          centerTitle: true,
        ),
      ),
      body:
          _chatGroups.isEmpty
              ? Center(
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 80.sp, color: Theme.of(context).colorScheme.outline),
                      SizedBox(height: 16.h),
                      Text('No Group Chats Yet', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                      SizedBox(height: 8.h),
                      Text('You are not part of any chat groups. Join one or create a new one!', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                itemCount: _chatGroups.length,
                itemBuilder: (context, index) {
                  final group = _chatGroups[index];
                  return ChatGroupTile(group: group);
                },
              ),
    );
  }
}

// 3. Widget for displaying a single chat group tile
class ChatGroupTile extends StatelessWidget {
  final ChatGroup group;

  const ChatGroupTile({Key? key, required this.group}) : super(key: key);

  // Helper to format the timestamp
  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (date.isAtSameMomentAs(today)) {
      return DateFormat('h:mm a').format(timestamp); // e.g., 10:30 AM
    } else if (today.difference(date).inDays == 1) {
      return 'Yesterday';
    } else if (now.difference(timestamp).inDays < 7) {
      return DateFormat('EEE').format(timestamp); // e.g., Mon, Tue
    } else if (now.year == timestamp.year) {
      return DateFormat('MMM d').format(timestamp); // e.g., Jul 27
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp); // e.g., Jul 27, 2024
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation to the specific chat group screen
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped on chat group: ${group.name}')));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
        child: Row(
          children: [
            CircleAvatar(radius: 30.r, backgroundImage: NetworkImage(group.imageUrl), backgroundColor: Theme.of(context).colorScheme.surfaceVariant),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  if (group.lastMessage != null && group.lastMessageSender != null)
                    Text(
                      '${group.lastMessageSender}: ${group.lastMessage}',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: group.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  else if (group.lastMessage != null)
                    Text(
                      group.lastMessage!,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: group.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (group.lastMessageTimestamp != null) Text(_formatTimestamp(group.lastMessageTimestamp), style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 10.sp)),
                if (group.unreadCount > 0) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.all(6.r),
                    constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                    child: Center(
                      child: Text(
                        group.unreadCount > 99 ? '99+' : group.unreadCount.toString(),
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
