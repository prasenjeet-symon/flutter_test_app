import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ====== MODELS ======
class PollOption {
  final String id;
  final String title;
  int votes;
  final String? iconUrl;

  PollOption({
    required this.id,
    required this.title,
    this.votes = 0,
    this.iconUrl,
  });
}

class PollPostModel {
  final String id;
  final String userName;
  final String userAvatarUrl;
  final String question;
  final DateTime timestamp;
  int likesCount;
  final int commentsCount;
  final String? topic;
  final String? organizationName;
  final bool isVerified;
  bool isSaved;
  bool isMultiSelect;
  List<PollOption> options;
  Set<String> selectedOptionIds;
  bool isLiked;
  int totalVotes;
   int shareCount;
   int saveCount;

  PollPostModel({
    required this.id,
    required this.userName,
    required this.userAvatarUrl,
    required this.question,
    required this.timestamp,
    required this.options,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.topic,
    this.organizationName,
    this.isVerified = false,
    this.isSaved = false,
    this.isMultiSelect = false,
    this.isLiked = false,
    required this.totalVotes,
    required this.shareCount,
    required this.saveCount,
    Set<String>? selectedOptionIds,
  }) : selectedOptionIds = selectedOptionIds ?? {};

  factory PollPostModel.fromJson(Map<String, dynamic> json) {
    final pollMeta = json['poll_metadata'];
    final owner = json['owner_details'] ?? {};
    final optionsList = (pollMeta['polls'] as List<dynamic>? ?? [])
        .map((opt) => PollOption(
      id: opt['id'],
      title: opt['title'],
      votes: (opt['response_count'] ?? 0),
      iconUrl: opt['icon'],
    ))
        .toList();

    return PollPostModel(
      id: json['_id'],
      userName: owner['full_name'] ?? 'Unknown',
      userAvatarUrl: owner['profile_picture'] != null
          ? 'https://your-cdn.com/${owner['profile_picture']}'
          : 'https://via.placeholder.com/150',
      question: pollMeta['title'] ?? '',
      timestamp: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      options: optionsList,
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      topic: pollMeta['topic'],
      organizationName: pollMeta['organizationName'],
      isVerified: owner['is_verified'] ?? false,
      isMultiSelect: pollMeta['is_multi_select'] ?? false,
      isLiked: json['is_liked'] ?? false,
      totalVotes: json['total_response'] ?? 0,
      saveCount: json['saved_count'] ?? 0,
      shareCount: json['shared_count'] ?? 0,
      isSaved: json['is_saved'] ?? false,
    );
  }
}
// ====== FEED SCREEN ======
class PollFeedScreen extends StatefulWidget {
  const PollFeedScreen({Key? key}) : super(key: key);

  @override
  State<PollFeedScreen> createState() => _PollFeedScreenState();
}

class _PollFeedScreenState extends State<PollFeedScreen> {
  late List<PollPostModel> _pollPosts;

  @override
  void initState() {
    super.initState();
    _fetchPolls();
  }

