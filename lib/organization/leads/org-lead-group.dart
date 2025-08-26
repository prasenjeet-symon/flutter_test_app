import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizationLeadGroupScreen extends StatefulWidget {
  const OrganizationLeadGroupScreen({super.key});

  @override
  _OrganizationLeadGroupScreenState createState() =>
      _OrganizationLeadGroupScreenState();
}

class _OrganizationLeadGroupScreenState
    extends State<OrganizationLeadGroupScreen> {
  final List<Map<String, dynamic>> _leadGroups = [
    {
      'id': 'L1',
      'name': 'Sales Leads',
      'icon': Icons.trending_up,
      'description': 'Leads generated from the sales funnel.',
      'autoAddContext': 'Website form submissions',
      'leadCount': 15,
    },
    {
      'id': 'L2',
      'name': 'Marketing Campaigns',
      'icon': Icons.campaign,
      'description': 'Leads acquired through marketing activities.',
      'autoAddContext': 'Social media campaigns',
      'leadCount': 8,
    },
    {
      'id': 'L3',
      'name': 'Partnership Enquiries',
      'icon': Icons.handshake,
      'description': 'Potential partners and collaboration requests.',
      'autoAddContext': 'Direct emails',
      'leadCount': 0,
    },
  ];

  void _showAddEditGroupDialog({Map<String, dynamic>? group}) {
    final _formKey = GlobalKey<FormState>();
    final isEditing = group != null;
    final nameController = TextEditingController(
      text: isEditing ? group['name'] : '',
    );
    final descriptionController = TextEditingController(
      text: isEditing ? group['description'] : '',
    );
    final autoAddContextController = TextEditingController(
      text: isEditing ? group['autoAddContext'] : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            isEditing ? 'Edit Lead Group' : 'Add Lead Group',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              fontSize: 20.sp,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // Set dialog width
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Group Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Group name is required.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16.h),
                    TextFormField(
                      controller: autoAddContextController,
                      decoration: InputDecoration(
                        labelText: 'Auto-add Context',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.lato(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    if (isEditing) {
                      final index = _leadGroups.indexWhere(
                        (element) => element['id'] == group['id'],
                      );
                      if (index != -1) {
                        _leadGroups[index] = {
                          ..._leadGroups[index],
                          'name': nameController.text,
                          'description': descriptionController.text,
                          'autoAddContext': autoAddContextController.text,
                        };
                      }
                    } else {
                      _leadGroups.add({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'name': nameController.text,
                        'icon': Icons.folder,
                        'description': descriptionController.text,
                        'autoAddContext': autoAddContextController.text,
                        'leadCount': 0,
                      });
                    }
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Lead group ${isEditing ? 'updated' : 'added'} successfully!',
                      ),
                    ),
                  );
                }
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteGroup(Map<String, dynamic> group) {
    if ((group['leadCount'] as int) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot delete a lead group that contains leads.',
            style: GoogleFonts.lato(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
            'Are you sure you want to delete the "${group['name']}" lead group?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                setState(() {
                  _leadGroups.removeWhere((g) => g['id'] == group['id']);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lead group deleted successfully!'),
                  ),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Lead Groups',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20.sp),
        ),
        centerTitle: true,
      ),
      body:
          _leadGroups.isEmpty
              ? Center(
                child: Text(
                  'No lead groups found. Tap the button to create your first one!',
                  style: GoogleFonts.lato(
                    fontSize: 16.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: _leadGroups.length,
                itemBuilder: (context, index) {
                  final group = _leadGroups[index];
                  return _LeadGroupItem(
                    group: group,
                    onEdit: () => _showAddEditGroupDialog(group: group),
                    onDelete: () => _confirmDeleteGroup(group),
                  );
                },
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditGroupDialog(),
        label: const Text('Add Lead Group'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}

class _LeadGroupItem extends StatelessWidget {
  final Map<String, dynamic> group;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LeadGroupItem({
    required this.group,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String name = group['name'] as String;
    final String description = group['description'] as String;
    final int leadCount = group['leadCount'] as int;
    final IconData icon = group['icon'] as IconData;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: ListTile(
        onTap: () {},
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          name,
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 14.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
                SizedBox(width: 4.w),
                Text(
                  '$leadCount leads',
                  style: GoogleFonts.lato(
                    fontSize: 12.sp,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'delete',
                  enabled: leadCount == 0,
                  child: Text(
                    'Delete',
                    style: GoogleFonts.lato(
                      color:
                          leadCount > 0
                              ? Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.4)
                              : Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
        ),
      ),
    );
  }
}
