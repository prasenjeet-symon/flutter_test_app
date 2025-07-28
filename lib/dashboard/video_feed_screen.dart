import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoPostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String coverImageUrl;
  final String videoUrl;
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

  VideoPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.coverImageUrl,
    required this.videoUrl,
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

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({Key? key}) : super(key: key);

  @override
  State<VideoFeedScreen> createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  List<VideoPostModel> _videoPosts = [];

  @override
  void initState() {
    super.initState();
    _loadDummyVideoPosts();
  }

  void _loadDummyVideoPosts() {
    _videoPosts = [
      VideoPostModel(
        id: 'vid_1',
        userId: 'v_user_a',
        userName: 'nature_shorts',
        userAvatarUrl: 'https://picsum.photos/id/1018/50/50',
        coverImageUrl: 'https://picsum.photos/id/1019/800/450',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        caption: 'A moment of peace in nature\'s embrace. Pure bliss!',
        timestamp: DateTime.now().subtract(Duration(days: 1, hours: 3)),
        likesCount: 543,
        commentsCount: 32,
        topic: 'Wildlife',
        organizationName: 'EcoWatch',
        aspectRatio: 16 / 9,
        isVerified: true,
      ),
      VideoPostModel(
        id: 'vid_2',
        userId: 'v_user_b',
        userName: 'tech_byte',
        userAvatarUrl: 'https://picsum.photos/id/1005/50/50',
        coverImageUrl: 'https://picsum.photos/id/1070/800/600',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
        caption: 'Quick dive into Flutter animations. So smooth!',
        timestamp: DateTime.now().subtract(Duration(hours: 8)),
        likesCount: 210,
        commentsCount: 18,
        topic: 'Flutter Development',
        organizationName: 'Dev Academy',
        aspectRatio: 4 / 3,
      ),
      VideoPostModel(
        id: 'vid_3',
        userId: 'v_user_c',
        userName: 'travel_vlogz',
        userAvatarUrl: 'https://picsum.photos/id/1080/50/50',
        coverImageUrl: 'https://picsum.photos/id/1083/800/450',
        videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
        caption: 'Exploring ancient ruins under the midday sun. What a journey!',
        timestamp: DateTime.now().subtract(Duration(minutes: 50)),
        likesCount: 78,
        commentsCount: 9,
        topic: 'Adventure Travel',
        organizationName: 'World Explorers Guild',
        aspectRatio: 16 / 9,
        isSaved: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Posts', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
          itemCount: _videoPosts.length,
          itemBuilder: (context, index) {
            return Padding(padding: EdgeInsets.only(bottom: 24.h), child: VideoPostWidget(post: _videoPosts[index]));
          },
        ),
      ),
    );
  }
}

class VideoPostWidget extends StatefulWidget {
  final VideoPostModel post;

  const VideoPostWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<VideoPostWidget> createState() => _VideoPostWidgetState();
}