  void _fetchPolls() async {
    // Simulate fetching poll posts api call
    final res = [
      {
        "_id": "689cb4d77e3ec20b9430b498",
        "org_idfr": 123,
        "owner_idfr": "686a8c8f1a2aaac842082725",
        "post_type": "poll",
        "poll_metadata": {
          "title": "Favorite Programming Language",
          "description": "Vote for the one you love most",
          "total_response": 28,
          "is_multi_select": false,
          "polls": [
            {
              "id": "7d5e55ff-dad3-4f68-9137-66e2350ad8ce",
              "title": "JavaScript",
              "response_count": 10,
              "icon": "",
              "_id": "689cb4d77e3ec20b9430b49a"
            },
            {
              "id": "8e92094f-09d4-43c5-bc05-09ca0457628d",
              "title": "Python",
              "response_count": 8,
              "icon": "",
              "_id": "689cb4d77e3ec20b9430b49b"
            },
            {
              "id": "7d3e55ff-dad3-4f68-9137-66e2350ad8ce",
              "title": "java",
              "response_count": 10,
              "icon": "",
              "_id": "689cb4d77e3ec20b0430b49a"
            },
          ],
          "_id": "689cb4d77e3ec20b9430b499"
        },
        "image_metadata": null,
        "video_metadata": null,
        "text_metadata": null,
        "is_visible_outside_org": true,
        "user_topic_idfr": "6888c29d767a75a678216d22",
        "topic_idfr": "6888c270767a75a678216d1f",
        "location": {
          "type": "Point",
          "coordinates": [
            77.5946,
            12.9716
          ],
          "address": "Bengaluru, India"
        },
        "likes_count": 1,
        "comments_count": 1,
        "saved_count": 0,
        "share_count": 0,
        "is_active": true,
        "is_deleted": false,
        "createdAt": "2025-08-13T15:52:55.055Z",
        "updatedAt": "2025-08-13T15:52:55.055Z",
        "owner_details": {
          "full_name": "Ravinder N",
          "unique_name": "ravinder2299",
          "profile_picture": "58845e98-9ef1-4cd9-a1b2-4dfd4f95407f",
          "email": null,
          "is_verified": false,
          "is_private_account": false,
          "phone": "+919640189281"
        },
        "is_liked": true,
        "is_saved": false
      },{
        "_id": "78acb4d77e3ec20b9430b500",
        "org_idfr": 456,
        "owner_idfr": "786b9d9f1a2aaac842082800",
        "post_type": "poll",
        "poll_metadata": {
          "title": "Best Frontend Framework",
          "description": "Choose the one you enjoy working with the most",
          "total_response": 35,
          "is_multi_select": true,
          "polls": [
            {
              "id": "1a2b3c4d-dad3-4f68-9137-66e2350ab123",
              "title": "React",
              "response_count": 15,
              "icon": "",
              "_id": "78acb4d77e3ec20b9430b501"
            },
            {
              "id": "2b3c4d5e-09d4-43c5-bc05-09ca04579999",
              "title": "Vue",
              "response_count": 12,
              "icon": "",
              "_id": "78acb4d77e3ec20b9430b502"
            },
            {
              "id": "3c4d5e6f-dad3-4f68-9137-66e2350acccc",
              "title": "Angular",
              "response_count": 8,
              "icon": "",
              "_id": "78acb4d77e3ec20b9430b503"
            }
          ],
          "_id": "78acb4d77e3ec20b9430b504"
        },
        "image_metadata": null,
        "video_metadata": null,
        "text_metadata": null,
        "is_visible_outside_org": false,
        "user_topic_idfr": "7888c29d767a75a678216e55",
        "topic_idfr": "7888c270767a75a678216e50",
        "location": {
          "type": "Point",
          "coordinates": [
            -74.006,
            40.7128
          ],
          "address": "New York, USA"
        },
        "likes_count": 5,
        "comments_count": 3,
        "saved_count": 2,
        "share_count": 1,
        "is_active": true,
        "is_deleted": false,
        "createdAt": "2025-08-14T05:30:00.000Z",
        "updatedAt": "2025-08-14T05:30:00.000Z",
        "owner_details": {
          "full_name": "Anita Sharma",
          "unique_name": "anita_dev",
          "profile_picture": "aa845e98-9ef1-4cd9-a1b2-4dfd4f900abc",
          "email": "anita@example.com",
          "is_verified": true,
          "is_private_account": true,
          "phone": "+919812345678"
        },
        "is_liked": false,
        "is_saved": true
      }
    ];


      setState(() {
        _pollPosts = res
            .map((item) => PollPostModel.fromJson(item))
            .toList();
      });


  }

