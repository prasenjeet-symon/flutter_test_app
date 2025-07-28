import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test_app/dashboard/followers.dart';

class SuggestedUsersScreen extends StatefulWidget {
  const SuggestedUsersScreen({Key? key}) : super(key: key);

  @override
  State<SuggestedUsersScreen> createState() => _SuggestedUsersScreenState();
}

class _SuggestedUsersScreenState extends State<SuggestedUsersScreen> {
  // Removed TextEditingController as search input is no longer present
  List<FollowerUser> _allSuggestedUsers = []; // Stores the complete list of suggested users

  @override
  void initState() {
    super.initState();
    _allSuggestedUsers = _generateDummyData(); // Initialize with dummy data
    // No filtering needed as there's no search input
  }

  @override
  void dispose() {
    // No controller to dispose
    super.dispose();
  }

  // Removed _filterSuggestedUsers method as search is no longer present

  // Callback function to update the status of a suggested user in the main list
  // This updates the logged-in user's relationship with the person in the tile.
  void _onSuggestedUserStatusChanged(FollowerUser updatedUser) {
    setState(() {
      int index = _allSuggestedUsers.indexWhere((user) => user.id == updatedUser.id);
      if (index != -1) {
        _allSuggestedUsers[index] = updatedUser;
        // No re-filtering needed for search, but state needs to rebuild to reflect button changes
      }
    });
  }

  // Generates dummy data for demonstration purposes.
  // The 'status' reflects the *logged-in user's* current relationship with these individuals.
  List<FollowerUser> _generateDummyData() {
    return [
      FollowerUser(
        id: 's1',
        fullName: 'David Lee',
        username: 'david_l',
        profilePictureUrl: 'https://picsum.photos/id/105/200/200',
        isVerified: false,
        status: FollowerStatus.notFollowing, // Logged-in user is NOT following David
      ),
      FollowerUser(
        id: 's2',
        fullName: 'Sarah Chen',
        username: 'sarah_c',
        profilePictureUrl: 'https://picsum.photos/id/106/200/200',
        isVerified: true,
        status: FollowerStatus.notFollowing, // Logged-in user is NOT following Sarah
      ),
      FollowerUser(
        id: 's3',
        fullName: 'Kevin Wong',
        username: 'kevin_w',
        profilePictureUrl: 'https://picsum.photos/id/107/200/200',
        isVerified: false,
        status: FollowerStatus.isFollowing, // Logged-in user IS following Kevin
      ),
      FollowerUser(
        id: 's4',
        fullName: 'Jessica Taylor',
        username: 'jess_t',
        profilePictureUrl: 'https://picsum.photos/id/108/200/200',
        isVerified: true,
        status: FollowerStatus.notFollowing, // Logged-in user is NOT following Jessica
      ),
      FollowerUser(
        id: 's5',
        fullName: 'Daniel Kim',
        username: 'daniel_k',
        profilePictureUrl: 'https://picsum.photos/id/109/200/200',
        isVerified: false,
        status: FollowerStatus.connected, // Logged-in user IS connected with Daniel
      ),
      FollowerUser(
        id: 's6',
        fullName: 'Olivia Martin',
        username: 'olivia_m',
        profilePictureUrl: 'https://picsum.photos/id/110/200/200',
        isVerified: true,
        status: FollowerStatus.notFollowing, // Logged-in user is NOT following Olivia
      ),
      FollowerUser(id: 's7', fullName: 'James White', username: 'james_w', profilePictureUrl: 'https://picsum.photos/id/111/200/200', isVerified: false, status: FollowerStatus.notFollowing),
      FollowerUser(id: 's8', fullName: 'Sophia Davis', username: 'sophia_d', profilePictureUrl: 'https://picsum.photos/id/112/200/200', isVerified: true, status: FollowerStatus.notFollowing),
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
          title: Text('Suggestions', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
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
            // Removed Padding and TextField for search input
            Expanded(
              child:
                  _allSuggestedUsers.isEmpty
                      ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_alt_outlined, size: 80.sp, color: Theme.of(context).colorScheme.outline),
                              SizedBox(height: 16.h),
                              Text('No Suggestions Right Now', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                              SizedBox(height: 8.h),
                              Text('Check back later for more people to connect with!', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _allSuggestedUsers.length, // Now directly uses _allSuggestedUsers
                        itemBuilder: (context, index) {
                          final user = _allSuggestedUsers[index];
                          return FollowerTile(user: user, onStatusChanged: _onSuggestedUserStatusChanged);
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
