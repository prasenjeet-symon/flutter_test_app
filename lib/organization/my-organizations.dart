// lib/organization_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Enum to represent user roles in a type-safe way.
enum UserRole { ADMIN, MEMBER, MAINTAINER }

class Organization {
  final String logoUrl;
  final String name;
  final String type;
  final bool isVerified;
  final String bio;
  final UserRole userRole;
  final String founderName;
  final String founderLogoUrl;
  final bool isFounderVerified;

  Organization({
    required this.logoUrl,
    required this.name,
    required this.type,
    required this.isVerified,
    required this.bio,
    required this.userRole,
    required this.founderName,
    required this.founderLogoUrl,
    required this.isFounderVerified,
  });
}

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  // Mock data for demonstration purposes
  final List<Organization> _allOrganizations = [
    Organization(
      logoUrl: 'https://picsum.photos/seed/google/150',
      name: 'Google Developers',
      type: 'Tech Community',
      isVerified: true,
      bio:
          'The official space for Google developers to learn, share, and connect. We empower developers everywhere.',
      userRole: UserRole.ADMIN,
      founderName: 'Sundar P.',
      founderLogoUrl: 'https://picsum.photos/seed/sundar/150',
      isFounderVerified: true,
    ),
    Organization(
      logoUrl: 'https://picsum.photos/seed/flutter/150',
      name: 'Flutter Community',
      type: 'Open Source',
      isVerified: true,
      bio:
          'A global community for Flutter developers. Share your projects, get help, and contribute to the ecosystem.',
      userRole: UserRole.MEMBER,
      founderName: 'Evan F.',
      founderLogoUrl: 'https://picsum.photos/seed/evan/150',
      isFounderVerified: false,
    ),
    Organization(
      logoUrl: 'https://picsum.photos/seed/android/150',
      name: 'Android Innovators',
      type: 'Mobile Development',
      isVerified: false,
      bio:
          'A group dedicated to pushing the boundaries of what\'s possible with the Android platform.',
      userRole: UserRole.MAINTAINER,
      founderName: 'Andy R.',
      founderLogoUrl: 'https://picsum.photos/seed/andy/150',
      isFounderVerified: true,
    ),
    Organization(
      logoUrl: 'https://picsum.photos/seed/design/150',
      name: 'Design Hub',
      type: 'Creative Collective',
      isVerified: false,
      bio:
          'A place for designers to collaborate, showcase their work, and find inspiration for their next big project.',
      userRole: UserRole.MEMBER,
      founderName: 'Jane D.',
      founderLogoUrl: 'https://picsum.photos/seed/jane/150',
      isFounderVerified: false,
    ),
  ];

  List<Organization> _filteredOrganizations = [];
  UserRole? _selectedRole; // Can be null (for 'All')

  @override
  void initState() {
    super.initState();
    _filteredOrganizations = _allOrganizations;
  }

  void _filterOrganizations(UserRole? role) {
    setState(() {
      _selectedRole = role;
      if (_selectedRole == null) {
        _filteredOrganizations = _allOrganizations;
      } else {
        _filteredOrganizations =
            _allOrganizations
                .where((org) => org.userRole == _selectedRole)
                .toList();
      }
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final List<UserRole?> options = [null, ...UserRole.values];
        return SafeArea(
          // Added SafeArea
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.h,
                  ),
                  child: Text(
                    'Filter by Role',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ...options.map((role) {
                  final isSelected = _selectedRole == role;
                  return ListTile(
                    title: Text(role?.name ?? 'All'),
                    leading: Icon(
                      isSelected
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                    ),
                    onTap: () {
                      _filterOrganizations(role);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Organizations'), // Updated title
        centerTitle: true, // Centered title
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
            tooltip: 'Filter Organizations',
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildActionButtons(context),
            SizedBox(height: 16.h),
            if (_selectedRole != null) ...[
              _buildActiveFilterChip(),
              SizedBox(height: 16.h),
            ],
            Expanded(
              child:
                  _filteredOrganizations.isEmpty
                      ? _buildEmptyState(context)
                      : _buildOrgList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              /* TODO: Implement create organization logic */
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('New Organization'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              /* TODO: Implement approve requests logic */
            },
            icon: const Icon(Icons.how_to_reg_outlined),
            label: const Text('Approve Requests'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveFilterChip() {
    return Chip(
      label: Text(_selectedRole!.name),
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimary,
        fontWeight: FontWeight.w500,
        fontSize: 13.sp,
      ),
      deleteIcon: Icon(
        Icons.cancel,
        color: Theme.of(context).colorScheme.onPrimary,
        size: 18.r,
      ),
      onDeleted: () {
        _filterOrganizations(null);
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    );
  }

  Widget _buildOrgList() {
    return ListView.builder(
      itemCount: _filteredOrganizations.length,
      itemBuilder: (context, index) {
        final org = _filteredOrganizations[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildOrgListItem(org),
        );
      },
    );
  }

  Widget _buildOrgListItem(Organization org) {
    return Card(
      elevation: 0, // Reduced shadow
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28.r,
                  backgroundImage: NetworkImage(org.logoUrl),
                  backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              org.name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (org.isVerified)
                            Padding(
                              padding: EdgeInsets.only(left: 4.w),
                              child: Icon(
                                Icons.verified,
                                color: Theme.of(context).colorScheme.primary,
                                size: 18.sp,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        org.type,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        org.bio,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          // Reduced font size
                          fontSize: 13.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14.r, // Increased size
                          backgroundImage: NetworkImage(org.founderLogoUrl),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      org.founderName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (org.isFounderVerified)
                                    Padding(
                                      padding: EdgeInsets.only(left: 2.w),
                                      child: Icon(
                                        Icons.verified,
                                        size: 10.sp,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                'Founder',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  fontSize: 10.sp,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14.r, // Increased size
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                          child: Text(
                            'U',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(context).colorScheme.onTertiary,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'You',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11.sp,
                                ),
                              ),
                              Text(
                                org.userRole.name,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.copyWith(
                                  fontSize: 10.sp,
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.corporate_fare_rounded,
            size: 80.r,
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Organizations Found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            'No organizations match the current filter. Try selecting another role or create a new one.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
