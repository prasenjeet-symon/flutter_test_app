import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Re-using the enum from FollowersScreen for consistency in relationship status
// This enum will now represent the relationship of the *logged-in user*
// with the person displayed in the tile.
enum FollowerStatus {
  isFollowing, // Logged-in user is following this person
  connected, // Logged-in user is mutually connected with this person (following each other)
  notFollowing, // Logged-in user is not following this person
}

// Re-using the user model from FollowersScreen
class FollowerUser {
  final String id;
  final String fullName;
  final String username;
  final String profilePictureUrl;
  final bool isVerified;
  FollowerStatus status; // Status relative to the *logged-in user*

  FollowerUser({required this.id, required this.fullName, required this.username, required this.profilePictureUrl, required this.isVerified, required this.status});

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

  Map<String, dynamic> toJson() {
    return {'id': id, 'fullName': fullName, 'username': username, 'profilePictureUrl': profilePictureUrl, 'isVerified': isVerified, 'status': status.toString().split('.').last};
  }
}

// Main screen to display connections (mutual follows) of a *profile owner*
// viewed by a *logged-in user*.
class ConnectionsScreen extends StatefulWidget {
  const ConnectionsScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  // _allConnections now holds the profile owner's connections, with status
  // indicating the logged-in user's relationship with them.
  List<FollowerUser> _allConnections = [];
  List<FollowerUser> _filteredConnections = [];

  @override
  void initState() {
    super.initState();
    _allConnections = _generateDummyData(); // Initialize with dummy data
    _filterConnections(); // Initially, filter by search query (no status filtering here)
    _searchController.addListener(_filterConnections); // Listen for search input changes
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterConnections);
    _searchController.dispose();
    super.dispose();
  }

  // Filters the connections list based only on the search query.
  // All connections of the profile owner are displayed, regardless of the logged-in user's relationship.
  void _filterConnections() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredConnections =
          _allConnections.where((user) {
            return user.fullName.toLowerCase().contains(query) || user.username.toLowerCase().contains(query);
          }).toList();
    });
  }

  // Callback function to update the status of a user in the main list
  // This updates the logged-in user's relationship with the person in the tile.
  void _onConnectionStatusChanged(FollowerUser updatedUser) {
    setState(() {
      int index = _allConnections.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        _allConnections[index] = updatedUser;
        _filterConnections(); // Re-filter the list (primarily for search, not for hiding items)
      }
    });
  }

  // Generates dummy data for demonstration purposes.
  // The 'status' reflects the *logged-in user's* current relationship with these individuals.
  List<FollowerUser> _generateDummyData() {
    return [
      FollowerUser(
        id: 'c1',
        fullName: 'John Doe',
        username: 'john_d',
        profilePictureUrl: 'https://picsum.photos/id/100/200/200',
        isVerified: true,
        status: FollowerStatus.notFollowing, // Logged-in user is NOT following John
      ),
      FollowerUser(
        id: 'c2',
        fullName: 'Jane Smith',
        username: 'jane_s',
        profilePictureUrl: 'https://picsum.photos/id/101/200/200',
        isVerified: false,
        status: FollowerStatus.isFollowing, // Logged-in user IS following Jane
      ),
      FollowerUser(
        id: 'c3',
        fullName: 'Robert Johnson',
        username: 'rob_j',
        profilePictureUrl: 'https://picsum.photos/id/102/200/200',
        isVerified: true,
        status: FollowerStatus.connected, // Logged-in user IS connected with Robert
      ),
      FollowerUser(
        id: 'c4',
        fullName: 'Emily Davis',
        username: 'emily_d',
        profilePictureUrl: 'https://picsum.photos/id/103/200/200',
        isVerified: false,
        status: FollowerStatus.notFollowing, // Logged-in user is NOT following Emily
      ),
      FollowerUser(
        id: 'c5',
        fullName: 'Michael Brown',
        username: 'mike_b',
        profilePictureUrl: 'https://picsum.photos/id/104/200/200',
        isVerified: true,
        status: FollowerStatus.isFollowing, // Logged-in user IS following Michael
      ),
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
          // AppBar title: "Connections" centered
          title: Text('Connections', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
                  hintText: 'Search connections...',
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
                  _filteredConnections.isEmpty && _searchController.text.isEmpty
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_alt_outlined, // Icon for connections
                                size: 80.sp,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              SizedBox(height: 16.h),
                              Text('No Connections Yet', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                              SizedBox(height: 8.h),
                              Text(
                                'This user has no connections yet.', // Message for profile owner's connections
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                      : _filteredConnections.isEmpty && _searchController.text.isNotEmpty
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
                        itemCount: _filteredConnections.length,
                        itemBuilder: (context, index) {
                          final user = _filteredConnections[index];
                          return ConnectionTile(user: user, onStatusChanged: _onConnectionStatusChanged);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying a single connection tile
class ConnectionTile extends StatefulWidget {
  final FollowerUser user; // Uses FollowerUser model
  final ValueChanged<FollowerUser> onStatusChanged;

  const ConnectionTile({Key? key, required this.user, required this.onStatusChanged}) : super(key: key);

  @override
  State<ConnectionTile> createState() => _ConnectionTileState();
}

class _ConnectionTileState extends State<ConnectionTile> {
  // _currentStatus now reflects the logged-in user's relationship with this person.
  late FollowerStatus _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.user.status;
  }

  // Builds the action button based on the logged-in user's relationship status
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
                _currentStatus = FollowerStatus.notFollowing; // Changing to notFollowing breaks the connection
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
    // The tile should always be visible as it's displaying a profile owner's connection.
    // The button state reflects the logged-in user's relationship with that connection.
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
