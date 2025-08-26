import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class LeadListScreen extends StatefulWidget {
  final String groupName;

  const LeadListScreen({super.key, required this.groupName});

  @override
  _LeadListScreenState createState() => _LeadListScreenState();
}

class _LeadListScreenState extends State<LeadListScreen> {
  final List<Map<String, dynamic>> _allLeads = [
    {
      'id': '101',
      'name': 'John Doe',
      'email': 'john.doe@example.com',
      'phone': '+1 555-123-4567',
      'creationDate': DateTime(2025, 8, 15),
      'profilePic': null,
    },
    {
      'id': '102',
      'name': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'phone': '+1 555-987-6543',
      'creationDate': DateTime(2025, 8, 16),
      'profilePic': null,
    },
    {
      'id': '103',
      'name': 'Peter Jones',
      'email': null,
      'phone': '+1 555-111-2222',
      'creationDate': DateTime(2025, 8, 17),
      'profilePic': null,
    },
    {
      'id': '104',
      'name': 'Emily Davis',
      'email': 'emily.davis@example.com',
      'phone': null,
      'creationDate': DateTime(2025, 8, 18),
      'profilePic': null,
    },
  ];

  final List<Map<String, dynamic>> _otherGroups = [
    {'id': 'L2', 'name': 'Marketing Campaigns'},
    {'id': 'L3', 'name': 'Partnership Enquiries'},
  ];

  List<Map<String, dynamic>> _filteredLeads = [];
  final Set<String> _selectedLeads = {};
  bool _isMultiSelectMode = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredLeads = List.from(_allLeads);
    _searchController.addListener(_filterLeads);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterLeads);
    _searchController.dispose();
    super.dispose();
  }

  void _filterLeads() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLeads =
          _allLeads.where((lead) {
            final name = (lead['name'] as String).toLowerCase();
            final email = (lead['email'] ?? '').toLowerCase();
            final phone = (lead['phone'] ?? '').toLowerCase();
            return name.contains(query) ||
                email.contains(query) ||
                phone.contains(query);
          }).toList();
    });
  }

  void _toggleMultiSelect(String leadId) {
    setState(() {
      if (_selectedLeads.contains(leadId)) {
        _selectedLeads.remove(leadId);
      } else {
        _selectedLeads.add(leadId);
      }
      _isMultiSelectMode = _selectedLeads.isNotEmpty;
    });
  }

  void _exitMultiSelectMode() {
    setState(() {
      _selectedLeads.clear();
      _isMultiSelectMode = false;
    });
  }

  void _showImportDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'ImportDialog',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return _ImportLeadsDialog();
      },
    );
  }

  void _showSendMessageDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'MessageDialog',
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: const Offset(0, 0),
          ).animate(anim1),
          child: child,
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return _MessageChannelDialog(
          isMultiSelect: _isMultiSelectMode,
          selectedCount: _selectedLeads.length,
        );
      },
    );
  }

  void _showMoveLeadsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _MoveLeadsDialog(
          currentGroupName: widget.groupName,
          selectedLeadsCount: _selectedLeads.length,
          otherGroups: _otherGroups,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar:
          _isMultiSelectMode
              ? _buildMultiSelectAppBar()
              : _buildDefaultAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search leads by name, email, or phone...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surfaceVariant.withOpacity(0.3),
                  ),
                ),
                if (_searchController.text.isNotEmpty &&
                    _filteredLeads.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'Showing results for: "${_searchController.text}"',
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        fontStyle: FontStyle.italic,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child:
                _filteredLeads.isEmpty
                    ? Center(
                      child: Text(
                        'No leads found.',
                        style: GoogleFonts.lato(
                          fontSize: 16.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    )
                    : ListView.separated(
                      itemCount: _filteredLeads.length,
                      itemBuilder: (context, index) {
                        final lead = _filteredLeads[index];
                        final isSelected = _selectedLeads.contains(lead['id']);
                        return _LeadListItem(
                          lead: lead,
                          isSelected: isSelected,
                          onTap: () => _toggleMultiSelect(lead['id'] as String),
                          onLongPress:
                              () => _toggleMultiSelect(lead['id'] as String),
                        );
                      },
                      separatorBuilder:
                          (context, index) => Divider(
                            height: 1.h,
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                          ),
                    ),
          ),
        ],
      ),
    );
  }

  AppBar _buildDefaultAppBar() {
    return AppBar(
      title: Text(
        '${widget.groupName} Leads',
        style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 20.sp),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.mail_outline),
          tooltip: 'Send message to all leads',
          onPressed: _showSendMessageDialog,
        ),
        IconButton(
          icon: const Icon(Icons.download),
          tooltip: 'Import leads',
          onPressed: _showImportDialog,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          tooltip: 'Add new lead',
          onPressed: () {
            // Add lead creation logic here
          },
        ),
      ],
    );
  }

  AppBar _buildMultiSelectAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _exitMultiSelectMode,
      ),
      title: Text('${_selectedLeads.length} Selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.mail),
          tooltip: 'Broadcast message',
          onPressed: _showSendMessageDialog,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: 'Delete selected leads',
          onPressed: () {
            // Add delete logic here
            _exitMultiSelectMode();
          },
        ),
        IconButton(
          icon: const Icon(Icons.drive_file_move_rounded),
          tooltip: 'Move selected leads',
          onPressed: _showMoveLeadsDialog,
        ),
      ],
    );
  }
}

