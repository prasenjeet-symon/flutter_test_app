import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator

// --- Global Constants ---
const List<String> availablePostTypeNames = ['Text Post', 'Image Post', 'Video Post', 'Event', 'Poll', 'Link', 'File', 'Announcement', 'YouTube', 'Audio', 'Donation', 'Article', 'Jobs'];

// --- Data Models ---
class Organization {
  final String id;
  final String name;
  final String shortName;
  final String type;
  final String logoUrl;
  final bool isVerified;

  Organization({required this.id, required this.name, required this.shortName, required this.type, this.logoUrl = 'https://picsum.photos/id/1/40', this.isVerified = false});
}

class Topic {
  final String id;
  final String name;
  final String orgId;

  Topic({required this.id, required this.name, required this.orgId});
}

// --- Dependencies needed by TopicPostsScreen ---

// Radiating Radar Icon for animation
class RadiatingRadarIcon extends StatefulWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final double iconSize;
  final Color activeColor;
  final Color inactiveColor;

  const RadiatingRadarIcon({Key? key, required this.isActive, required this.onPressed, this.iconSize = 28.0, this.activeColor = Colors.green, this.inactiveColor = Colors.grey}) : super(key: key);

  @override
  _RadiatingRadarIconState createState() => _RadiatingRadarIconState();
}

class _RadiatingRadarIconState extends State<RadiatingRadarIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration for one full pulse cycle
    );

    if (widget.isActive) {
      _controller.repeat(); // Repeat animation if active
    }
  }

  @override
  void didUpdateWidget(covariant RadiatingRadarIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.value = 0.0; // Reset animation when inactive
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      borderRadius: BorderRadius.circular(widget.iconSize * 0.7),
      child: Container(
        width: widget.iconSize * 1.5,
        height: widget.iconSize * 1.5,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isActive)
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final normalizedValue = (_controller.value + delay) % 1.0;
                    final opacity = (1.0 - normalizedValue).clamp(0.0, 1.0);
                    final scale = 1.0 + (normalizedValue * 1.5);

                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(scale: scale, child: Container(width: widget.iconSize, height: widget.iconSize, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.activeColor.withOpacity(0.4)))),
                    );
                  },
                );
              }),
            Icon(Icons.radar, size: widget.iconSize, color: widget.isActive ? widget.activeColor : widget.inactiveColor),
          ],
        ),
      ),
    );
  }
}

// PostTypeFilterBottomSheet
class PostTypeFilterBottomSheet extends StatefulWidget {
  final List<String> allPostTypes;
  final Set<String> initialSelectedTypes;

  const PostTypeFilterBottomSheet({Key? key, required this.allPostTypes, required this.initialSelectedTypes}) : super(key: key);

  @override
  _PostTypeFilterBottomSheetState createState() => _PostTypeFilterBottomSheetState();
}

class _PostTypeFilterBottomSheetState extends State<PostTypeFilterBottomSheet> {
  late Set<String> _currentSelectedTypes;

  @override
  void initState() {
    super.initState();
    _currentSelectedTypes = Set.from(widget.initialSelectedTypes);
  }

