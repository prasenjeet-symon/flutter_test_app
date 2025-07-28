import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Enum to represent the following status of a user relative to the current user
enum FollowerStatus {
  isFollowing, // Current user is following this follower
  connected, // Current user is connected with this follower (e.g., mutual follow)
  notFollowing, // Current user is not following this follower
}

// Model class to represent a single follower user
class FollowerUser {
  final String id;
  final String fullName;
  final String username;
  final String profilePictureUrl;
  final bool isVerified;
  FollowerStatus status; // Current status of the relationship

  FollowerUser({required this.id, required this.fullName, required this.username, required this.profilePictureUrl, required this.isVerified, required this.status});

  // Factory constructor to create a FollowerUser from a JSON map (for future use)
  factory FollowerUser.fromJson(Map<String, dynamic> json) {
    return FollowerUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String,
      isVerified: json['isVerified'] as bool,
      status: FollowerStatus.values.firstWhere((e) => e.toString() == 'FollowerStatus.${json['status']}'),
    );
  }

  // Method to convert a FollowerUser object to a JSON map (for future use)
  Map<String, dynamic> toJson() {
    return {'id': id, 'fullName': fullName, 'username': username, 'profilePictureUrl': profilePictureUrl, 'isVerified': isVerified, 'status': status.toString().split('.').last};
  }
}

// Main screen widget to display the list of followers
class FollowersScreen extends StatefulWidget {
  const FollowersScreen({Key? key}) : super(key: key);

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FollowerUser> _allFollowers = []; // Stores the complete list of followers
  List<FollowerUser> _filteredFollowers = []; // Stores the list filtered by search query

  @override
  void initState() {
    super.initState();
    _allFollowers = _generateDummyData(); // Initialize with dummy data
    _filteredFollowers = _allFollowers; // Initially, show all followers
    _searchController.addListener(_filterFollowers); // Listen for search input changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFollowers);
    _searchController.dispose();
    super.dispose();
  }

  // Filters the followers list based on the search query
  void _filterFollowers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFollowers =
          _allFollowers.where((user) {
            return user.fullName.toLowerCase().contains(query) || user.username.toLowerCase().contains(query);
          }).toList();
    });
  }

  // Callback function to update the status of a follower in the main list
  void _onFollowerStatusChanged(FollowerUser updatedUser) {
    setState(() {
      int index = _allFollowers.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        _allFollowers[index] = updatedUser;
        _filterFollowers(); // Re-filter the list after a status change
      }
    });
  }

  // Generates dummy data for demonstration purposes
  List<FollowerUser> _generateDummyData() {
    return [
      FollowerUser(
        id: 'f1',
        fullName: 'Zoe White',
        username: 'zoe_w',
        profilePictureUrl: 'https://picsum.photos/id/1062/200/200',
        isVerified: true,
        status: FollowerStatus.connected, // This follower is also followed by current user
      ),
      FollowerUser(
        id: 'f2',
        fullName: 'Liam Miller',
        username: 'liam_m',
        profilePictureUrl: 'https://picsum.photos/id/1063/200/200',
        isVerified: false,
        status: FollowerStatus.notFollowing, // Current user is not following this follower
      ),
      FollowerUser(
        id: 'f3',
        fullName: 'Ava Davis',
        username: 'ava_d',
        profilePictureUrl: 'https://picsum.photos/id/1064/200/200',
        isVerified: true,
        status: FollowerStatus.isFollowing, // Current user is following this follower
      ),
      FollowerUser(id: 'f4', fullName: 'Noah Garcia', username: 'noah_g', profilePictureUrl: 'https://picsum.photos/id/1065/200/200', isVerified: false, status: FollowerStatus.notFollowing),
      FollowerUser(id: 'f5', fullName: 'Isabella Rodriguez', username: 'isabella_r', profilePictureUrl: 'https://picsum.photos/id/1066/200/200', isVerified: true, status: FollowerStatus.isFollowing),
      FollowerUser(id: 'f6', fullName: 'William Martinez', username: 'will_m', profilePictureUrl: 'https://picsum.photos/id/1067/200/200', isVerified: false, status: FollowerStatus.notFollowing),
      FollowerUser(id: 'f7', fullName: 'Sophia Hernandez', username: 'sophia_h', profilePictureUrl: 'https://picsum.photos/id/1068/200/200', isVerified: true, status: FollowerStatus.connected),
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
          // AppBar title: "Followers" centered
          title: Text('Followers', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          centerTitle: true,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search followers...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.w)),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20.sp),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20.sp),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          )
                          : null,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                ),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                cursorColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child:
                  _filteredFollowers.isEmpty && _searchController.text.isEmpty
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 80.sp, color: Theme.of(context).colorScheme.outline),
                              SizedBox(height: 16.h),
                              Text('No Followers Yet', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                              SizedBox(height: 8.h),
                              Text('Share your profile to gain followers!', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                      : _filteredFollowers.isEmpty && _searchController.text.isNotEmpty
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_off_outlined, size: 80.sp, color: Theme.of(context).colorScheme.outline),
                              SizedBox(height: 16.h),
                              Text('No Matching Results', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                              SizedBox(height: 8.h),
                              Text('Try a different name or username.', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredFollowers.length,
                        itemBuilder: (context, index) {
                          final user = _filteredFollowers[index];
                          return FollowerTile(user: user, onStatusChanged: _onFollowerStatusChanged);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying a single follower tile
class FollowerTile extends StatefulWidget {
  final FollowerUser user;
  final ValueChanged<FollowerUser> onStatusChanged;

  const FollowerTile({Key? key, required this.user, required this.onStatusChanged}) : super(key: key);

  @override
  State<FollowerTile> createState() => _FollowerTileState();
}

class _FollowerTileState extends State<FollowerTile> {
  late FollowerStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.user.status;
  }

  // Builds the appropriate action button based on the current follower status
  Widget _buildActionButton(BuildContext context) {
    switch (_currentStatus) {
      case FollowerStatus.isFollowing:
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
                        Text('Are you sure you want to unfollow ${widget.user.fullName}?', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13.sp), textAlign: TextAlign.center),
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
                _currentStatus = FollowerStatus.notFollowing;
                widget.user.status = _currentStatus;
                widget.onStatusChanged(widget.user);
              });
            }
            FocusScope.of(context).unfocus();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          child: const Text('Following'),
        );
      case FollowerStatus.connected:
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
                          'Are you sure you want to remove your connection with ${widget.user.fullName}? This will also unfollow them.',
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
                _currentStatus = FollowerStatus.notFollowing;
                widget.user.status = _currentStatus;
                widget.onStatusChanged(widget.user);
              });
            }
            FocusScope.of(context).unfocus();
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          child: const Text('Connected'),
        );
      case FollowerStatus.notFollowing:
        return FilledButton(
          onPressed: () {
            setState(() {
              _currentStatus = FollowerStatus.isFollowing;
              widget.user.status = _currentStatus;
              widget.onStatusChanged(widget.user);
            });
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          child: const Text('Follow'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Tapped on ${widget.user.fullName}\'s profile')));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
        child: Row(
          children: [
            CircleAvatar(radius: 28.r, backgroundImage: NetworkImage(widget.user.profilePictureUrl), backgroundColor: Theme.of(context).colorScheme.surfaceVariant),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(widget.user.fullName, style: Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
                      if (widget.user.isVerified) Padding(padding: EdgeInsets.only(left: 4.w), child: Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 16.sp)),
                    ],
                  ),
                  Text('@${widget.user.username}', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }
}
