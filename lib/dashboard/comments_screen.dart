// lib/screens/comments_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  String text;
  final DateTime timestamp;
  final bool isVerified;

  CommentModel({required this.id, required this.postId, required this.userId, required this.userName, required this.userAvatarUrl, required this.text, required this.timestamp, this.isVerified = false});

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      postId: json['postId'],
      userId: json['userId'],
      userName: json['userName'],
      userAvatarUrl: json['userAvatarUrl'],
      text: json['text'],
      timestamp: DateTime.parse(json['timestamp']),
      isVerified: json['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'postId': postId, 'userId': userId, 'userName': userName, 'userAvatarUrl': userAvatarUrl, 'text': text, 'timestamp': timestamp.toIso8601String(), 'isVerified': isVerified};
  }
}

const String kLoggedInUserId = 'current_user_id';
const String kLoggedInUserName = 'You';
const String kLoggedInUserAvatar = 'https://picsum.photos/id/1005/50/50';

class CommentsScreen extends StatefulWidget {
  final String postId;

  const CommentsScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<CommentModel> _comments = [];
  bool _isSendingComment = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _commentController.addListener(_updateSendButtonState);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _commentController.removeListener(_updateSendButtonState);
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateSendButtonState() {
    setState(() {});
  }

  void _loadComments() {
    setState(() {
      _comments = [
        CommentModel(
          id: 'c1',
          postId: widget.postId,
          userId: 'user1',
          userName: 'John_Doe',
          userAvatarUrl: 'https://picsum.photos/id/237/50/50',
          text: 'This is a truly insightful post! I really enjoyed reading it and learned a lot.',
          timestamp: DateTime.now().subtract(Duration(minutes: 90)),
          isVerified: true,
        ),
        CommentModel(
          id: 'c2',
          postId: widget.postId,
          userId: 'user2',
          userName: 'JaneSmith_Official',
          userAvatarUrl: 'https://picsum.photos/id/1025/50/50',
          text: 'Agreed! Very well written. Thanks for sharing your thoughts.',
          timestamp: DateTime.now().subtract(Duration(minutes: 65)),
        ),
        CommentModel(
          id: 'c3',
          postId: widget.postId,
          userId: kLoggedInUserId,
          userName: kLoggedInUserName,
          userAvatarUrl: kLoggedInUserAvatar,
          text: 'My thoughts exactly! This resonated with me so much. Great job! 👍',
          timestamp: DateTime.now().subtract(Duration(minutes: 40)),
        ),
        CommentModel(
          id: 'c4',
          postId: widget.postId,
          userId: 'user3',
          userName: 'Peter_J',
          userAvatarUrl: 'https://picsum.photos/id/106/50/50',
          text: 'Could you elaborate more on point #3 in your next post? Very curious!',
          timestamp: DateTime.now().subtract(Duration(minutes: 25)),
        ),
        CommentModel(id: 'c5', postId: widget.postId, userId: 'user4', userName: 'Sarah_Lee_Art', userAvatarUrl: 'https://picsum.photos/id/1084/50/50', text: 'Amazing content!', timestamp: DateTime.now().subtract(Duration(minutes: 10))),
        CommentModel(
          id: 'c6',
          postId: widget.postId,
          userId: kLoggedInUserId,
          userName: kLoggedInUserName,
          userAvatarUrl: kLoggedInUserAvatar,
          text: 'Just wanted to add, this is a very helpful resource for anyone starting out.',
          timestamp: DateTime.now().subtract(Duration(minutes: 5)),
        ),
      ];
    });
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() {
      _isSendingComment = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.postId,
      userId: kLoggedInUserId,
      userName: kLoggedInUserName,
      userAvatarUrl: kLoggedInUserAvatar,
      text: text,
      timestamp: DateTime.now(),
      isVerified: false,
    );

    setState(() {
      _comments.add(newComment);
      _commentController.clear();
      _isSendingComment = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  void _deleteComment(String commentId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          title: Text('Delete Comment', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface)),
          content: Text('Are you sure you want to delete this comment?', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          actions: <Widget>[
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface))),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Theme.of(context).colorScheme.onError),
              child: Text('Delete', style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.onError)),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _comments.removeWhere((comment) => comment.id == commentId);
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Comment deleted.'), duration: const Duration(seconds: 1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments (${_comments.length})', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back, size: 24.sp, color: Theme.of(context).colorScheme.onSurface), onPressed: () => Navigator.pop(context)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom: PreferredSize(preferredSize: Size.fromHeight(1.h), child: Container(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), height: 1.h)),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Column(
            children: [
              Expanded(
                child:
                    _comments.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.comment_outlined, size: 60.sp, color: Theme.of(context).colorScheme.outline),
                              SizedBox(height: 16.h),
                              Text('No comments yet.', style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                              SizedBox(height: 8.h),
                              Text('Be the first to comment!', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        )
                        : ListView.builder(
                          controller: _scrollController,
                          itemCount: _comments.length,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          itemBuilder: (context, index) {
                            final comment = _comments[index];
                            return CommentTile(comment: comment, loggedInUserId: kLoggedInUserId, onDelete: _deleteComment);
                          },
                        ),
              ),
              _buildCommentInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5), width: 1.h))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(radius: 18.r, backgroundImage: NetworkImage(kLoggedInUserAvatar), backgroundColor: Theme.of(context).colorScheme.primaryContainer),
          SizedBox(width: 12.w),
          Expanded(
            child: TextField(
              controller: _commentController,
              maxLines: 5,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                hintStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                border: InputBorder.none,
                focusedBorder: InputBorder.none, // Removes the outline when focused
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              ),
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface),
              cursorColor: Theme.of(context).colorScheme.primary,
            ),
          ),
          AnimatedOpacity(
            opacity: (_commentController.text.trim().isEmpty || _isSendingComment) ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: TextButton(
              onPressed: (_commentController.text.trim().isEmpty || _isSendingComment) ? null : _addComment,
              child: Text('Post', style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class CommentTile extends StatelessWidget {
  final CommentModel comment;
  final String loggedInUserId;
  final Function(String) onDelete;

  const CommentTile({Key? key, required this.comment, required this.loggedInUserId, required this.onDelete}) : super(key: key);

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isMyComment = comment.userId == loggedInUserId;

    return GestureDetector(
      onLongPress: isMyComment ? () => onDelete(comment.id) : null,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: NetworkImage(comment.userAvatarUrl),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading comment avatar: $exception');
              },
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(comment.userName, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
                      if (comment.isVerified) Padding(padding: EdgeInsets.only(left: 4.w), child: Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 14.sp)),
                      SizedBox(width: 8.w),
                      Text(_formatTimestamp(comment.timestamp), style: Theme.of(context).textTheme.labelSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(comment.text, style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
