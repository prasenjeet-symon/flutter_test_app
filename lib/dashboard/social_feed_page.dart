import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:visibility_detector/visibility_detector.dart';

// --- Main Application Entry Point ---
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ScreenUtilInit is used to make the UI responsive across different screen sizes.
    return ScreenUtilInit(
      designSize: const Size(375, 812), // Example design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(debugShowCheckedModeBanner: false, title: 'Flutter Social Feed', theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.light), useMaterial3: true), home: child);
      },
      child: const SocialFeedPage(),
    );
  }
}

// --- 1. Data Models ---
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

// --- 2. Main Social Feed Page (NO CHANGE) ---
class SocialFeedPage extends StatefulWidget {
  const SocialFeedPage({Key? key}) : super(key: key);

  @override
  State<SocialFeedPage> createState() => _SocialFeedPageState();
}

class _SocialFeedPageState extends State<SocialFeedPage> {
  // Mock Data
  final List<Organization> _organizations = [
    Organization(id: 'org1', name: 'Global Tech Solutions', shortName: 'GTS', type: 'Technology', logoUrl: 'https://picsum.photos/id/100/40', isVerified: true),
    Organization(id: 'org2', name: 'Health & Wellness Co.', shortName: 'HWC', type: 'Healthcare', logoUrl: 'https://picsum.photos/id/101/40'),
    Organization(id: 'org3', name: 'Artistic Creations Studio', shortName: 'ACS', type: 'Arts & Culture', logoUrl: 'https://picsum.photos/id/102/40', isVerified: true),
    Organization(id: 'org4', name: 'Eco-Friendly Living', shortName: 'EFL', type: 'Environment', logoUrl: 'https://picsum.photos/id/103/40'),
    Organization(id: 'org5', name: 'Future Education Hub', shortName: 'FEH', type: 'Education', logoUrl: 'https://picsum.photos/id/104/40', isVerified: true),
  ];

  late final List<Topic> _topics;

  final Map<String, GlobalKey> _organizationKeys = {};
  final Map<String, GlobalKey> _topicChipKeys = {};

  final ScrollController _mainFeedScrollController = ScrollController();
  final ScrollController _topicsBarScrollController = ScrollController();

  String? _selectedTopicId;
  bool _isScrollingProgrammatically = false;
  Set<String> _selectedOrganizationIds = {};
  bool _isNearbyPostsActive = false; // New state for nearby posts
  double? _activeNearbyRadiusKm; // Stores the active radius when enabled

  // Centralized list of available post type names for filtering and creation
  static const List<String> _availablePostTypeNames = ['Text Post', 'Image Post', 'Video Post', 'Event', 'Poll', 'Link', 'File', 'Announcement', 'YouTube', 'Audio', 'Donation', 'Article', 'Jobs'];

  Set<String> _selectedPostTypes = Set.from(_availablePostTypeNames); // Initialize with all selected

  List<Topic> get _filteredTopics {
    if (_selectedOrganizationIds.isEmpty) return [];
    return _topics.where((topic) => _selectedOrganizationIds.contains(topic.orgId)).toList();
  }

  List<Organization> get _filteredOrganizations {
    if (_selectedOrganizationIds.isEmpty) return [];
    // Ensure the order of filtered organizations matches the original order
    return _organizations.where((org) => _selectedOrganizationIds.contains(org.id)).toList();
  }

