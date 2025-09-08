import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:google_fonts/google_fonts.dart';


class YouTubePostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String videoId;
  final String title;
  final String description;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;
  final String? topic;
  final String? organizationName;
  final bool isVerified;
  bool isSaved;

  YouTubePostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.videoId,
    required this.title,
    required this.description,
    required this.timestamp,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.topic,
    this.organizationName,
    this.isVerified = false,
    this.isSaved = false,
  });

  String get thumbnailUrl => 'https://img.youtube.com/vi/$videoId/0.jpg';
  String get videoUrl => 'https://www.youtube.com/watch?v=$videoId';
}
class YouTubeFeedScreen extends StatefulWidget {
  const YouTubeFeedScreen({Key? key}) : super(key: key);

  @override
  State<YouTubeFeedScreen> createState() => _YouTubeFeedScreenState();
}

class _YouTubeFeedScreenState extends State<YouTubeFeedScreen> {
  List<YouTubePostModel> _youtubePosts = [];

  @override
  void initState() {
    super.initState();
    _loadDummyYouTubePosts();
  }

  void _loadDummyYouTubePosts() {
    _youtubePosts = [
      YouTubePostModel(
        id: 'youtube_1',
        userId: 'y_user_a',
        userName: 'dev_journey',
        userAvatarUrl: 'https://picsum.photos/id/1014/50/50',
        videoId: 'FGelGOTBSQk',
        title: 'Building a Responsive Flutter App',
        description: 'Watch me build a beautiful responsive UI in Flutter. Link to the code: https://github.com/flutter/flutter',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        likesCount: 120,
        commentsCount: 30,
        topic: 'Flutter',
        organizationName: 'FlutterFlow',
        isVerified: true,
      ),
      YouTubePostModel(
        id: 'youtube_2',
        userId: 'y_user_b',
        userName: 'tech_talks',
        userAvatarUrl: 'https://picsum.photos/id/1018/50/50',
        videoId: 'ZiiuxXDsla8',
        title: 'The Future of AI in Web Development',
        description: 'Exploring how AI is changing the landscape of front-end development. Share your thoughts!',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        likesCount: 250,
        commentsCount: 65,
        topic: 'AI',
        organizationName: 'TechHub',
        isSaved: true,
      ),
      YouTubePostModel(
        id: 'youtube_3',
        userId: 'y_user_c',
        userName: 'creative_coder',
        userAvatarUrl: 'https://picsum.photos/id/1027/50/50',
        videoId: 'E_Gg_l0w-z8',
        title: 'My First VR Experience',
        description: 'Just got my first VR headset. The possibilities are endless!',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        likesCount: 78,
        commentsCount: 12,
        topic: 'VR',
        organizationName: 'GameDev Society',
      ),
    ];
  }

  void _showVideoFullScreen(String videoId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FullScreenYouTubePlayer(videoId: videoId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Posts', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          itemCount: _youtubePosts.length,
          itemBuilder: (context, index) {
            final post = _youtubePosts[index];
            return Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: YouTubePostWidget(
                post: post,
                onThumbnailTap: () => _showVideoFullScreen(post.videoId),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FullScreenYouTubePlayer extends StatefulWidget {
  final String videoId;

  const FullScreenYouTubePlayer({Key? key, required this.videoId}) : super(key: key);

  @override
  State<FullScreenYouTubePlayer> createState() => _FullScreenYouTubePlayerState();
}

class _FullScreenYouTubePlayerState extends State<FullScreenYouTubePlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        forceHD: true,
        hideControls: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black.withOpacity(0.9),
      child: Stack(
        children: [
          Center(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Theme.of(context).colorScheme.primary,
              progressColors: ProgressBarColors(
                playedColor: Theme.of(context).colorScheme.primary,
                handleColor: Theme.of(context).colorScheme.primary,
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


class YouTubePostWidget extends StatefulWidget {
  final YouTubePostModel post;
  final VoidCallback onThumbnailTap;

  const YouTubePostWidget({
    Key? key,
    required this.post,
    required this.onThumbnailTap,
  }) : super(key: key);

  @override
  State<YouTubePostWidget> createState() => _YouTubePostWidgetState();
}

class _YouTubePostWidgetState extends State<YouTubePostWidget> {
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
    return '${(difference.inDays / 365).floor()}y ago';
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isSaved ? 'Post saved!' : 'Post unsaved.'), duration: const Duration(seconds: 1)));
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
          style: GoogleFonts.lato(fontSize: 15.sp, color: Theme.of(context).colorScheme.primary, decoration: TextDecoration.underline),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open $url')));
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
      style: GoogleFonts.lato(fontSize: 15.sp, color: Theme.of(context).colorScheme.onSurface, height: 1.4),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const Spacer(),
                IconButton(icon: Icon(Icons.more_horiz, size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant), onPressed: () {}),
              ],
            ),
            SizedBox(height: 16.h),
            Text(widget.post.title, style: GoogleFonts.lato(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
            SizedBox(height: 8.h),
            RichText(text: _buildRichText(context, widget.post.description)),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: widget.onThumbnailTap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      'https://img.youtube.com/vi/${widget.post.videoId}/0.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200.h,
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        child: Center(child: Icon(Icons.ondemand_video, size: 50.sp, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ),
                    ),
                  ),
                  Icon(Icons.play_circle_filled, size: 70.sp, color: Colors.white.withOpacity(0.8)),
                ],
              ),
            ),
            if (widget.post.topic != null && widget.post.topic!.isNotEmpty) ...[
              SizedBox(height: 16.h),
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
            ],
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
