import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class PostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String imageUrl;
  final String caption;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;
  final String? topic;
  final String? organizationName;
  final double? aspectRatio;
  final int? originalWidth;
  final int? originalHeight;
  final bool isVerified;
  bool isSaved;

  PostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.imageUrl,
    required this.caption,
    required this.timestamp,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.topic,
    this.organizationName,
    this.aspectRatio,
    this.originalWidth,
    this.originalHeight,
    this.isVerified = false,
    this.isSaved = false,
  });
}

class TumblrFeedScreen extends StatefulWidget {
  const TumblrFeedScreen({Key? key}) : super(key: key);

  @override
  State<TumblrFeedScreen> createState() => _TumblrFeedScreenState();
}

class _TumblrFeedScreenState extends State<TumblrFeedScreen> {
  List<PostModel> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadDummyPosts();
  }

  void _loadDummyPosts() {
    _posts = [
      PostModel(
        id: 'post_1',
        userId: 'user_a',
        userName: 'wanderlust_diary',
        userAvatarUrl: 'https://picsum.photos/id/1012/50/50',
        imageUrl: 'https://picsum.photos/id/1016/800/600',
        caption: 'Chasing the last rays of sun. Every sunset is an opportunity to reset.',
        timestamp: DateTime.now().subtract(Duration(days: 2, hours: 5)),
        likesCount: 125,
        commentsCount: 15,
        topic: 'Nature Photography',
        organizationName: 'Nature Lovers Club',
        aspectRatio: 4 / 3,
        isVerified: true,
      ),
      PostModel(
        id: 'post_2',
        userId: 'user_b',
        userName: 'art_explorer',
        userAvatarUrl: 'https://picsum.photos/id/660/50/50',
        imageUrl: 'https://picsum.photos/id/1050/800/600',
        caption: 'Lost in thoughts and reflections. This piece always speaks to me.',
        timestamp: DateTime.now().subtract(Duration(hours: 10)),
        likesCount: 89,
        commentsCount: 8,
        topic: 'Abstract Art',
        organizationName: 'Global Art Society',
        aspectRatio: 16 / 9,
      ),
      PostModel(
        id: 'post_3',
        userId: 'user_c',
        userName: 'cozy_reads',
        userAvatarUrl: 'https://picsum.photos/id/338/50/50',
        imageUrl: 'https://picsum.photos/id/1043/800/1200',
        caption: 'A perfect afternoon with a warm brew and a good book. What are you reading today?',
        timestamp: DateTime.now().subtract(Duration(hours: 3)),
        likesCount: 201,
        commentsCount: 22,
        topic: 'Reading Nook',
        organizationName: 'Bookworm Community',
        aspectRatio: 2 / 3,
      ),
      PostModel(
        id: 'post_4',
        userId: 'user_d',
        userName: 'urban_wanderer',
        userAvatarUrl: 'https://picsum.photos/id/100/50/50',
        imageUrl: 'https://picsum.photos/id/201/1200/800',
        caption: 'City lights and bustling nights. There is something truly magical about urban landscapes.',
        timestamp: DateTime.now().subtract(Duration(minutes: 45)),
        likesCount: 50,
        commentsCount: 5,
        topic: 'City Life',
        organizationName: 'Urban Explorers',
        originalWidth: 1200,
        originalHeight: 800,
        isVerified: true,
      ),
      PostModel(
        id: 'post_5',
        userId: 'user_e',
        userName: 'foodie_fusion',
        userAvatarUrl: 'https://picsum.photos/id/40/50/50',
        imageUrl: 'https://picsum.photos/id/1047/600/600',
        caption: 'Experimenting with new recipes! This one turned out delicious.',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 2)),
        likesCount: 180,
        commentsCount: 10,
        topic: 'Cooking Adventures',
        organizationName: 'Gourmet Collective',
        aspectRatio: 1 / 1,
        isSaved: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tumblr Inspired Feed', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          itemCount: _posts.length,
          itemBuilder: (context, index) {
            return Padding(padding: EdgeInsets.only(bottom: 24.h), child: ImagePostWidget(post: _posts[index]));
          },
        ),
      ),
    );
  }
}

class ImagePostWidget extends StatefulWidget {
  final PostModel post;

  const ImagePostWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<ImagePostWidget> createState() => _ImagePostWidgetState();
}

class _ImagePostWidgetState extends State<ImagePostWidget> {
  late bool _isSaved;

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

  void _showImageFullScreen(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.black.withOpacity(0.9),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.1,
                  maxScale: 4.0,
                  child: Image.network(
                    widget.post.imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), value: loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Colors.grey[800], child: Icon(Icons.broken_image, size: 50.sp, color: Colors.white));
                    },
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
      },
    );
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isSaved ? 'Post saved!' : 'Post unsaved.'), duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    double? calculatedAspectRatio = widget.post.aspectRatio;
    if (calculatedAspectRatio == null && widget.post.originalWidth != null && widget.post.originalHeight != null && widget.post.originalHeight! > 0) {
      calculatedAspectRatio = widget.post.originalWidth! / widget.post.originalHeight!;
    }
    calculatedAspectRatio ??= 4 / 3;

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
            GestureDetector(
              onTap: () => _showImageFullScreen(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: AspectRatio(
                  aspectRatio: calculatedAspectRatio,
                  child: Image.network(
                    widget.post.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator(value: loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)));
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: Theme.of(context).colorScheme.errorContainer, child: Icon(Icons.broken_image, size: 50.sp, color: Theme.of(context).colorScheme.onErrorContainer));
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(widget.post.caption, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface)),
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
