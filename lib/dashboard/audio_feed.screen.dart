import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';

class AudioPostModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String audioUrl;
  final String title;
  final String description;
  final DateTime timestamp;
  final int likesCount;
  final int commentsCount;
  final String? topic;
  final String? organizationName;
  final bool isVerified;
  bool isSaved;

  AudioPostModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.audioUrl,
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
}

class AudioFeedScreen extends StatefulWidget {
  const AudioFeedScreen({Key? key}) : super(key: key);

  @override
  State<AudioFeedScreen> createState() => _AudioFeedScreenState();
}

class _AudioFeedScreenState extends State<AudioFeedScreen> {
  late final List<AudioPostModel> _audioPosts;
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _activeAudioIndex;
  bool _isPlaying = false;
  double _currentPosition = 0;
  double _audioDuration = 0;
  bool _isLoading = false;
  bool _isAudioCompleted = false;

  @override
  void initState() {
    super.initState();
    _loadDummyAudioPosts();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        _currentPosition = position.inMilliseconds.toDouble();
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        _audioDuration = duration.inMilliseconds.toDouble();
        _isLoading = false;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _isAudioCompleted = true;
        _currentPosition = _audioDuration;
      });
      _audioPlayer.seek(const Duration(milliseconds: 0));
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _loadDummyAudioPosts() {
    _audioPosts = [
      AudioPostModel(
        id: 'audio_1',
        userId: 'a_user_a',
        userName: 'melodic_mind',
        userAvatarUrl: 'https://picsum.photos/id/1025/50/50',
        audioUrl: 'https://upload.wikimedia.org/wikipedia/commons/c/c8/Example.ogg',
        title: 'Morning Reflections',
        description: 'A peaceful instrumental piece to start your day. Listen to more at https://www.soundhelix.com',
        timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
        likesCount: 154,
        commentsCount: 22,
        topic: 'Music',
        organizationName: 'Soundscape Studio',
        isVerified: true,
      ),
      AudioPostModel(
        id: 'audio_2',
        userId: 'a_user_b',
        userName: 'podcast_pro',
        userAvatarUrl: 'https://picsum.photos/id/403/50/50',
        audioUrl: 'https://file-examples.com/storage/fe4a4a25a6fbb7c9f3d1f3a/2017/11/file_example_MP3_700KB.mp3',
        title: 'Flutter State Management',
        description: 'An in-depth discussion on BLoC architecture for Flutter. What do you think about it? #FlutterDev',
        timestamp: DateTime.now().subtract(const Duration(hours: 18)),
        likesCount: 87,
        commentsCount: 15,
        topic: 'Technology',
        organizationName: 'DevCast',
      ),
      AudioPostModel(
        id: 'audio_3',
        userId: 'a_user_c',
        userName: 'story_teller',
        userAvatarUrl: 'https://picsum.photos/id/42/50/50',
        audioUrl: 'https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3',
        title: 'The Lost City of Oakhaven',
        description: 'A brief reading from my new fantasy novel. Hope you enjoy it! Find it here: https://www.goodreads.com/book/show/12345',
        timestamp: DateTime.now().subtract(const Duration(minutes: 50)),
        likesCount: 201,
        commentsCount: 30,
        topic: 'Audiobook',
        isSaved: true,
      ),
    ];
  }

  void _playAudio(int index) async {
    final post = _audioPosts[index];
    if (_activeAudioIndex != index) {
      await _audioPlayer.stop();
    }

    setState(() {
      _activeAudioIndex = index;
      _isLoading = true;
      _isAudioCompleted = false;
      _currentPosition = 0;
    });

    await _audioPlayer.setSourceUrl(post.audioUrl);
    await _audioPlayer.resume();
  }

  void _pauseAudio() async {
    await _audioPlayer.pause();
  }

  void _resumeAudio() async {
    await _audioPlayer.resume();
  }

  void _seekAudio(double value) async {
    await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
    if (!_isPlaying) {
      await _audioPlayer.resume();
    }
  }

  void _handlePlayPauseToggle() {
    if (_activeAudioIndex == null) return;

    if (_isPlaying) {
      _pauseAudio();
    } else {
      if (_isAudioCompleted) {
        _playAudio(_activeAudioIndex!); // Restart
      } else {
        _resumeAudio();
      }
    }
  }

  void _handleOnTap(int index) {
    if (_activeAudioIndex == index) {
      _handlePlayPauseToggle();
    } else {
      _playAudio(index);
    }
  }

  void _closeBottomPlayer() {
    _audioPlayer.stop();
    setState(() {
      _activeAudioIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Audio Posts',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, _activeAudioIndex != null ? 110.h : 8.h),
                itemCount: _audioPosts.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final post = _audioPosts[index];
                  final bool isActive = _activeAudioIndex == index;
                  return AudioPostWidget(
                    post: post,
                    isPlaying: isActive ? _isPlaying : false,
                    isLoading: isActive ? _isLoading : false,
                    isAudioCompleted: isActive ? _isAudioCompleted : false,
                    currentPosition: isActive ? _currentPosition : 0,
                    audioDuration: isActive ? _audioDuration : 0,
                    onTap: () => _handleOnTap(index),
                    onSeek: _seekAudio,
                  );
                },
              ),
            ),
            if (_activeAudioIndex != null)
              BottomAudioPlayer(
                post: _audioPosts[_activeAudioIndex!],
                isPlaying: _isPlaying,
                isLoading: _isLoading,
                isAudioCompleted: _isAudioCompleted,
                currentPosition: _currentPosition,
                audioDuration: _audioDuration,
                onTogglePlayPause: _handlePlayPauseToggle,
                onSeek: _seekAudio,
                onClose: _closeBottomPlayer,
              ),
          ],
        ),
      ),
    );
  }
}