class _VideoPostWidgetState extends State<VideoPostWidget> {
  late bool _isSaved;
  VideoPlayerController? _preloadedVideoController;
  bool _isPreloading = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.post.isSaved;
  }

  void _initializePreloadedController() {
    if (_preloadedVideoController == null && !_isPreloading) {
      _isPreloading = true;
      _preloadedVideoController = VideoPlayerController.networkUrl(Uri.parse(widget.post.videoUrl));
      _preloadedVideoController!
          .initialize()
          .then((_) {
            if (mounted) {
              _preloadedVideoController!.setVolume(0.0); // Pre-load silently
              _preloadedVideoController!.setLooping(true); // Optional: if you want a subtle loop preview
              // _preloadedVideoController!.play(); // Can uncomment to start aggressive buffering
              setState(() {
                _isPreloading = false;
              });
            }
          })
          .catchError((error) {
            print('Error preloading video for ${widget.post.id}: $error');
            if (mounted) {
              setState(() {
                _isPreloading = false;
                _preloadedVideoController?.dispose();
                _preloadedVideoController = null;
              });
            }
          });
    }
  }

  void _disposePreloadedController() {
    if (_preloadedVideoController != null) {
      _preloadedVideoController!.dispose();
      _preloadedVideoController = null;
      _isPreloading = false;
    }
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

  void _showVideoFullScreen(BuildContext context) async {
    // Pause the preloaded controller before opening the full screen view
    _preloadedVideoController?.pause();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FullScreenVideoPlayer(preloadedController: _preloadedVideoController, videoUrl: widget.post.videoUrl);
      },
    );

    // After the full screen video is closed, if the post is still visible,
    // resume the preloaded controller (optional, based on desired preview behavior)
    if (mounted && _preloadedVideoController != null && _preloadedVideoController!.value.isInitialized) {
      // You might want to seek to beginning for preview here, or just keep it paused
      // _preloadedVideoController!.seekTo(Duration.zero);
      // _preloadedVideoController!.play(); // Uncomment to resume preview
    }
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isSaved ? 'Post saved!' : 'Post unsaved.'), duration: const Duration(seconds: 1)));
  }

  @override
  void dispose() {
    _disposePreloadedController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? calculatedAspectRatio = widget.post.aspectRatio;
    if (calculatedAspectRatio == null && widget.post.originalWidth != null && widget.post.originalHeight != null && widget.post.originalHeight! > 0) {
      calculatedAspectRatio = widget.post.originalWidth! / widget.post.originalHeight!;
    }
    calculatedAspectRatio ??= 16 / 9;

    return VisibilityDetector(
      key: Key(widget.post.id),
      onVisibilityChanged: (visibilityInfo) {
        final visibleFraction = visibilityInfo.visibleFraction;
        if (visibleFraction > 0.5) {
          _initializePreloadedController();
        } else if (visibleFraction == 0) {
          _disposePreloadedController();
        }
      },
      child: Card(
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
                onTap: () => _showVideoFullScreen(context),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: AspectRatio(
                    aspectRatio: calculatedAspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          widget.post.coverImageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(child: CircularProgressIndicator(value: loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)));
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: Theme.of(context).colorScheme.errorContainer, child: Icon(Icons.broken_image, size: 50.sp, color: Theme.of(context).colorScheme.onErrorContainer));
                          },
                        ),
                        Icon(Icons.play_circle_fill, size: 60.sp, color: Colors.white.withOpacity(0.8)),
                      ],
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
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController? preloadedController;
  final String videoUrl;

  const _FullScreenVideoPlayer({Key? key, this.preloadedController, required this.videoUrl}) : super(key: key);

  @override
  State<_FullScreenVideoPlayer> createState() => __FullScreenVideoPlayerState();
}

class __FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _controllerInitialized = false;
  bool _controllerOwnedByThisWidget = false;

  @override
  void initState() {
    super.initState();

    if (widget.preloadedController != null && widget.preloadedController!.value.isInitialized) {
      _controller = widget.preloadedController!;
      // Ensure it starts from the beginning and has sound
      _controller.seekTo(Duration.zero);
      _controller.setVolume(1.0);
      _controller.play().then((_) {
        if (mounted) setState(() => _isPlaying = true);
      });
      _controllerInitialized = true;
    } else {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      _controllerOwnedByThisWidget = true;
      _controller
          .initialize()
          .then((_) {
            if (mounted) {
              setState(() {
                _controllerInitialized = true;
                _controller.play();
                _isPlaying = true;
              });
            }
          })
          .catchError((error) {
            print('Error initializing video player in full screen: $error');
            if (mounted) {
              setState(() {
                _controllerInitialized = false;
              });
            }
          });
    }

    // Listener to update play/pause button state
    _controller.addListener(() {
      if (_controller.value.isPlaying != _isPlaying) {
        if (mounted) {
          setState(() {
            _isPlaying = _controller.value.isPlaying;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    // Only dispose the controller if this widget created it
    if (_controllerOwnedByThisWidget) {
      _controller.dispose();
    } else {
      // If controller was passed (preloaded), just pause it and set volume to 0
      // so it can be reused by the VideoPostWidget if it's still visible.
      _controller.pause();
      _controller.setVolume(0.0);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child:
                _controllerInitialized
                    ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _isPlaying ? _controller.pause() : _controller.play();
                        });
                      },
                      child: AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller)),
                    )
                    : CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
          ),
          if (_controllerInitialized && !_isPlaying)
            Positioned.fill(
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.play();
                    });
                  },
                  child: Icon(Icons.play_arrow, color: Colors.white.withOpacity(0.8), size: 80.sp),
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
