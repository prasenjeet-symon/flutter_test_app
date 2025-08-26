import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'manage_mission_screen.dart';
import 'manage_purpose_screen.dart';

class OrganizationSettingsScreen extends StatelessWidget {
  const OrganizationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Organization Settings',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Manage Properties'),
              SizedBox(height: 12.h),
              _buildPropertiesList(context),
              SizedBox(height: 24.h),
              const Divider(),
              SizedBox(height: 24.h),
              _buildSectionTitle(context, 'Manage Dropdown Values'),
              SizedBox(height: 12.h),
              _buildDropdownList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        title,
        style: GoogleFonts.lato(
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildPropertiesList(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 0,
      child: Column(
        children: [
          _buildListTile(context, 'Manage Goals', Icons.flag_outlined, () {
            // Placeholder for navigation to ManageGoalsScreen
            print('Navigating to Manage Goals Screen...');
          }),
          const Divider(height: 0),
          _buildListTile(
            context,
            'Manage Mission',
            Icons.lightbulb_outline,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageMissionScreen()),
              );
            },
          ),
          const Divider(height: 0),
          _buildListTile(
            context,
            'Manage Purpose',
            Icons.assignment_turned_in_outlined,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagePurposeScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownList(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 0,
      child: Column(
        children: [
          _buildListTile(
            context,
            'Mission Categories',
            Icons.category_outlined,
            () {
              print('Managing mission categories...');
            },
          ),
          const Divider(height: 0),
          _buildListTile(
            context,
            'Mission Sub-categories',
            Icons.subtitles_outlined,
            () {
              print('Managing mission sub-categories...');
            },
          ),
          const Divider(height: 0),
          _buildListTile(
            context,
            'Purpose Categories',
            Icons.category_outlined,
            () {
              print('Managing purpose categories...');
            },
          ),
          const Divider(height: 0),
          _buildListTile(
            context,
            'Purpose Sub-categories',
            Icons.subtitles_outlined,
            () {
              print('Managing purpose sub-categories...');
            },
          ),
          const Divider(height: 0),
          _buildListTile(
            context,
            'Goal Categories',
            Icons.assignment_turned_in_outlined,
            () {
              print('Managing goal categories...');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: GoogleFonts.lato(fontSize: 16.sp)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
