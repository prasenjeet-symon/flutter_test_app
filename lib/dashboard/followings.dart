import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Enum to represent the following status of a user
enum FollowingStatus {
  isFollowing, // User is currently followed
  connected, // User is connected (implying a stronger connection than just following)
  notFollowing, // User is not followed
}

// Model class to represent a single user in the followings list
class FollowingUser {
  final String id;
  final String fullName;
  final String username;
  final String profilePictureUrl;
  final bool isVerified;
  FollowingStatus status; // Current status of following this user

  FollowingUser({required this.id, required this.fullName, required this.username, required this.profilePictureUrl, required this.isVerified, required this.status});

  // Factory constructor to create a FollowingUser from a JSON map
  factory FollowingUser.fromJson(Map<String, dynamic> json) {
    return FollowingUser(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      username: json['username'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String,
      isVerified: json['isVerified'] as bool,
      status: FollowingStatus.values.firstWhere((e) => e.toString() == 'FollowingStatus.${json['status']}'),
    );
  }

  // Method to convert a FollowingUser object to a JSON map
  Map<String, dynamic> toJson() {
    return {'id': id, 'fullName': fullName, 'username': username, 'profilePictureUrl': profilePictureUrl, 'isVerified': isVerified, 'status': status.toString().split('.').last};
  }
}

// Main screen widget to display the list of followings
class FollowingsScreen extends StatefulWidget {
  const FollowingsScreen({Key? key}) : super(key: key);

  @override
  State<FollowingsScreen> createState() => _FollowingsScreenState();
}

class _FollowingsScreenState extends State<FollowingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FollowingUser> _allFollowings = []; // Stores the complete list of users
  List<FollowingUser> _filteredFollowings = []; // Stores the list filtered by search query

  @override
  void initState() {
    super.initState();
    _allFollowings = _generateDummyData(); // Initialize with dummy data
    _filteredFollowings = _allFollowings; // Initially, show all users
    _searchController.addListener(_filterFollowings); // Listen for search input changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterFollowings);
    _searchController.dispose();
    super.dispose();
  }

