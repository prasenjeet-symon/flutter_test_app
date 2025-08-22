import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FounderSearchScreen extends StatefulWidget {
  const FounderSearchScreen({super.key});

  @override
  _FounderSearchScreenState createState() => _FounderSearchScreenState();
}

class _FounderSearchScreenState extends State<FounderSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;
  String? _selectedFounder;

  // Dummy data for search with Picsum URLs and userIds
  final List<Map<String, String>> _users = [
    {'name': 'Alice Johnson', 'userId': '@alicej', 'avatar': 'https://picsum.photos/seed/alice/100/100'},
    {'name': 'Bob Smith', 'userId': '@bobsmith', 'avatar': 'https://picsum.photos/seed/bob/100/100'},
    {'name': 'Carol Williams', 'userId': '@carolw', 'avatar': 'https://picsum.photos/seed/carol/100/100'},
    {'name': 'David Brown', 'userId': '@davidb', 'avatar': 'https://picsum.photos/seed/david/100/100'},
  ];
  List<Map<String, String>> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredUsers = _users.where((user) => user['name']!.toLowerCase().contains(_searchController.text.toLowerCase()) || user['userId']!.toLowerCase().contains(_searchController.text.toLowerCase())).toList();
      if (_searchController.text.isNotEmpty) {
        _selectedFounder = null;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectFounder(String? founderName) {
    setState(() {
      _selectedFounder = founderName;
      _searchController.clear();
      _filteredUsers = _users;
      _isSearchFocused = false;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedFounder = null;
      _isSearchFocused = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812), minTextAdapt: true, splitScreenMode: true);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: Theme.of(context).colorScheme.onSurface, size: 24.sp),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Select Founder', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface, fontSize: 20.sp)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Find the Organization Founder', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface, fontSize: 28.sp), textAlign: TextAlign.left),
              SizedBox(height: 16.h),
              Text(
                'Search for an existing user or select yourself as the founder.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 16.sp, height: 1.5),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 32.h),
              // Search Input
              Focus(
                onFocusChange: (isFocused) {
                  setState(() {
                    _isSearchFocused = isFocused;
                    if (isFocused && _searchController.text.isNotEmpty) {
                      _selectedFounder = null;
                    }
                  });
                },
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for a user...',
                    hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), fontSize: 16.sp),
                    prefixIcon: Icon(Icons.search_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), size: 24.sp),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface.withOpacity(0.1),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
                  ),
                  style: TextStyle(fontSize: 16.sp, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              SizedBox(height: 24.h),
              // Selected Founder Card or Search Results or Select Yourself Card
              Expanded(
                child: Column(
                  children: [
                    if (_selectedFounder != null)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primary.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20.r,
                                  backgroundImage: _selectedFounder == 'Current User' ? const NetworkImage('https://picsum.photos/seed/currentuser/100/100') : NetworkImage(_users.firstWhere((user) => user['name'] == _selectedFounder)['avatar']!),
                                ),
                                SizedBox(width: 16.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_selectedFounder!, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
                                    SizedBox(height: 4.h),
                                    Text(
                                      _selectedFounder == 'Current User' ? '@currentuser' : _users.firstWhere((user) => user['name'] == _selectedFounder)['userId']!,
                                      style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(icon: Icon(Icons.close_rounded, size: 24.sp, color: Theme.of(context).colorScheme.onPrimary), onPressed: _clearSelection),
                          ],
                        ),
                      )
                    else if (_isSearchFocused || _searchController.text.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return GestureDetector(
                              onTap: () {
                                _selectFounder(user['name']);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                                margin: EdgeInsets.only(bottom: 12.h),
                                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface.withOpacity(0.1), borderRadius: BorderRadius.circular(12.r)),
                                child: Row(
                                  children: [
                                    CircleAvatar(radius: 20.r, backgroundImage: NetworkImage(user['avatar']!)),
                                    SizedBox(width: 16.w),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(user['name']!, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
                                        SizedBox(height: 4.h),
                                        Text(user['userId']!, style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () {
                          _selectFounder('Current User');
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(0.7), Theme.of(context).colorScheme.primary.withOpacity(0.5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(radius: 20.r, backgroundImage: const NetworkImage('https://picsum.photos/seed/currentuser/100/100')),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Select Yourself as Founder', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onPrimary)),
                                    SizedBox(height: 4.h),
                                    Text('@currentuser', style: TextStyle(fontSize: 14.sp, color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:
          _selectedFounder != null
              ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/next_screen');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.w),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_rounded, size: 24.sp, color: Theme.of(context).colorScheme.primary),
                        SizedBox(width: 8.w),
                        Text('Continue', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                  ),
                ),
              )
              : null,
    );
  }
}