  @override
  void initState() {
    super.initState();
    _topics = [
      Topic(id: 'topic1', name: 'Innovations', orgId: 'org1'),
      Topic(id: 'topic2', name: 'Daily Habits', orgId: 'org2'),
      Topic(id: 'topic3', name: 'Digital Art', orgId: 'org3'),
      Topic(id: 'topic4', name: 'Recycling Tips', orgId: 'org4'),
      Topic(id: 'topic5', name: 'Online Courses', orgId: 'org5'),
      Topic(id: 'topic6', name: 'AI Ethics', orgId: 'org1'),
      Topic(id: 'topic7', name: 'Mental Health', orgId: 'org2'),
      Topic(id: 'topic8', name: 'Sculpture', orgId: 'org3'),
    ];

    for (var org in _organizations) {
      _organizationKeys[org.id] = GlobalKey();
    }
    for (var topic in _topics) {
      _topicChipKeys[topic.id] = GlobalKey();
    }

    _selectedOrganizationIds = _organizations.map((org) => org.id).toSet();

    if (_filteredTopics.isNotEmpty) {
      _selectedTopicId = _filteredTopics.first.id;
    }
  }

  @override
  void dispose() {
    _mainFeedScrollController.dispose();
    _topicsBarScrollController.dispose();
    super.dispose();
  }

