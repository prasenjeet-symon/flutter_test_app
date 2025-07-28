// lib/screens/post_likers_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math'; // For random status generation

// --- FollowStatus Enum (already exists) ---
enum FollowStatus {
  notFollowing, // User can be followed
  following, // User is currently being followed
  connected, // User is "connected" (e.g., friend, LinkedIn connection, mutual follow)
}

// --- UserModel Definition (already exists, with FollowStatus) ---
class UserModel {
  final String id;
  final String name;
  final String avatarUrl;
  final String? username;
  final String? bio;
  FollowStatus followStatus; // Added follow status

  UserModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.username,
    this.bio,
    this.followStatus = FollowStatus.notFollowing, // Default status
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      username: json['username'] as String?,
      bio: json['bio'] as String?,
      followStatus: _parseFollowStatus(json['followStatus']), // Parse status
    );
  }

  static FollowStatus _parseFollowStatus(String? statusString) {
    switch (statusString) {
      case 'following':
        return FollowStatus.following;
      case 'connected':
        return FollowStatus.connected;
      case 'notFollowing':
      default:
        return FollowStatus.notFollowing;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'username': username,
      'bio': bio,
      'followStatus': followStatus.name, // Convert enum to string
    };
  }
}
// --- End UserModel Definition ---

class PostLikersScreen extends StatefulWidget {
  final String postId; // The ID of the post whose likers we are displaying

  const PostLikersScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<PostLikersScreen> createState() => _PostLikersScreenState();
}

