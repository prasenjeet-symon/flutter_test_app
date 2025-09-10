import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:add_2_calendar/add_2_calendar.dart';


class EventPostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  // final String eventTitle;
  final String eventDescription;
  final String? eventImageUrl;
  final DateTime eventDateTime;
  final String? location;
  int likesCount;
  final int commentsCount;
  final String? topic;
  final String? organizationName;
  final bool isVerified;
  bool isSaved;
  bool isLiked;

  EventPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    // required this.eventTitle,
    required this.eventDescription,
    this.eventImageUrl,
    required this.eventDateTime,
    this.location,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.topic,
    this.organizationName,
    this.isVerified = false,
    this.isSaved = false,
    this.isLiked = false,
  });
}

class EventFeedScreen extends StatefulWidget {
  const EventFeedScreen({Key? key}) : super(key: key);

  @override
  State<EventFeedScreen> createState() => _EventFeedScreenState();
}

class _EventFeedScreenState extends State<EventFeedScreen> {
  List<EventPostModel> _eventPosts = [];

  @override
  void initState() {
    super.initState();
    _loadDummyEventPosts();
  }

  void _loadDummyEventPosts() {
    _eventPosts = [
      EventPostModel(
        id: 'event_1',
        userId: 'e_user_a',
        userName: 'Local Events Hub',
        userAvatarUrl: 'https://picsum.photos/id/10/50/50',
        eventDescription: 'Join us to help clean up the local community garden and prepare it for spring planting! All ages are welcome.',
        eventImageUrl: 'https://picsum.photos/id/1043/800/600',
        eventDateTime: DateTime.parse("2025-09-14T10:00:00.000Z"),
        location: 'Oakwood Community Park',
        likesCount: 45,
        commentsCount: 10,
        topic: 'Community',
        isVerified: true,
        isLiked: true,
      ),
      EventPostModel(
        id: 'event_2',
        userId: 'e_user_b',
        userName: 'Tech Meetup Group',
        userAvatarUrl: 'https://picsum.photos/id/1/50/50',
        eventDescription: 'An in-depth workshop on the latest features in Flutter and Dart for building cross-platform apps. RSVP here: https://example.com/flutter-workshop',
        eventImageUrl: 'https://picsum.photos/id/1029/800/600',
        eventDateTime: DateTime.parse("2025-09-19T18:30:00.000Z"),
        location: 'Digital Innovation Center',
        likesCount: 110,
        commentsCount: 25,
        topic: 'Technology',
        organizationName: 'DevZone',
        isSaved: true,
      ),
      EventPostModel(
        id: 'event_3',
        userId: 'e_user_c',
        userName: 'Past Events Archive',
        userAvatarUrl: 'https://picsum.photos/id/20/50/50',
        eventDescription: 'A look back at our fun retro gaming night from last month!',
        eventImageUrl: 'https://picsum.photos/id/1067/800/600',
        eventDateTime: DateTime.parse("2025-08-10T20:00:00.000Z"),
        location: 'The Arcade',
        likesCount: 88,
        commentsCount: 42,
        topic: 'Gaming',
        organizationName: 'Nostalgia Inc.',
      ),
    ];
  }