  Future<void> _scrollToOrganization(String orgId) async {
    final key = _organizationKeys[orgId];
    if (key != null && key.currentContext != null) {
      await Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, alignment: 0.0);
    }
  }

  void _scrollToChip(String topicId) {
    final key = _topicChipKeys[topicId];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(key.currentContext!, duration: const Duration(milliseconds: 300), curve: Curves.easeOut, alignment: 0.5);
    }
  }

  void _showOrganizationSelection() async {
    final Set<String>? updatedSelection = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return OrganizationMultiSelectBottomSheet(organizations: _organizations, initialSelectedIds: _selectedOrganizationIds);
      },
    );

    if (updatedSelection != null && updatedSelection != _selectedOrganizationIds) {
      setState(() {
        _selectedOrganizationIds = updatedSelection;
        if (_selectedTopicId != null && !_filteredTopics.any((t) => t.id == _selectedTopicId)) {
          _selectedTopicId = _filteredTopics.isNotEmpty ? _filteredTopics.first.id : null;
        } else if (_selectedTopicId == null && _filteredTopics.isNotEmpty) {
          _selectedTopicId = _filteredTopics.first.id;
        }
      });
      if (_selectedTopicId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToChip(_selectedTopicId!);
        });
      }
      if (_filteredOrganizations.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToOrganization(_filteredOrganizations.first.id);
        });
      } else {
        _mainFeedScrollController.jumpTo(_mainFeedScrollController.position.minScrollExtent);
      }
    }
  }

  void _showCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const CreatePostBottomSheet();
      },
    );
  }

  // Dialog for Nearby Posts
  void _showNearbyPostsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use the currently active radius or a default when enabling
        double _dialogSelectedRadiusKm = _activeNearbyRadiusKm ?? 100.0;

        return StatefulBuilder(
          // StatefulBuilder allows managing state within the dialog
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
                mainAxisSize: MainAxisSize.min, // Important for Column in content
                children: [
                  Text(
                    _isNearbyPostsActive
                        ? 'Are you sure you want to stop seeing posts from your nearby location? You can re-enable it anytime.'
                        : 'Allow OrgOrbit to access your location to show you relevant posts from nearby organizations and users.',
                    style: GoogleFonts.lato(fontSize: 15.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  if (!_isNearbyPostsActive) ...[
                    // Show radius selector only when enabling
                    SizedBox(height: 20.h),
                    Text('Select Radius: ${_dialogSelectedRadiusKm.round()} km', style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                    Slider(
                      value: _dialogSelectedRadiusKm,
                      min: 10.0,
                      max: 2500.0, // Max radius to cover large areas like India
                      divisions: 25, // 2500 / 25 = 100km increments
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
                      // This setState is for the main SocialFeedPageState
                      _isNearbyPostsActive = !_isNearbyPostsActive;
                      if (_isNearbyPostsActive) {
                        _activeNearbyRadiusKm = _dialogSelectedRadiusKm; // Save selected radius
                      } else {
                        _activeNearbyRadiusKm = null; // Clear radius when disabled
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

  // New function to show post type filter sheet
  void _showPostTypeFilterSheet() async {
    final Set<String>? updatedSelectedTypes = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true, // Allows the sheet to take full height if content requires
      builder: (context) {
        return PostTypeFilterBottomSheet(allPostTypes: _availablePostTypeNames, initialSelectedTypes: _selectedPostTypes);
      },
    );

    if (updatedSelectedTypes != null && updatedSelectedTypes != _selectedPostTypes) {
      setState(() {
        _selectedPostTypes = updatedSelectedTypes;
      });
      // For demonstration, show a snackbar with selected filters
      String filterMessage = updatedSelectedTypes.isEmpty ? 'No post types selected (showing nothing).' : 'Filtering by: ${updatedSelectedTypes.join(', ')}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(filterMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Organization> currentSelectedOrgs = _organizations.where((org) => _selectedOrganizationIds.contains(org.id)).toList();
    final int selectedCount = currentSelectedOrgs.length;
    final double logoRadius = 13.r; // Radius for AppBar logos
    final double overlapAmount = 10.w; // How much logos overlap

    Widget appBarLeadingLogos;

    if (selectedCount == 0) {
      appBarLeadingLogos = Text(
        'Select Orgs', // Shorter text for space
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 16.sp),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    } else if (selectedCount == 1) {
      final Organization selectedOrg = currentSelectedOrgs.first;
      appBarLeadingLogos = CircleAvatar(radius: logoRadius, backgroundImage: NetworkImage(selectedOrg.logoUrl), backgroundColor: Theme.of(context).colorScheme.primaryContainer);
    } else {
      // Multiple organizations selected - overlapping logos
      const int maxLogosToShow = 3; // Show up to 3 logos overlapping
      final List<Organization> logosToDisplay = currentSelectedOrgs.take(maxLogosToShow).toList();

      appBarLeadingLogos = SizedBox(
        width: (logoRadius * 2 * logosToDisplay.length) - (overlapAmount * (logosToDisplay.length - 1)),
        height: logoRadius * 2,
        child: Stack(
          children: List.generate(logosToDisplay.length, (index) {
            return Positioned(
              left: index * (logoRadius * 2 - overlapAmount),
              child: CircleAvatar(
                radius: logoRadius,
                backgroundImage: NetworkImage(logosToDisplay[index].logoUrl),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child:
                    index == maxLogosToShow - 1 && selectedCount > maxLogosToShow
                        ? // If this is the last visible logo and there are more
                        ClipOval(
                          child: Container(
                            color: Colors.black54, // Dark overlay
                            alignment: Alignment.center,
                            child: Text('+${selectedCount - maxLogosToShow}', style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                          ),
                        )
                        : null,
              ),
            );
          }),
        ),
      );
    }

    // Calculate dynamic leadingWidth to prevent overflow
    double radarIconBaseWidth = 40.w; // Base width for the radar icon area
    double spacingBetweenRadarAndLogos = 4.w;
    double logosWidgetWidth;

    if (selectedCount == 0) {
      logosWidgetWidth = 80.w; // Estimated width for "Select Orgs" text
    } else if (selectedCount == 1) {
      logosWidgetWidth = logoRadius * 2;
    } else {
      logosWidgetWidth = (logoRadius * 2 * (selectedCount > 3 ? 3 : selectedCount)) - (overlapAmount * ((selectedCount > 3 ? 3 : selectedCount) - 1));
    }
    double calculatedLeadingWidth = radarIconBaseWidth + spacingBetweenRadarAndLogos + logosWidgetWidth + 16.w; // Total padding

    return Scaffold(
      appBar: AppBar(
        // Leading section for Radar icon and Org Selection Logos
        leadingWidth: calculatedLeadingWidth,
        leading: Row(
          mainAxisSize: MainAxisSize.min, // Ensure Row takes minimal space
          children: [
            SizedBox(width: 8.w), // Padding before the first icon
            RadiatingRadarIcon(
              isActive: _isNearbyPostsActive,
              onPressed: _showNearbyPostsDialog,
              iconSize: 28.sp,
              activeColor: Theme.of(context).colorScheme.primary, // Using primary color for active radar
              inactiveColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: 4.w), // Space between radar and logos
            GestureDetector(onTap: _showOrganizationSelection, child: Align(alignment: Alignment.centerLeft, child: appBarLeadingLogos)),
          ],
        ),
        title: Text(
          'OrgOrbit', // Renamed from 'Social Feed'
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 20.sp),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, size: 28.sp, color: Theme.of(context).colorScheme.onSurfaceVariant),
            onPressed: _showPostTypeFilterSheet, // Call the new filter function
            tooltip: 'Filter Posts',
          ),
          IconButton(icon: Icon(Icons.add_box_outlined, size: 28.sp, color: Theme.of(context).colorScheme.primary), onPressed: _showCreatePostSheet, tooltip: 'Create New Post'),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // Horizontal Scrollable Topics Bar
          Container(
            height: 60.h,
            color: Theme.of(context).colorScheme.surface,
            child: ListView.builder(
              controller: _topicsBarScrollController,
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _filteredTopics.length,
              itemBuilder: (context, index) {
                final topic = _filteredTopics[index];
                final organization = _organizations.firstWhere((org) => org.id == topic.orgId);
                final bool isSelected = topic.id == _selectedTopicId;

                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: ActionChip(
                    key: _topicChipKeys[topic.id],
                    avatar: Icon(Icons.topic_outlined, size: 20.sp, color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant),
                    label: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(topic.name, style: GoogleFonts.lato(fontSize: 13.sp, color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500)),
                        Text('(${organization.shortName})', style: GoogleFonts.lato(fontSize: 10.sp, color: isSelected ? Theme.of(context).colorScheme.onPrimary.withOpacity(0.8) : Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    onPressed: () async {
                      setState(() {
                        _isScrollingProgrammatically = true;
                        _selectedTopicId = topic.id;
                      });
                      _scrollToChip(topic.id);
                      await _scrollToOrganization(topic.orgId);
                      if (mounted) {
                        setState(() {
                          _isScrollingProgrammatically = false;
                        });
                      }
                    },
                    backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r), side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline.withOpacity(0.5))),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1.h, color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),

          // Main Scrollable Feed Content
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is UserScrollNotification && _isScrollingProgrammatically) {
                  if (mounted) {
                    setState(() {
                      _isScrollingProgrammatically = false;
                    });
                  }
                }
                return false;
              },
              child:
                  _filteredOrganizations.isEmpty
                      ? Center(child: Text('No organizations selected. Tap the logos to select.', style: GoogleFonts.lato(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurfaceVariant), textAlign: TextAlign.center))
                      : ListView.builder(
                        controller: _mainFeedScrollController,
                        padding: EdgeInsets.symmetric(vertical: 16.w),
                        itemCount: _filteredOrganizations.length,
                        itemBuilder: (context, index) {
                          final organization = _filteredOrganizations[index];
                          return VisibilityDetector(
                            key: ValueKey('org_section_${organization.id}'),
                            onVisibilityChanged: (visibilityInfo) {
                              if (!_isScrollingProgrammatically && visibilityInfo.visibleFraction > 0.4) {
                                final relevantTopic = _filteredTopics.firstWhereOrNull((t) => t.orgId == organization.id);

                                if (relevantTopic != null && _selectedTopicId != relevantTopic.id) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    if (mounted) {
                                      setState(() {
                                        _selectedTopicId = relevantTopic.id;
                                      });
                                      _scrollToChip(relevantTopic.id);
                                    }
                                  });
                                }
                              }
                            },
                            child: OrganizationFeedSection(key: _organizationKeys[organization.id], organization: organization, topics: _topics, selectedTopicId: _selectedTopicId),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. Organization Feed Section Widget (NO CHANGE) ---
class OrganizationFeedSection extends StatelessWidget {
  final Organization organization;
  final List<Topic> topics;
  final String? selectedTopicId;

  const OrganizationFeedSection({Key? key, required this.organization, required this.topics, required this.selectedTopicId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Topic? selectedTopic = topics.where((t) => t.id == selectedTopicId).isNotEmpty ? topics.firstWhere((t) => t.id == selectedTopicId) : null;
    final bool isTopicForThisOrg = selectedTopic?.orgId == organization.id;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.2))),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 18.r, backgroundImage: NetworkImage(organization.logoUrl), backgroundColor: Theme.of(context).colorScheme.primaryContainer),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(organization.name, style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                          if (organization.isVerified) ...[SizedBox(width: 4.w), Icon(Icons.verified, size: 16.sp, color: Theme.of(context).colorScheme.primary)],
                        ],
                      ),
                      Text(organization.type, style: GoogleFonts.lato(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (isTopicForThisOrg && selectedTopic != null)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text('Topic: ${selectedTopic.name}', style: GoogleFonts.lato(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('View All posts from ${organization.name}')));
                  },
                  child: Text('View All', style: GoogleFonts.lato(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5 + (index * 0.05)),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                    ),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        'https://picsum.photos/seed/${organization.id}_${index + 1}/300/120',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Text('Dummy Post ${index + 1}', style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Organization Multi-Select Bottom Sheet (NO CHANGE)
class OrganizationMultiSelectBottomSheet extends StatefulWidget {
  final List<Organization> organizations;
  final Set<String> initialSelectedIds;

  const OrganizationMultiSelectBottomSheet({Key? key, required this.organizations, required this.initialSelectedIds}) : super(key: key);

  @override
  State<OrganizationMultiSelectBottomSheet> createState() => _OrganizationMultiSelectBottomSheetState();
}

class _OrganizationMultiSelectBottomSheetState extends State<OrganizationMultiSelectBottomSheet> {
  late Set<String> _currentSelectedIds;

  @override
  void initState() {
    super.initState();
    _currentSelectedIds = Set.from(widget.initialSelectedIds);
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
                Text('Select Organizations', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, fontSize: 20.sp)),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.builder(
                itemCount: widget.organizations.length,
                itemBuilder: (context, index) {
                  final org = widget.organizations[index];
                  final isSelected = _currentSelectedIds.contains(org.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (bool? newValue) {
                      setState(() {
                        if (newValue == true) {
                          _currentSelectedIds.add(org.id);
                        } else {
                          _currentSelectedIds.remove(org.id);
                        }
                      });
                    },
                    title: Row(
                      children: [
                        CircleAvatar(radius: 16.r, backgroundImage: NetworkImage(org.logoUrl)),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(org.name, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 15.sp)),
                                  if (org.isVerified) ...[SizedBox(width: 4.w), Icon(Icons.verified, size: 14.sp, color: Theme.of(context).colorScheme.primary)],
                                ],
                              ),
                              Text(org.type, style: GoogleFonts.lato(fontSize: 12.sp, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, _currentSelectedIds);
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text('Done', style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// NEW WIDGET: Create Post Bottom Sheet (NO CHANGE)
class CreatePostBottomSheet extends StatelessWidget {
  const CreatePostBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define your post types with icons and text
    final List<Map<String, dynamic>> postTypes = [
      {'name': 'Text Post', 'icon': Icons.description, 'color': Colors.blueAccent},
      {'name': 'Image Post', 'icon': Icons.image, 'color': Colors.greenAccent},
      {'name': 'Video Post', 'icon': Icons.videocam, 'color': Colors.redAccent},
      {'name': 'Event', 'icon': Icons.event, 'color': Colors.orangeAccent},
      {'name': 'Poll', 'icon': Icons.bar_chart, 'color': Colors.purpleAccent},
      {'name': 'Link', 'icon': Icons.link, 'color': Colors.tealAccent},
      {'name': 'File', 'icon': Icons.attach_file, 'color': Colors.brown},
      {'name': 'Announcement', 'icon': Icons.campaign, 'color': Colors.pinkAccent},
      {'name': 'YouTube', 'icon': Icons.play_circle_fill, 'color': Colors.red},
      {'name': 'Audio', 'icon': Icons.audiotrack, 'color': Colors.deepOrange},
      {'name': 'Donation', 'icon': Icons.volunteer_activism, 'color': Colors.indigo},
      {'name': 'Article', 'icon': Icons.article, 'color': Colors.cyan}, // New
      {'name': 'Jobs', 'icon': Icons.work, 'color': Colors.lime}, // New
    ];

    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keep column compact, but allow content inside to scroll
          children: [
            Align(alignment: Alignment.topRight, child: IconButton(icon: Icon(Icons.close, size: 24.sp), onPressed: () => Navigator.pop(context))),
            Text('Create New Post', style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold, fontSize: 22.sp), textAlign: TextAlign.center),
            SizedBox(height: 24.h),
            Expanded(
              // Expanded to fill remaining space
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 16.w, mainAxisSpacing: 16.h, childAspectRatio: 0.85),
                itemCount: postTypes.length,
                itemBuilder: (context, index) {
                  final type = postTypes[index];
                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Creating a ${type['name']}')));
                      Navigator.pop(context);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 70.w,
                          height: 70.w,
                          decoration: BoxDecoration(color: (type['color'] as Color).withOpacity(0.2), borderRadius: BorderRadius.circular(15.r), border: Border.all(color: (type['color'] as Color).withOpacity(0.5))),
                          child: Icon(type['icon'] as IconData, size: 36.sp, color: type['color'] as Color),
                        ),
                        SizedBox(height: 8.h),
                        Text(type['name'] as String, style: GoogleFonts.lato(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface), textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

// NEW WIDGET: PostTypeFilterBottomSheet (MODIFIED)
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

  // Helper to get IconData and Color for a given post type name
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
        return {'icon': Icons.category, 'color': Colors.grey}; // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 0.8.sh, // Take 80% of screen height
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
                    Navigator.pop(context); // Pop without returning any value
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
                // Use SingleChildScrollView for the Wrap
                child: Wrap(
                  spacing: 10.w, // Horizontal space between chips
                  runSpacing: 10.h, // Vertical space between rows of chips
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
                          elevation: isSelected ? 2 : 0, // Add a slight elevation for selected chips
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
                  Navigator.pop(context, _currentSelectedTypes); // Return selected types
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

// NEW WIDGET: Radiating Radar Icon for animation (NO CHANGE)
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
      // Use InkWell for better tap feedback on custom widget
      onTap: widget.onPressed,
      borderRadius: BorderRadius.circular(widget.iconSize * 0.7), // Match icon circularity
      child: Container(
        // Wrap in a sized container to control hit test area and potential overflow
        width: widget.iconSize * 1.5, // Make it slightly larger for the radiating effect
        height: widget.iconSize * 1.5,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (widget.isActive) // Show radiating circles only when active
              ...List.generate(3, (index) {
                // Generate 3 radiating circles
                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    // Stagger the animations
                    final delay = index * 0.2; // Delay for each circle (adjusted for smoother overlap)
                    final normalizedValue = (_controller.value + delay) % 1.0;
                    final opacity = (1.0 - normalizedValue).clamp(0.0, 1.0); // Fades out from 1 to 0
                    final scale = 1.0 + (normalizedValue * 1.5); // Expands from 1x to 2.5x

                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: widget.iconSize,
                          height: widget.iconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.activeColor.withOpacity(0.4), // Semi-transparent color for pulses
                          ),
                        ),
                      ),
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

// Extension to easily find firstWhereOrNull, similar to Kotlin/Swift (NO CHANGE)
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
