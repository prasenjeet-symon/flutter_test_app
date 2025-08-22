import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Mock data for demonstration
class Organization {
  final String name;
  final String shortName;
  final String logoUrl;

  Organization({required this.name, required this.shortName, required this.logoUrl});

  // Override equality for easy comparison
  @override
  bool operator ==(Object other) => identical(this, other) || other is Organization && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

class SelectParentScreen extends StatefulWidget {
  const SelectParentScreen({super.key});

  @override
  _SelectParentScreenState createState() => _SelectParentScreenState();
}

class _SelectParentScreenState extends State<SelectParentScreen> {
  // A mock list of all parent organizations
  final List<Organization> _allOrganizations = [
    Organization(name: 'Tech Innovators Inc.', shortName: 'TII', logoUrl: 'https://picsum.photos/seed/tii/200'),
    Organization(name: 'Global Solutions Ltd.', shortName: 'GSL', logoUrl: 'https://picsum.photos/seed/gsl/200'),
    Organization(name: 'Creative Ventures Group', shortName: 'CVG', logoUrl: 'https://picsum.photos/seed/cvg/200'),
    Organization(name: 'Future Forward Corp.', shortName: 'FFC', logoUrl: 'https://picsum.photos/seed/ffc/200'),
    Organization(name: 'Digital Pioneers LLC', shortName: 'DPL', logoUrl: 'https://picsum.photos/seed/dpl/200'),
    Organization(name: 'Synergy Enterprises', shortName: 'SE', logoUrl: 'https://picsum.photos/seed/se/200'),
    Organization(name: 'Nexus Solutions', shortName: 'NS', logoUrl: 'https://picsum.photos/seed/ns/200'),
    Organization(name: 'Apex Innovations', shortName: 'AI', logoUrl: 'https://picsum.photos/seed/ai/200'),
    Organization(name: 'Quantum Dynamics', shortName: 'QD', logoUrl: 'https://picsum.photos/seed/qd/200'),
  ];

  // A small list to display initially
  List<Organization> _initialOrganizations = [];

  // The list displayed to the user, filtered by the search query
  List<Organization> _filteredOrganizations = [];
  final TextEditingController _searchController = TextEditingController();
  Organization? _selectedOrganization;

  @override
  void initState() {
    super.initState();
    // Show a small, curated list initially
    _initialOrganizations = _allOrganizations.take(3).toList();
    _filteredOrganizations = _initialOrganizations;
    _searchController.addListener(_filterOrganizations);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterOrganizations);
    _searchController.dispose();
    super.dispose();
  }

  void _filterOrganizations() {
    final query = _searchController.text.toLowerCase();

    List<Organization> tempFilteredList;
    if (query.isEmpty) {
      // Use the initial list as the base when search is empty
      tempFilteredList = List.from(_initialOrganizations);
    } else {
      // Filter the entire list when a query is present
      tempFilteredList = _allOrganizations.where((org) => org.name.toLowerCase().contains(query) || org.shortName.toLowerCase().contains(query)).toList();
    }

    // If an organization is selected, make it the first item in the list
    if (_selectedOrganization != null) {
      // Use a new list to avoid modifying the original list
      List<Organization> finalFilteredList = List.from(tempFilteredList);
      finalFilteredList.removeWhere((org) => org == _selectedOrganization);
      _filteredOrganizations = [_selectedOrganization!, ...finalFilteredList];
    } else {
      _filteredOrganizations = tempFilteredList;
    }

    // Trigger a rebuild to update the UI
    setState(() {});
  }

  void _selectOrganization(Organization organization) {
    setState(() {
      if (_selectedOrganization == organization) {
        _selectedOrganization = null; // Deselect if already selected
      } else {
        _selectedOrganization = organization;
      }
      _filterOrganizations(); // Re-filter to update list
    });
  }

  void _onNext() {
    if (_selectedOrganization != null) {
      // Logic for selected organization
      Navigator.pushNamed(context, '/next_screen', arguments: {'parentOrg': _selectedOrganization!.name});
    } else {
      // You can show a message or handle this case
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an organization or skip.')));
    }
  }

  void _onSkip() {
    Navigator.pushNamed(context, '/next_screen');
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface, size: 24.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Select Parent Organization', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, fontSize: 20.sp)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Find Your Parent Organization', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 28.sp), textAlign: TextAlign.left),
              SizedBox(height: 16.h),
              Text(
                'Search for and select the organization you want to associate with. You can also skip this step.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16.sp, height: 1.5),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 32.h),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for an organization...',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 16.sp),
                  prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 24.sp),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                  contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                ),
                style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
              ),
              SizedBox(height: 16.h),

              // List of Organizations
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredOrganizations.length,
                  itemBuilder: (context, index) {
                    final organization = _filteredOrganizations[index];
                    final isSelected = _selectedOrganization == organization;
                    return Card(
                      elevation: 0,
                      color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surface.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r), side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 2.w)),
                      margin: EdgeInsets.symmetric(vertical: 8.h),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          backgroundImage: NetworkImage(organization.logoUrl),
                          child: (organization.logoUrl.isEmpty) ? Text(organization.shortName, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)) : null,
                        ),
                        title: Text(
                          organization.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 16.sp),
                        ),
                        subtitle: Text(
                          organization.shortName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.7) : Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                        ),
                        trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary, size: 24.sp) : null,
                        onTap: () {
                          _selectOrganization(organization);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedOrganization != null ? _onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    disabledBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  ),
                  child: Text('Next', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
                ),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _onSkip,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2), width: 1.w),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('Skip', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