  void _showImageFullScreen(String imageUrl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FullScreenImageViewer(imageUrl: imageUrl),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events Feed', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          itemCount: _eventPosts.length,
          itemBuilder: (context, index) {
            final post = _eventPosts[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: EventPostWidget(
                post: post,
                onImageTap: () {
                  if (post.eventImageUrl != null) {
                    _showImageFullScreen(post.eventImageUrl!);
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.9),
      child: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error_outline, color: Colors.white, size: 50),
              ),
            ),
          ),
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Center(
              child: SafeArea(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  ),
                  child: Text('Close', style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class EventPostWidget extends StatefulWidget {
  final EventPostModel post;
  final VoidCallback onImageTap;

  const EventPostWidget({Key? key, required this.post, required this.onImageTap}) : super(key: key);

  @override
  State<EventPostWidget> createState() => _EventPostWidgetState();
}

class _EventPostWidgetState extends State<EventPostWidget> {
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.post.isSaved;
  }

  String _formatTimestamp(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inMinutes < 1) return 'just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isSaved ? 'Post saved!' : 'Post unsaved.'), duration: const Duration(seconds: 1)));
  }

  void _toggleLike() {
    setState(() {
      if (widget.post.isLiked) {
        widget.post.likesCount--;
      } else {
        widget.post.likesCount++;
      }
      widget.post.isLiked = !widget.post.isLiked;
    });
  }

  void _addEventToCalendar() {
    final DateTime eventStartDateTime = widget.post.eventDateTime;
    final DateTime eventEndDateTime = eventStartDateTime.add(const Duration(hours: 2));

    final Event calendarEvent = Event(
      title: widget.post.eventDescription,
      description: widget.post.eventDescription,
      location: widget.post.location ?? '',
      startDate: eventStartDateTime,
      endDate: eventEndDateTime,
    );

    Add2Calendar.addEvent2Cal(calendarEvent);
  }

  TextSpan _buildRichText(BuildContext context, String text) {
    final urlRegex = RegExp(r"(https?:\/\/[^\s]+)", caseSensitive: false);
    final List<TextSpan> spans = [];
    int start = 0;

    for (final match in urlRegex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      final String url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: GoogleFonts.lato(
            fontSize: 15.sp,
            color: Theme.of(context).colorScheme.primary,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open $url')),
                  );
                }
              }
            },
        ),
      );
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return TextSpan(
      children: spans,
      style: GoogleFonts.lato(
        fontSize: 15.sp,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // **FIX**: Convert the UTC DateTime to the user's local timezone before formatting.
    final localEventDateTime = widget.post.eventDateTime.toLocal();

    final formattedDate = DateFormat('EEE, MMM d').format(localEventDateTime);
    final formattedTime = DateFormat.jm().format(localEventDateTime);

    final bool isFutureEvent = widget.post.eventDateTime.isAfter(DateTime.now());


    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r), side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), width: 1.w)),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 20.r, backgroundImage: NetworkImage(widget.post.userAvatarUrl), backgroundColor: Theme.of(context).colorScheme.primaryContainer, onBackgroundImageError: (exception, stackTrace) {}),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.post.userName, style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                        if (widget.post.isVerified) Padding(padding: EdgeInsets.only(left: 4.w), child: Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 14.sp)),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(_formatTimestamp(DateTime.now()), style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                const Spacer(),
                IconButton(icon: Icon(Icons.more_horiz, size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant), onPressed: () {}),
              ],
            ),
            SizedBox(height: 16.h),
            if (widget.post.eventImageUrl != null) ...[
              GestureDetector(
                onTap: widget.onImageTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.network(
                    widget.post.eventImageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200.h,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200.h,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Center(child: Icon(Icons.calendar_today, size: 50.sp, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            RichText(text: _buildRichText(context, widget.post.eventDescription)),
            SizedBox(height: 16.h),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined, size: 18.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(width: 8.w),
                Text('$formattedDate at $formattedTime', style: GoogleFonts.lato(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
            if (widget.post.location != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 18.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  SizedBox(width: 8.w),
                  Text(widget.post.location!, style: GoogleFonts.lato(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ],
            SizedBox(height: 16.h),
            if (isFutureEvent)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addEventToCalendar,
                  icon: Icon(Icons.calendar_month_outlined, size: 20.sp),
                  label: const Text('Add to Calendar'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    textStyle: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    'Event Ended',
                    style: GoogleFonts.lato(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            SizedBox(height: 16.h),
            if (widget.post.topic != null && widget.post.topic!.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08), borderRadius: BorderRadius.circular(4.r)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.post.topic!, style: Theme.of(context).textTheme.labelSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    if (widget.post.organizationName != null && widget.post.organizationName!.isNotEmpty)
                      Text(' - ${widget.post.organizationName!}', style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            Row(
              children: [
                GestureDetector(
                  onTap: _toggleLike,
                  child: Row(
                    children: [
                      Icon(
                        widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20.sp,
                        color: widget.post.isLiked ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${widget.post.likesCount}',
                        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.chat_bubble_outline, size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(width: 4.w),
                Text('${widget.post.commentsCount}', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const Spacer(),
                IconButton(icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border, size: 20.sp, color: _isSaved ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurfaceVariant), onPressed: _toggleSave),
                SizedBox(width: 8.w),
                Icon(Icons.share_outlined, size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