  void _handleVote(PollPostModel post, String optionId) {
    if (!post.isMultiSelect) {
      // SINGLE SELECT – vote once and lock
      if (post.selectedOptionIds.isEmpty) {
        post.selectedOptionIds.add(optionId);
        final opt = post.options.firstWhere((o) => o.id == optionId);
        opt.votes++;
      }
    } else {
      // MULTI SELECT – add selection, but no deselecting
      if (!post.selectedOptionIds.contains(optionId)) {
        post.selectedOptionIds.add(optionId);
        final opt = post.options.firstWhere((o) => o.id == optionId);
        opt.votes++;
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Polls',
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
          itemCount: _pollPosts.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: PollPostWidget(
                post: _pollPosts[index],
                onVote: (optionId) {
                  setState(() => _handleVote(_pollPosts[index], optionId));
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

// ====== POLL CARD ======
class PollPostWidget extends StatefulWidget {
  final PollPostModel post;
  final Function(String) onVote;

  const PollPostWidget({Key? key, required this.post, required this.onVote})
      : super(key: key);

  @override
  State<PollPostWidget> createState() => _PollPostWidgetState();
}

class _PollPostWidgetState extends State<PollPostWidget> {
  late bool _isSaved;
  bool _isTranslated = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.post.isSaved;
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }

  int _totalVotes() =>
      widget.post.options.fold(0, (sum, o) => sum + o.votes);

  void _toggleSave() {
    setState(() => _isSaved = !_isSaved);
  }

  void _toggleTranslation() {
    setState(() => _isTranslated = !_isTranslated);
  }

  @override
  Widget build(BuildContext context) {
    final totalVotes = _totalVotes();

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                    radius: 20.r,
                    backgroundImage:
                    NetworkImage(widget.post.userAvatarUrl)),
                SizedBox(width: 12.w),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(widget.post.userName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(fontWeight: FontWeight.bold)),
                    if (widget.post.isVerified)
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Icon(Icons.verified,
                            size: 14.sp,
                            color: Theme.of(context).colorScheme.primary),
                      )
                  ]),
                  Text(_formatTimestamp(widget.post.timestamp),
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant)),
                ]),
                Spacer(),
                IconButton(
                    icon: Icon(Icons.more_horiz, size: 20.sp),
                    onPressed: () {}),
              ],
            ),
            SizedBox(height: 16.h),

            // Question
            Text(
              _isTranslated
                  ? 'Translated: ${widget.post.question}'
                  : widget.post.question,
              style: GoogleFonts.lato(
                  fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 16.h),

            ...widget.post.options.map((option) {
              final isMultiSelect = widget.post.isMultiSelect;
              final hasVoted = widget.post.selectedOptionIds.isNotEmpty;
              final isSelected = widget.post.selectedOptionIds.contains(option.id);

              final totalVotes = widget.post.totalVotes > 0
                  ? widget.post.totalVotes
                  : widget.post.options.fold(0, (sum, o) => sum + o.votes);

              final percent = totalVotes > 0 ? (option.votes / totalVotes) : 0.0;

              return GestureDetector(
                  onTap: () {
                    final isMultiSelect = widget.post.isMultiSelect;
                    final hasVoted = widget.post.selectedOptionIds.isNotEmpty;

                    // single select: lock after first tap
                    if (!isMultiSelect && !hasVoted) {
                      widget.onVote(option.id);
                      setState(() {
                        widget.post.totalVotes =
                            widget.post.options.fold(0, (sum, o) => sum + o.votes);
                      });
                    }

                    // multi select: allow adding new selections, but don't allow deselecting
                    if (isMultiSelect && (!hasVoted || !widget.post.selectedOptionIds.contains(option.id))) {
                      widget.onVote(option.id);
                      setState(() {
                        widget.post.totalVotes =
                            widget.post.options.fold(0, (sum, o) => sum + o.votes);
                      });
                    }
                  },
                  child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: !hasVoted?EdgeInsets.symmetric(horizontal: 4.w, vertical: 10.h):null,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,    // Ensures bar doesn't overflow corners
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      if (hasVoted)
                        FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: percent,
                          child: Container(
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.20),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (option.iconUrl != null &&
                                  option.iconUrl!.isNotEmpty) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4.r),
                                  child: Image.network(option.iconUrl!,
                                      height: 20.h, width: 20.h, fit: BoxFit.cover),
                                ),

                              ],
                              SizedBox(width: 8.w),
                              Text(option.title,
                                  style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          if (hasVoted)...[
                            Text(
                              "${(percent * 100).toStringAsFixed(0)}%  ",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),

            if (widget.post.topic != null) SizedBox(height: 12.h),
            if (widget.post.topic != null)
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4.r)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(widget.post.topic!,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall!
                          .copyWith(fontWeight: FontWeight.bold)),
                  if (widget.post.organizationName != null)
                    Text(' - ${widget.post.organizationName!}',
                        style: Theme.of(context).textTheme.labelSmall),
                ]),
              ),
            SizedBox(height: 16.h),

            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (widget.post.isLiked) {
                        widget.post.likesCount -= 1;
                      } else {
                        widget.post.likesCount += 1;
                      }
                      widget.post.isLiked = !widget.post.isLiked;
                    });
                  },
                  child: Icon(
                    widget.post.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 20.sp,
                    color: widget.post.isLiked
                        ? Theme.of(context).colorScheme.error
                        : null,
                  ),
                ),
                SizedBox(width: 4.w),
                Text('${widget.post.likesCount}'),

                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () {
                    //naviaget to comments
                  },
                  child: Icon(Icons.chat_bubble_outline, size: 20.sp),
                ),
                SizedBox(width: 4.w),
                Text('${widget.post.commentsCount}'),

                SizedBox(width: 16.w),

                Spacer(),
                GestureDetector(
                  onTap: _toggleSave,
                  child: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 24.sp,
                    color: _isSaved
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () {

                  },
                  child: Icon(Icons.share_outlined, size: 20.sp),
                ),
              ],
            )

          ],
        ),
      ),
    );
  }
}