class AudioPostWidget extends StatefulWidget {
  final AudioPostModel post;
  final bool isPlaying;
  final bool isLoading;
  final bool isAudioCompleted;
  final double currentPosition;
  final double audioDuration;
  final VoidCallback onTap;
  final ValueChanged<double> onSeek;

  const AudioPostWidget({
    Key? key,
    required this.post,
    required this.isPlaying,
    required this.isLoading,
    required this.isAudioCompleted,
    required this.currentPosition,
    required this.audioDuration,
    required this.onTap,
    required this.onSeek,
  }) : super(key: key);

  @override
  State<AudioPostWidget> createState() => _AudioPostWidgetState();
}
class _AudioPostWidgetState extends State<AudioPostWidget> {
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
    return '${(difference.inDays / 7).floor()}w ago';
  }

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Post saved!' : 'Post unsaved.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _formatDuration(double milliseconds) {
    if (milliseconds.isNaN || milliseconds.isInfinite) {
      return '00:00';
    }
    final seconds = milliseconds / 1000;
    final minutes = (seconds / 60).truncate();
    final remainingSeconds = (seconds % 60).truncate();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          width: 1.w,
        ),
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderSection(
              userName: widget.post.userName,
              avatarUrl: widget.post.userAvatarUrl,
              isVerified: widget.post.isVerified,
              timestamp: _formatTimestamp(widget.post.timestamp),
            ),
            SizedBox(height: 16.h),
            Text(
              widget.post.title,
              style: GoogleFonts.lato(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (widget.post.description.isNotEmpty) ...[
              SizedBox(height: 8.h),
              RichText(text: _buildRichText(context, widget.post.description)),
            ],
            SizedBox(height: 16.h),
            _AudioPlayerSection(
              isPlaying: widget.isPlaying,
              isLoading: widget.isLoading,
              isAudioCompleted: widget.isAudioCompleted,
              currentPosition: widget.currentPosition,
              audioDuration: widget.audioDuration,
              onTap: widget.onTap,
              onSeek: widget.onSeek,
              formatDuration: _formatDuration,
            ),
            if (widget.post.topic != null && widget.post.topic!.isNotEmpty) ...[
              SizedBox(height: 16.h),
              _TopicSection(
                topic: widget.post.topic!,
                organizationName: widget.post.organizationName,
              ),
            ],
            SizedBox(height: 16.h),
            _FooterSection(
              likesCount: widget.post.likesCount,
              commentsCount: widget.post.commentsCount,
              isSaved: _isSaved,
              onToggleSave: _toggleSave,
            ),
          ],
        ),
      ),
    );
  }
}