class _PostLikersScreenState extends State<PostLikersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _allLikers = [];
  List<UserModel> _filteredLikers = [];
  final Random _random = Random(); // For random initial follow status

  @override
  void initState() {
    super.initState();
    _loadLikers(); // Load dummy data
    _searchController.addListener(_filterLikers); // Listen for search input changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLikers);
    _searchController.dispose();
    super.dispose();
  }

  // --- Dummy Data Loading (Replace with actual API call) ---
  void _loadLikers() {
    setState(() {
      _allLikers = _generateDummyLikers();
      _filteredLikers = List.from(_allLikers); // Initially show all likers
    });
  }

  List<UserModel> _generateDummyLikers() {
    final List<UserModel> likers = [
      UserModel(id: 'u1', name: 'Alice Smith', avatarUrl: 'https://picsum.photos/id/1/50/50', username: 'alice_s'),
      UserModel(id: 'u2', name: 'Bob Johnson', avatarUrl: 'https://picsum.photos/id/2/50/50', username: 'bobj'),
      UserModel(id: 'u3', name: 'Charlie Brown', avatarUrl: 'https://picsum.photos/id/3/50/50', username: 'charlieb'),
      UserModel(id: 'u4', name: 'Diana Prince', avatarUrl: 'https://picsum.photos/id/4/50/50', username: 'wonder_d'),
      UserModel(id: 'u5', name: 'Eve Adams', avatarUrl: 'https://picsum.photos/id/5/50/50', username: 'evea'),
      UserModel(id: 'u6', name: 'Frank White', avatarUrl: 'https://picsum.photos/id/6/50/50', username: 'fwhite'),
      UserModel(id: 'u7', name: 'Grace Kelly', avatarUrl: 'https://picsum.photos/id/7/50/50', username: 'gkelly'),
      UserModel(id: 'u8', name: 'Henry Ford', avatarUrl: 'https://picsum.photos/id/8/50/50', username: 'hford'),
      UserModel(id: 'u9', name: 'Ivy Green', avatarUrl: 'https://picsum.photos/id/9/50/50', username: 'ivyg'),
      UserModel(id: 'u10', name: 'Jack Black', avatarUrl: 'https://picsum.photos/id/10/50/50', username: 'jackb'),
      UserModel(id: 'u11', name: 'Karen Red', avatarUrl: 'https://picsum.photos/id/11/50/50', username: 'karen_r'),
      UserModel(id: 'u12', name: 'Liam Blue', avatarUrl: 'https://picsum.photos/id/12/50/50', username: 'liamblue'),
      UserModel(id: 'u13', name: 'Mia Yellow', avatarUrl: 'https://picsum.photos/id/13/50/50', username: 'mia_y'),
      UserModel(id: 'u14', name: 'Noah Purple', avatarUrl: 'https://picsum.photos/id/14/50/50', username: 'noah_p'),
      UserModel(id: 'u15', name: 'Olivia Orange', avatarUrl: 'https://picsum.photos/id/15/50/50', username: 'olivia_o'),
    ];

    // Assign random follow statuses for demonstration
    return likers.map((user) {
      final statusIndex = _random.nextInt(FollowStatus.values.length);
      user.followStatus = FollowStatus.values[statusIndex];
      return user;
    }).toList();
  }
  // --- End Dummy Data Loading ---

  // --- Search Filtering Logic ---
  void _filterLikers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLikers = List.from(_allLikers);
      } else {
        _filteredLikers =
            _allLikers.where((user) {
              return user.name.toLowerCase().contains(query) || (user.username?.toLowerCase().contains(query) ?? false);
            }).toList();
      }
    });
  }
  // --- End Search Filtering Logic ---

  // --- Callback from LikerTile to update parent list ---
  void _onLikerStatusChanged(UserModel updatedUser) {
    setState(() {
      // Find the user in the original list and update their status
      final userIndex = _allLikers.indexWhere((u) => u.id == updatedUser.id);
      if (userIndex != -1) {
        _allLikers[userIndex] = updatedUser;
        _filterLikers(); // Re-filter the list after a status change
      }
    });
    // Optional: Show a snackbar or toast based on status change
    String message = '';
    switch (updatedUser.followStatus) {
      case FollowStatus.notFollowing:
        message = 'You unfollowed ${updatedUser.name}';
        break;
      case FollowStatus.following:
        message = 'You are now following ${updatedUser.name}';
        break;
      case FollowStatus.connected:
        message = 'Connected with ${updatedUser.name}'; // Or "You disconnected from..."
        break;
    }
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
  // --- End Callback from LikerTile ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Likes', // AppBar title
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search likers by name or username...',
                  prefixIcon: Icon(Icons.search, size: 22.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none, // Use BorderSide.none for a filled look
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Expanded(
              child:
                  _filteredLikers.isEmpty && _searchController.text.isNotEmpty
                      ? Center(child: Text('No users found matching your search.', style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                      : _filteredLikers.isEmpty
                      ? Center(child: Text('No one has liked this post yet.', style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)))
                      : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: _filteredLikers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredLikers[index];
                          return LikerTile(user: user, onStatusChanged: _onLikerStatusChanged);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- New LikerTile Widget ---
class LikerTile extends StatefulWidget {
  final UserModel user;
  final ValueChanged<UserModel> onStatusChanged; // Callback to inform parent of status change

  const LikerTile({Key? key, required this.user, required this.onStatusChanged}) : super(key: key);

  @override
  State<LikerTile> createState() => _LikerTileState();
}

class _LikerTileState extends State<LikerTile> {
  late FollowStatus _currentStatus; // Internal state for the button

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.user.followStatus; // Initialize with user's current status
  }

  // Helper method to build the action button based on current status
  Widget _buildActionButton(BuildContext context) {
    // Assume 'u_viewer_id' is the ID of the logged-in user.
    // Hide button for the logged-in user themselves
    const String loggedInUserId = 'u_viewer_id';
    if (widget.user.id == loggedInUserId) {
      return const SizedBox.shrink();
    }

    switch (_currentStatus) {
      case FollowStatus.following:
        return OutlinedButton(
          onPressed: () async {
            // Show confirmation bottom sheet for unfollowing
            final bool? confirm = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return SafeArea(
                  child: Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
                    padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, MediaQuery.of(context).viewInsets.bottom + 16.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_remove_outlined, size: 64.sp, color: Theme.of(context).colorScheme.error),
                        SizedBox(height: 16.h),
                        Text('Unfollow User?', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
                        SizedBox(height: 8.h),
                        Text('Are you sure you want to unfollow ${widget.user.name}?', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13.sp), textAlign: TextAlign.center),
                        SizedBox(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface))),
                            SizedBox(width: 16.w),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.error,
                                foregroundColor: Theme.of(context).colorScheme.onError,
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              ),
                              child: Text('Unfollow', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            if (confirm == true) {
              setState(() {
                _currentStatus = FollowStatus.notFollowing;
                widget.user.followStatus = _currentStatus; // Update the underlying model
                widget.onStatusChanged(widget.user); // Notify parent
              });
            }
            FocusScope.of(context).unfocus(); // Dismiss keyboard if open
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary, // Text: primary
            side: BorderSide(color: Theme.of(context).colorScheme.primary), // Border: primary
            minimumSize: Size(80.w, 32.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13.sp),
          ),
          child: const Text('Following'),
        );
      case FollowStatus.connected:
        return FilledButton(
          onPressed: () async {
            // Show confirmation bottom sheet for removing connection
            final bool? confirm = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) {
                return SafeArea(
                  child: Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
                    padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, MediaQuery.of(context).viewInsets.bottom + 16.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.link_off_outlined, size: 64.sp, color: Theme.of(context).colorScheme.error),
                        SizedBox(height: 16.h),
                        Text('Remove Connection?', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
                        SizedBox(height: 8.h),
                        Text(
                          'Are you sure you want to remove your connection with ${widget.user.name}? This will also unfollow them.',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13.sp),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface))),
                            SizedBox(width: 16.w),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.error,
                                foregroundColor: Theme.of(context).colorScheme.onError,
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              ),
                              child: Text('Remove Connection', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            if (confirm == true) {
              setState(() {
                _currentStatus = FollowStatus.notFollowing; // Assuming removing connection leads to notFollowing
                widget.user.followStatus = _currentStatus;
                widget.onStatusChanged(widget.user);
              });
            }
            FocusScope.of(context).unfocus();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant, // Lighter background for 'Connected'
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant, // Text on surface variant
            minimumSize: Size(80.w, 32.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13.sp),
          ),
          child: const Text('Connected'),
        );
      case FollowStatus.notFollowing:
        return FilledButton(
          onPressed: () {
            setState(() {
              _currentStatus = FollowStatus.following;
              widget.user.followStatus = _currentStatus; // Update the underlying model
              widget.onStatusChanged(widget.user); // Notify parent
            });
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary, // Primary background
            foregroundColor: Theme.of(context).colorScheme.onPrimary, // On primary text
            minimumSize: Size(80.w, 32.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13.sp),
          ),
          child: const Text('Follow'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Implement navigation to user's profile screen
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped on ${widget.user.name}\'s profile (ID: ${widget.user.id})'), duration: const Duration(milliseconds: 800)));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundImage: NetworkImage(widget.user.avatarUrl),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              onBackgroundImageError: (exception, stackTrace) {
                print('Error loading image for ${widget.user.name}: $exception');
              },
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.user.name, style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  if (widget.user.username != null) Text('@${widget.user.username}', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 8.w), // Space between text and button
            _buildActionButton(context), // The dynamic button
          ],
        ),
      ),
    );
  }
}