  Map<String, dynamic> _getPostTypeDetails(String typeName) {
    switch (typeName) {
      case 'Text Post':
        return {'icon': Icons.description, 'color': Colors.blueAccent};
      case 'Image Post':
        return {'icon': Icons.image, 'color': Colors.greenAccent};
      case 'Video Post':
        return {'icon': Icons.videocam, 'color': Colors.redAccent};
      case 'Event':
        return {'icon': Icons.event, 'color': Colors.orangeAccent};
      case 'Poll':
        return {'icon': Icons.bar_chart, 'color': Colors.purpleAccent};
      case 'Link':
        return {'icon': Icons.link, 'color': Colors.tealAccent};
      case 'File':
        return {'icon': Icons.attach_file, 'color': Colors.brown};
      case 'Announcement':
        return {'icon': Icons.campaign, 'color': Colors.pinkAccent};
      case 'YouTube':
        return {'icon': Icons.play_circle_fill, 'color': Colors.red};
      case 'Audio':
        return {'icon': Icons.audiotrack, 'color': Colors.deepOrange};
      case 'Donation':
        return {'icon': Icons.volunteer_activism, 'color': Colors.indigo};
      case 'Article':
        return {'icon': Icons.article, 'color': Colors.cyan};
      case 'Jobs':
        return {'icon': Icons.work, 'color': Colors.lime};
      default:
        return {'icon': Icons.category, 'color': Colors.grey};
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 0.8.sh,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Filter Post Types', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp)),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentSelectedTypes.clear();
                    });
                  },
                  child: Text('Clear All', style: GoogleFonts.lato(fontSize: 14.sp, color: Theme.of(context).colorScheme.primary)),
                ),
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentSelectedTypes = Set.from(widget.allPostTypes);
                    });
                  },
                  child: Text('Select All', style: GoogleFonts.lato(fontSize: 14.sp, color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 10.w,
                  runSpacing: 10.h,
                  children:
                      widget.allPostTypes.map((typeName) {
                        final bool isSelected = _currentSelectedTypes.contains(typeName);
                        final typeDetails = _getPostTypeDetails(typeName);
                        final Color chipColor = isSelected ? (typeDetails['color'] as Color) : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5);
                        final Color textColor =
                            isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimary // Text color for selected chips
                                : Theme.of(context).colorScheme.onSurface; // Text color for unselected chips
                        final Color iconColor =
                            isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .onPrimary // Icon color for selected chips
                                : (typeDetails['color'] as Color); // Original color for unselected chips

                        return ActionChip(
                          avatar: Icon(typeDetails['icon'] as IconData, size: 20.sp, color: iconColor),
                          label: Text(typeName, style: GoogleFonts.lato(fontSize: 14.sp, fontWeight: FontWeight.w500, color: textColor)),
                          onPressed: () {
                            setState(() {
                              if (isSelected) {
                                _currentSelectedTypes.remove(typeName);
                              } else {
                                _currentSelectedTypes.add(typeName);
                              }
                            });
                          },
                          backgroundColor: chipColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            side: BorderSide(color: isSelected ? (typeDetails['color'] as Color).withOpacity(0.8) : Theme.of(context).colorScheme.outline.withOpacity(0.5), width: 1.w),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          elevation: isSelected ? 2 : 0,
                        );
                      }).toList(),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _currentSelectedTypes);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text('Apply Filters', style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extension to easily find firstWhereOrNull, similar to Kotlin/Swift
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

// --- TopicPostsScreen ---
class TopicPostsScreen extends StatefulWidget {
  final String topicId;

  const TopicPostsScreen({Key? key, required this.topicId}) : super(key: key);

  @override
  State<TopicPostsScreen> createState() => _TopicPostsScreenState();
}

class _TopicPostsScreenState extends State<TopicPostsScreen> {
  bool _isNearbyPostsActive = false;
  double? _activeNearbyRadiusKm;
  Set<String> _selectedPostTypes = Set.from(availablePostTypeNames);

  // Dummy data for organizations and topics to simulate a lookup
  final List<Organization> _dummyOrganizations = [
    Organization(id: 'org1', name: 'Global Tech Solutions', shortName: 'GTS', type: 'Technology', logoUrl: 'https://picsum.photos/id/100/40', isVerified: true),
    Organization(id: 'org2', name: 'Health & Wellness Co.', shortName: 'HWC', type: 'Healthcare', logoUrl: 'https://picsum.photos/id/101/40'),
    Organization(id: 'org3', name: 'Artistic Creations Studio', shortName: 'ACS', type: 'Arts & Culture', logoUrl: 'https://picsum.photos/id/102/40', isVerified: true),
    Organization(id: 'org4', name: 'Eco-Friendly Living', shortName: 'EFL', type: 'Environment', logoUrl: 'https://picsum.photos/id/103/40'),
    Organization(id: 'org5', name: 'Future Education Hub', shortName: 'FEH', type: 'Education', logoUrl: 'https://picsum.photos/id/104/40', isVerified: true),
  ];

  final List<Topic> _dummyTopics = [
    Topic(id: 'topic1', name: 'Innovations', orgId: 'org1'),
    Topic(id: 'topic2', name: 'Daily Habits', orgId: 'org2'),
    Topic(id: 'topic3', name: 'Digital Art', orgId: 'org3'),
    Topic(id: 'topic4', name: 'Recycling Tips', orgId: 'org4'),
    Topic(id: 'topic5', name: 'Online Courses', orgId: 'org5'),
    Topic(id: 'topic6', name: 'AI Ethics', orgId: 'org1'),
    Topic(id: 'topic7', name: 'Mental Health', orgId: 'org2'),
    Topic(id: 'topic8', name: 'Sculpture', orgId: 'org3'),
  ];

  // Method to get the Organization associated with the given topicId
  Organization? _getOrganizationForTopic(String topicId) {
    final Topic? topic = _dummyTopics.firstWhereOrNull((t) => t.id == topicId);
    if (topic != null) {
      return _dummyOrganizations.firstWhereOrNull((org) => org.id == topic.orgId);
    }
    return null;
  }

  // Method to get the Topic object based on topicId
  Topic? _getTopicById(String topicId) {
    return _dummyTopics.firstWhereOrNull((t) => t.id == topicId);
  }

  Future<void> _handleLocationPermissionsAndService() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      // accessing the position and request users of the App to enable the location services.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled. Please enable them to use this feature.')));
      // Attempt to open location settings to prompt user
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        // User still didn't enable it
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services still disabled. Cannot enable nearby posts.')));
        return; // Exit if user doesn't enable service
      }
    }

    // Check permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied. Please grant permission to use nearby posts.')));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied. Please enable them from app settings.')));
      // Optionally open app settings for the user
      await Geolocator.openAppSettings();
      return;
    }

    // If we reach here, permissions are granted and service is enabled
    _showNearbyPostsDialog();
  }

  void _showNearbyPostsDialog() {
    // This dialog now only appears AFTER permissions and service check
    // Logic for radius selection and toggle remains the same
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        double _dialogSelectedRadiusKm = _activeNearbyRadiusKm ?? 100.0;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateInDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Row(
                children: [
                  Icon(_isNearbyPostsActive ? Icons.location_off : Icons.location_on, color: _isNearbyPostsActive ? Colors.redAccent : Theme.of(context).colorScheme.primary, size: 28.sp),
                  SizedBox(width: 10.w),
                  Expanded(child: Text(_isNearbyPostsActive ? 'Disable Nearby Posts?' : 'Enable Nearby Posts?', style: GoogleFonts.lato(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface))),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isNearbyPostsActive
                        ? 'Are you sure you want to stop seeing posts from your nearby location? You can re-enable it anytime.'
                        : 'Allow OrgOrbit to access your location to show you relevant posts from nearby organizations and users.',
                    style: GoogleFonts.lato(fontSize: 15.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (!_isNearbyPostsActive) ...[
                    SizedBox(height: 20.h),
                    Text('Select Radius: ${_dialogSelectedRadiusKm.round()} km', style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    Slider(
                      value: _dialogSelectedRadiusKm,
                      min: 10.0,
                      max: 2500.0,
                      divisions: 25,
                      label: '${_dialogSelectedRadiusKm.round()} km',
                      onChanged: (double newValue) {
                        setStateInDialog(() {
                          _dialogSelectedRadiusKm = newValue;
                        });
                      },
                      activeColor: Theme.of(context).colorScheme.primary,
                      inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ],
                ],
              ),
              actionsPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text('Cancel', style: GoogleFonts.lato(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isNearbyPostsActive = !_isNearbyPostsActive;
                      if (_isNearbyPostsActive) {
                        _activeNearbyRadiusKm = _dialogSelectedRadiusKm;
                      } else {
                        _activeNearbyRadiusKm = null;
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isNearbyPostsActive ? 'Nearby Posts Enabled within ${_activeNearbyRadiusKm?.round()} km!' : 'Nearby Posts Disabled.')));
                    Navigator.of(dialogContext).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isNearbyPostsActive ? Colors.redAccent : Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  ),
                  child: Text(_isNearbyPostsActive ? 'Disable' : 'Enable', style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPostTypeFilterSheet() async {
    final Set<String>? updatedSelectedTypes = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return PostTypeFilterBottomSheet(allPostTypes: availablePostTypeNames, initialSelectedTypes: _selectedPostTypes);
      },
    );

    if (updatedSelectedTypes != null && updatedSelectedTypes != _selectedPostTypes) {
      setState(() {
        _selectedPostTypes = updatedSelectedTypes;
      });
      String filterMessage = updatedSelectedTypes.isEmpty ? 'No post types selected (showing nothing).' : 'Filtering by: ${updatedSelectedTypes.join(', ')}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(filterMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final Organization? organization = _getOrganizationForTopic(widget.topicId);
    final Topic? topic = _getTopicById(widget.topicId);

    if (organization == null || topic == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Error', style: GoogleFonts.lato()), centerTitle: true),
        body: Center(child: Text('Organization or Topic not found for ID: ${widget.topicId}.', style: GoogleFonts.lato(fontSize: 16.sp, color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 50.w,
        leading: RadiatingRadarIcon(
          isActive: _isNearbyPostsActive,
          onPressed: _handleLocationPermissionsAndService, // Call permission handler
          iconSize: 28.sp,
          activeColor: Theme.of(context).colorScheme.primary,
          inactiveColor: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the entire row horizontally
          mainAxisSize: MainAxisSize.min, // Make the row take minimum space
          children: [
            CircleAvatar(
              radius: 16.r, // Slightly smaller for compactness
              backgroundImage: NetworkImage(organization.logoUrl),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            SizedBox(width: 8.w), // Reduced space between logo and text
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    organization.name,
                    style: GoogleFonts.lato(
                      fontSize: 15.sp, // Slightly smaller font for org name
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Topic: ${topic.name}', // Compact "Topic: [Topic Name]"
                    style: GoogleFonts.lato(
                      fontSize: 11.sp, // Smaller font for topic name
                      color: Theme.of(context).colorScheme.primary, // Primary color for topic name
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true, // Ensures the title widget itself is centered
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        actions: [IconButton(icon: Icon(Icons.filter_list, size: 28.sp, color: Theme.of(context).colorScheme.onSurfaceVariant), onPressed: _showPostTypeFilterSheet, tooltip: 'Filter Posts'), SizedBox(width: 8.w)],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 10, // Dummy posts
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: Container(
              height: 180.h,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2))),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.network(
                  'https://picsum.photos/seed/${widget.topicId}_post$index/400/250',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, size: 40.sp, color: Theme.of(context).colorScheme.error),
                          SizedBox(height: 8.h),
                          Text('Dummy Post ${index + 1}\nTopic: ${topic.name}', style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