class BottomAudioPlayer extends StatelessWidget {
  final AudioPostModel post;
  final bool isPlaying;
  final bool isLoading;
  final bool isAudioCompleted;
  final double currentPosition;
  final double audioDuration;
  final VoidCallback onTogglePlayPause;
  final ValueChanged<double> onSeek;
  final VoidCallback onClose;

  const BottomAudioPlayer({
    Key? key,
    required this.post,
    required this.isPlaying,
    required this.isLoading,
    required this.isAudioCompleted,
    required this.currentPosition,
    required this.audioDuration,
    required this.onTogglePlayPause,
    required this.onSeek,
    required this.onClose,
  }) : super(key: key);

  String _formatDuration(double milliseconds) {
    if (milliseconds.isNaN || milliseconds.isInfinite) {
      return '00:00';
    }
    final seconds = milliseconds / 1000;
    final minutes = (seconds / 60).truncate();
    final remainingSeconds = (seconds % 60).truncate();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (audioDuration > 0) ? currentPosition / audioDuration : 0.0;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          height: 100.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.85),
            border: Border(
              top: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3), width: 1.w),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Image.network(
                      post.userAvatarUrl,
                      width: 40.sp,
                      height: 40.sp,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          post.title,
                          style: theme.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post.userName,
                          style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    width: 40.sp,
                    height: 40.sp,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: isLoading
                        ? Padding(
                      padding: EdgeInsets.all(10.w),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                        : IconButton(
                      onPressed: onTogglePlayPause,
                      icon: Icon(
                        isAudioCompleted
                            ? Icons.replay
                            : isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 24.sp,
                        color: theme.colorScheme.onPrimary,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurfaceVariant),
                    onPressed: onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              GestureDetector(
                onTapDown: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final localOffset = box.globalToLocal(details.globalPosition);
                  final newProgress = localOffset.dx / box.size.width;
                  onSeek(newProgress * audioDuration);
                },
                onHorizontalDragUpdate: (details) {
                  final box = context.findRenderObject() as RenderBox;
                  final localOffset = box.globalToLocal(details.globalPosition);
                  final newProgress = (localOffset.dx / box.size.width).clamp(0.0, 1.0);
                  onSeek(newProgress * audioDuration);
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: LinearProgressIndicator(
                    value: progress.isNaN ? 0 : progress,
                    backgroundColor: theme.colorScheme.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    minHeight: 5.h,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(currentPosition),
                    style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  Text(
                    _formatDuration(audioDuration),
                    style: theme.textTheme.bodySmall!.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioPlayerSection extends StatelessWidget {
  final bool isPlaying;
  final bool isLoading;
  final bool isAudioCompleted;
  final double currentPosition;
  final double audioDuration;
  final VoidCallback onTap;
  final ValueChanged<double> onSeek;
  final String Function(double) formatDuration;

  const _AudioPlayerSection({
    required this.isPlaying,
    required this.isLoading,
    required this.isAudioCompleted,
    required this.currentPosition,
    required this.audioDuration,
    required this.onTap,
    required this.onSeek,
    required this.formatDuration,
  });

  String _formatDuration(double milliseconds) {
    if (milliseconds.isNaN || milliseconds.isInfinite) {
      return '00:00';
    }
    final seconds = milliseconds / 1000;
    final minutes = (seconds / 60).truncate();
    final remainingSeconds = (seconds % 60).truncate();
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (audioDuration > 0) ? currentPosition / audioDuration : 0.0;

    final Color backgroundColor = theme.brightness == Brightness.dark ? const Color(0xFF2A284D) : const Color(0xFFE0E7FF);
    final Color activeColor = theme.brightness == Brightness.dark ? const Color(0xFFa78bfa) : theme.colorScheme.primary;
    final Color inactiveColor = theme.brightness == Brightness.dark ? const Color(0xFF4c3d91) : theme.colorScheme.primary.withOpacity(0.3);
    final Color iconColor = theme.brightness == Brightness.dark ? const Color(0xFF1e1b4b) : theme.colorScheme.onPrimary;
    final Color textColor = theme.brightness == Brightness.dark ? const Color(0xFFddd6fe) : theme.colorScheme.onSurface;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.sp,
            height: 48.sp,
            decoration: BoxDecoration(
              color: activeColor,
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? Padding(
              padding: EdgeInsets.all(12.w),
              child: CircularProgressIndicator(
                strokeWidth: 2.w,
                color: iconColor,
              ),
            )
                : IconButton(
              onPressed: onTap,
              icon: Icon(
                isAudioCompleted
                    ? Icons.replay
                    : isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                size: 28.sp,
                color: iconColor,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                final box = context.findRenderObject() as RenderBox;
                final position = box.globalToLocal(details.globalPosition);
                final newProgress = position.dx / box.size.width;
                onSeek((newProgress * audioDuration).clamp(0.0, audioDuration));
              },
              onTapDown: (details) {
                final box = context.findRenderObject() as RenderBox;
                final position = box.globalToLocal(details.globalPosition);
                final newProgress = position.dx / box.size.width;
                onSeek((newProgress * audioDuration).clamp(0.0, audioDuration));
              },
              child: CustomPaint(
                size: Size(double.infinity, 40.h),
                painter: WaveformPainter(
                  progress: progress,
                  activeColor: activeColor,
                  inactiveColor: inactiveColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Text(
            _formatDuration(audioDuration),
            style: GoogleFonts.lato(
              fontSize: 14.sp,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final String userName;
  final String avatarUrl;
  final bool isVerified;
  final String timestamp;

  const _HeaderSection({
    required this.userName,
    required this.avatarUrl,
    required this.isVerified,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 20.r, backgroundImage: NetworkImage(avatarUrl)),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  userName,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (isVerified)
                  Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: Icon(Icons.verified,
                        color: Theme.of(context).colorScheme.primary, size: 14.sp),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Text(
              timestamp,
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: Icon(Icons.more_horiz,
              size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _TopicSection extends StatelessWidget {
  final String topic;
  final String? organizationName;

  const _TopicSection({required this.topic, this.organizationName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            topic,
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          if (organizationName != null && organizationName!.isNotEmpty)
            Text(
              ' - $organizationName',
              style: Theme.of(context).textTheme.labelSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  final int likesCount;
  final int commentsCount;
  final bool isSaved;
  final VoidCallback onToggleSave;

  const _FooterSection({
    required this.likesCount,
    required this.commentsCount,
    required this.isSaved,
    required this.onToggleSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.favorite_border,
            size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
        SizedBox(width: 4.w),
        Text('$likesCount',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
        SizedBox(width: 16.w),
        Icon(Icons.chat_bubble_outline,
            size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
        SizedBox(width: 4.w),
        Text('$commentsCount',
            style: Theme.of(context).textTheme.labelMedium!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            )),
        const Spacer(),
        IconButton(
          icon: Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            size: 20.sp,
            color: isSaved
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onPressed: onToggleSave,
        ),
        SizedBox(width: 8.w),
        Icon(Icons.share_outlined,
            size: 20.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ],
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double progress;
  final Color activeColor;
  final Color inactiveColor;
  final List<double> _waveHeights = [0.4, 0.6, 0.8, 0.5, 0.7, 0.9, 0.6, 0.4, 0.7, 0.5, 0.8, 0.6, 0.9, 0.7, 0.5, 0.4, 0.6, 0.8, 0.5, 0.7, 0.9, 0.6, 0.4, 0.7, 0.5, 0.8, 0.6, 0.9, 0.7, 0.5, 0.4, 0.6, 0.8, 0.5, 0.7, 0.9, 0.6, 0.4, 0.7, 0.5, 0.8, 0.6, 0.9, 0.7, 0.5];

  WaveformPainter({required this.progress, required this.activeColor, required this.inactiveColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final barWidth = 3.0;
    final barSpacing = 2.0;
    final totalBarWidth = barWidth + barSpacing;
    final count = (size.width / totalBarWidth).floor();
    final activeBarCount = (count * progress).floor();

    for (int i = 0; i < count; i++) {
      paint.color = i < activeBarCount ? activeColor : inactiveColor;
      final barHeight = _waveHeights[i % _waveHeights.length] * size.height;
      final top = (size.height - barHeight) / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * totalBarWidth, top, barWidth, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