  // Filters the followings list based on the search query
  void _filterFollowings() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFollowings =
          _allFollowings.where((user) {
            return user.fullName.toLowerCase().contains(query) || user.username.toLowerCase().contains(query);
          }).toList();
    });
  }

  // Callback function to update the status of a user in the main list
  void _onFollowingStatusChanged(FollowingUser updatedUser) {
    setState(() {
      int index = _allFollowings.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        _allFollowings[index] = updatedUser;
        _filterFollowings(); // Re-filter the list after a status change
      }
    });
  }

  // Generates dummy data for demonstration purposes
  List<FollowingUser> _generateDummyData() {
    return [
      FollowingUser(id: '1', fullName: 'Alice Johnson', username: 'alice_j', profilePictureUrl: 'https://picsum.photos/id/1005/200/200', isVerified: true, status: FollowingStatus.isFollowing),
      FollowingUser(id: '2', fullName: 'Bob Smith', username: 'bob_s', profilePictureUrl: 'https://picsum.photos/id/1011/200/200', isVerified: false, status: FollowingStatus.notFollowing),
      FollowingUser(id: '3', fullName: 'Charlie Brown', username: 'charli_b', profilePictureUrl: 'https://picsum.photos/id/1012/200/200', isVerified: true, status: FollowingStatus.connected),
      FollowingUser(id: '4', fullName: 'Diana Prince', username: 'wonder_di', profilePictureUrl: 'https://picsum.photos/id/1018/200/200', isVerified: false, status: FollowingStatus.notFollowing),
      FollowingUser(id: '5', fullName: 'Ethan Hunt', username: 'ethan_h', profilePictureUrl: 'https://picsum.photos/id/1025/200/200', isVerified: true, status: FollowingStatus.isFollowing),
      FollowingUser(id: '6', fullName: 'Fiona Gallagher', username: 'fiona_g', profilePictureUrl: 'https://picsum.photos/id/1027/200/200', isVerified: false, status: FollowingStatus.notFollowing),
      FollowingUser(id: '7', fullName: 'George Clooney', username: 'george_c', profilePictureUrl: 'https://picsum.photos/id/1035/200/200', isVerified: true, status: FollowingStatus.connected),
      FollowingUser(id: '8', fullName: 'Hannah Montana', username: 'hannah_m', profilePictureUrl: 'https://picsum.photos/id/1043/200/200', isVerified: false, status: FollowingStatus.isFollowing),
      FollowingUser(id: '9', fullName: 'Ian Somerhalder', username: 'ian_s', profilePictureUrl: 'https://picsum.photos/id/1044/200/200', isVerified: true, status: FollowingStatus.notFollowing),
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
          // Bottom border for the AppBar
          bottom: PreferredSize(preferredSize: Size.fromHeight(1.h), child: Container(color: Theme.of(context).colorScheme.outline, height: 1.h)),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 24.sp, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          // AppBar title: now only "Followings" centered
          title: Text('Followings', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          centerTitle: true, // Ensures the title is perfectly centered
        ),
      ),
      body: GestureDetector(
        // Dismiss keyboard when tapping anywhere outside an input field
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.opaque, // Ensures the GestureDetector captures all taps
        child: Column(
          // Use Column to stack the search bar and the list
          children: [
            Padding(
              // Search input field moved to the body, at the top
              padding: EdgeInsets.all(16.w), // Padding around the search bar
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search followings...',
                  // Outline border for better visual separation
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Theme.of(context).colorScheme.outline)),
                  // Border style when the field is focused
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.w)),
                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20.sp),
                  // Suffix icon to clear text when input is not empty
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 20.sp),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus(); // Dismiss keyboard after clearing
                            },
                          )
                          : null,
                  contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w), // Adjust content padding
                ),
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onSurface),
                cursorColor: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              // The rest of the body content (list or empty states) takes remaining space
              child:
                  _filteredFollowings.isEmpty && _searchController.text.isEmpty
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 80.sp, color: Theme.of(context).colorScheme.outline),
                              SizedBox(height: 16.h),
                              Text('No Followings Yet', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                              SizedBox(height: 8.h),
                              Text('Start following people to see them here!', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                      : _filteredFollowings.isEmpty && _searchController.text.isNotEmpty
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
                        itemCount: _filteredFollowings.length,
                        itemBuilder: (context, index) {
                          final user = _filteredFollowings[index];
                          return FollowingTile(user: user, onStatusChanged: _onFollowingStatusChanged);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying a single user tile in the followings list
class FollowingTile extends StatefulWidget {
  final FollowingUser user;
  final ValueChanged<FollowingUser> onStatusChanged; // Callback for status changes

  const FollowingTile({Key? key, required this.user, required this.onStatusChanged}) : super(key: key);

  @override
  State<FollowingTile> createState() => _FollowingTileState();
}

class _FollowingTileState extends State<FollowingTile> {
  late FollowingStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.user.status; // Initialize status from user object
  }

  // Builds the appropriate action button based on the current following status
  Widget _buildActionButton(BuildContext context) {
    switch (_currentStatus) {
      case FollowingStatus.isFollowing:
        return OutlinedButton(
          onPressed: () async {
            // Show confirmation bottom sheet for unfollowing
            final bool? confirm = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true, // Allows bottom sheet to take full height
              backgroundColor: Colors.transparent, // Makes background transparent to show rounded corners
              builder: (context) {
                return SafeArea(
                  // Ensures content is not cut off by system UI (e.g., navigation bar)
                  child: Container(
                    decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
                    padding: EdgeInsets.fromLTRB(
                      16.w,
                      24.h,
                      16.w,
                      // Adjust bottom padding to account for keyboard or navigation bar
                      MediaQuery.of(context).viewInsets.bottom + 16.h,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Make column only as tall as its children
                      children: [
                        Icon(
                          Icons.person_remove_outlined, // Icon for unfollow action
                          size: 64.sp,
                          color: Theme.of(context).colorScheme.error, // Error color for destructive action
                        ),
                        SizedBox(height: 16.h),
                        Text('Unfollow User?', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
                        SizedBox(height: 8.h),
                        Text(
                          'Are you sure you want to unfollow ${widget.user.fullName}?',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13.sp, // Smaller font size for description
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false), // Dismiss without confirmation
                              child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.onSurface)),
                            ),
                            SizedBox(width: 16.w),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true), // Dismiss with confirmation
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
              // If user confirmed unfollow
              setState(() {
                _currentStatus = FollowingStatus.notFollowing; // Change status to not following
                widget.user.status = _currentStatus; // Update user object
                widget.onStatusChanged(widget.user); // Notify parent screen
              });
            }
            FocusScope.of(context).unfocus(); // Dismiss keyboard after bottom sheet closes
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h), // Compact padding
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          child: const Text('Following'),
        );
      case FollowingStatus.connected:
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
                        Icon(
                          Icons.link_off_outlined, // Icon for removing connection
                          size: 64.sp,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        SizedBox(height: 16.h),
                        Text('Remove Connection?', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
                        SizedBox(height: 8.h),
                        Text(
                          'Are you sure you want to remove your connection with ${widget.user.fullName}? This will also unfollow them.',
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13.sp, // Smaller font size for description
                          ),
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
              // If user confirmed removal
              setState(() {
                _currentStatus = FollowingStatus.notFollowing; // Change status
                widget.user.status = _currentStatus;
                widget.onStatusChanged(widget.user);
              });
            }
            FocusScope.of(context).unfocus(); // Dismiss keyboard after bottom sheet closes
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h), // Compact padding
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            textStyle: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          child: const Text('Connected'),
        );
      case FollowingStatus.notFollowing:
        return FilledButton(
          onPressed: () {
            setState(() {
              _currentStatus = FollowingStatus.isFollowing; // Change status to following
              widget.user.status = _currentStatus;
              widget.onStatusChanged(widget.user);
            });
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h), // Compact padding
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
        // Example: Show a snackbar when a user tile is tapped
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
                      if (widget.user.isVerified) // Show verified icon if user is verified
                        Padding(padding: EdgeInsets.only(left: 4.w), child: Icon(Icons.verified, color: Theme.of(context).colorScheme.primary, size: 16.sp)),
                    ],
                  ),
                  Text('@${widget.user.username}', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            _buildActionButton(context), // The action button (Follow, Following, Connected)
          ],
        ),
      ),
    );
  }
}
