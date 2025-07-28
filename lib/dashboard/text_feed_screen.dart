import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class TextPostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String body;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;
  final String? topic;
  final String? organizationName;
  final bool isVerified;
  bool isSaved;

  TextPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.body,
    required this.timestamp,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.topic,
    this.organizationName,
    this.isVerified = false,
    this.isSaved = false,
  });
}

class TextFeedScreen extends StatefulWidget {
  const TextFeedScreen({Key? key}) : super(key: key);

  @override
  State<TextFeedScreen> createState() => _TextFeedScreenState();
}

class _TextFeedScreenState extends State<TextFeedScreen> {
  List<TextPostModel> _textPosts = [];

  @override
  void initState() {
    super.initState();
    _loadDummyTextPosts();
  }

  void _loadDummyTextPosts() {
    _textPosts = [
      TextPostModel(
        id: 'text_1',
        userId: 't_user_a',
        userName: 'thought_weaver',
        userAvatarUrl: 'https://picsum.photos/id/1025/50/50',
        body:
            'In our fast-paced world, finding moments of mindfulness can be truly transformative. It\'s about being being present, observing without judgment, and appreciating the simple things. Starting with just five minutes of conscious breathing each day can make a significant difference. Try it and feel the shift in your perspective.',
        timestamp: DateTime.now().subtract(Duration(days: 3, hours: 2)),
        likesCount: 345,
        commentsCount: 50,
        topic: 'Mindfulness',
        organizationName: 'Zen Institute',
        isVerified: true,
      ),
      TextPostModel(
        id: 'text_2',
        userId: 't_user_b',
        userName: 'code_whisperer',
        userAvatarUrl: 'https://picsum.photos/id/403/50/50',
        body:
            'Asynchronous programming is fundamental in Dart/Flutter. `async` and `await` keywords make working with Futures much cleaner and more readable than traditional callbacks. Remember, `async` marks a function as asynchronous, allowing it to use `await`, and `await` pauses execution until a Future completes, making asynchronous code look synchronous.',
        timestamp: DateTime.now().subtract(Duration(hours: 15)),
        likesCount: 189,
        commentsCount: 25,
        topic: 'Programming',
        organizationName: 'DevHub',
      ),
      TextPostModel(
        id: 'text_3',
        userId: 't_user_c',
        userName: 'daily_journal',
        userAvatarUrl: 'https://picsum.photos/id/42/50/50',
        body: 'Today was a day of small victories. Finished that challenging report, had a great coffee with an old friend, and found a new favorite song. It\'s the little things that add up.',
        timestamp: DateTime.now().subtract(Duration(minutes: 40)),
        likesCount: 75,
        commentsCount: 10,
        topic: 'Daily Reflections',
        organizationName: 'Self-Care Club',
        isSaved: true,
      ),
      TextPostModel(
        id: 'text_4',
        userId: 't_user_d',
        userName: 'future_tech',
        userAvatarUrl: 'https://picsum.photos/id/601/50/50',
        body:
            'Artificial intelligence is no longer just for data analysis. It\'s now generating art, composing music, and even writing compelling narratives. While some feel threatened, others see it as a powerful co-creator tool, pushing the boundaries of human creativity. The collaboration between human and AI promises exciting new artistic expressions.',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 8)),
        likesCount: 502,
        commentsCount: 88,
        topic: 'Artificial Intelligence',
        organizationName: 'Innovate Minds',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Posts', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          itemCount: _textPosts.length,
          itemBuilder: (context, index) {
            return Padding(padding: EdgeInsets.only(bottom: 24.h), child: TextPostWidget(post: _textPosts[index]));
          },
        ),
      ),
    );
  }
}

class TextPostWidget extends StatefulWidget {
  final TextPostModel post;

  const TextPostWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<TextPostWidget> createState() => _TextPostWidgetState();
}

class _TextPostWidgetState extends State<TextPostWidget> {
  late bool _isSaved;
  bool _isTranslated = false;

  String _getSimulatedTranslation(String originalText) {
    return 'This is the translated version of: "${originalText.substring(0, originalText.length > 50 ? 50 : originalText.length)}..." (Simulated Translation)';
  }

  @override
  void initState() {
    super.initState();
    _isSaved = widget.post.isSaved;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isSaved ? 'Post saved!' : 'Post unsaved.'), duration: const Duration(seconds: 1)));
  }

  void _toggleTranslation() {
    setState(() {
      _isTranslated = !_isTranslated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayBody = _isTranslated ? _getSimulatedTranslation(widget.post.body) : widget.post.body;

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
                    Text(_formatTimestamp(widget.post.timestamp), style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  ],
                ),
                Spacer(),
                IconButton(icon: Icon(Icons.more_horiz, size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant), onPressed: () {}),
              ],
            ),
            SizedBox(height: 16.h),
            Text(displayBody, style: GoogleFonts.lato(fontSize: 15.sp, color: Theme.of(context).colorScheme.onSurface, height: 1.4)),
            // Removed SizedBox(height: 8.h) here to compact space
            if (widget.post.topic != null && widget.post.topic!.isNotEmpty) SizedBox(height: 12.h),
            if (widget.post.topic != null && widget.post.topic!.isNotEmpty)
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
            Row(
              children: [
                Icon(Icons.favorite_border, size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(width: 4.w),
                Text('${widget.post.likesCount}', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                SizedBox(width: 16.w),
                Icon(Icons.chat_bubble_outline, size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                SizedBox(width: 4.w),
                Text('${widget.post.commentsCount}', style: Theme.of(context).textTheme.labelMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                Spacer(),
                // Moved the translate icon here
                IconButton(
                  icon: Icon(_isTranslated ? Icons.language_outlined : Icons.translate, size: 22.sp, color: Theme.of(context).colorScheme.primary),
                  tooltip: _isTranslated ? 'Show Original' : 'Translate',
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  onPressed: _toggleTranslation,
                ),
                SizedBox(width: 8.w), // Space between translate and save icons
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