class _LeadListItem extends StatelessWidget {
  final Map<String, dynamic> lead;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _LeadListItem({
    required this.lead,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color:
          isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            (lead['name'] as String).isNotEmpty ? lead['name'][0] : '?',
            style: GoogleFonts.lato(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          lead['name'] as String,
          style: GoogleFonts.lato(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lead['email'] != null)
              Text(
                lead['email'] as String,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            if (lead['phone'] != null)
              Text(
                lead['phone'] as String,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            SizedBox(height: 4.h),
            Text(
              'Created: ${_formatDate(lead['creationDate'] as DateTime)}',
              style: GoogleFonts.lato(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
          ],
        ),
        trailing:
            isSelected
                ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.sp,
                )
                : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _ImportLeadsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Smart Lead Import',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload,
                size: 80.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 24.h),
              Text(
                'AI-Powered Smart Import',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Our AI can handle all sorts of user databases and automatically map fields to your lead groups. Just upload your CSV file and let our technology do the rest.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 16.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onBackground.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 32.h),
              OutlinedButton.icon(
                onPressed: () {
                  // Add CSV upload logic here
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload CSV'),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(200.w, 50.h),
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageChannelDialog extends StatelessWidget {
  final bool isMultiSelect;
  final int selectedCount;

  const _MessageChannelDialog({
    required this.isMultiSelect,
    required this.selectedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          isMultiSelect
              ? 'Send Message to $selectedCount Leads'
              : 'Broadcast to All Leads',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Select a communication channel to broadcast your message.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Our smart broadcast feature allows you to reach your leads quickly and efficiently. Choose a channel below to proceed to the message composer.',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: Theme.of(
                  context,
                ).colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 24.h),
            _ChannelOption(
              icon: Icons.whatshot,
              title: 'WhatsApp',
              description: 'Send direct messages and rich media via WhatsApp.',
              onTap: () {
                // Handle WhatsApp tap
              },
            ),
            SizedBox(height: 16.h),
            _ChannelOption(
              icon: Icons.sms_outlined,
              title: 'SMS',
              description:
                  'Send traditional text messages for high deliverability.',
              onTap: () {
                // Handle SMS tap
              },
            ),
            SizedBox(height: 16.h),
            _ChannelOption(
              icon: Icons.email_outlined,
              title: 'Email',
              description:
                  'Send detailed messages with rich formatting and attachments.',
              onTap: () {
                // Handle Email tap
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ChannelOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ChannelOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: GoogleFonts.lato(
                        fontSize: 14.sp,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoveLeadsDialog extends StatefulWidget {
  final String currentGroupName;
  final int selectedLeadsCount;
  final List<Map<String, dynamic>> otherGroups;

  const _MoveLeadsDialog({
    required this.currentGroupName,
    required this.selectedLeadsCount,
    required this.otherGroups,
  });

  @override
  _MoveLeadsDialogState createState() => _MoveLeadsDialogState();
}

class _MoveLeadsDialogState extends State<_MoveLeadsDialog> {
  String? _selectedGroupName;
  late final List<String> _groupNames;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _groupNames = widget.otherGroups.map((e) => e['name'] as String).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
      title: Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.drive_file_move_rounded,
              size: 40.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 8.h),
            Text(
              'Move ${widget.selectedLeadsCount} Leads',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 20.sp,
              ),
            ),
            Text(
              'from "${widget.currentGroupName}"',
              style: GoogleFonts.lato(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a destination group:',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 12.h),
            _buildGroupSelectionInput(context),
            if (_selectedGroupName != null)
              Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Colors.green),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Selected: $_selectedGroupName',
                        style: GoogleFonts.lato(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.lato(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        FilledButton(
          onPressed:
              _selectedGroupName == null
                  ? null
                  : () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${widget.selectedLeadsCount} leads moved to "$_selectedGroupName".',
                        ),
                      ),
                    );
                  },
          child: const Text('Move'),
        ),
      ],
    );
  }

  Widget _buildGroupSelectionInput(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        return _groupNames.where((String option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (String selection) {
        setState(() {
          _selectedGroupName = selection;
        });
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Search for a group',
            hintText: 'e.g., "Marketing Leads"',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceVariant.withOpacity(0.3),
          ),
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<String> onSelected,
        Iterable<String> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: SizedBox(
              width: 250.w,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final String option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      child: Text(option),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
