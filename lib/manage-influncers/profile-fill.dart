import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

// --- Model for Country Data ---
class Country {
  final String name;
  final String code;
  final String flag;
  Country({required this.name, required this.code, required this.flag});
}

class CreateInfluencerProfileScreen extends StatefulWidget {
  const CreateInfluencerProfileScreen({super.key});

  @override
  State<CreateInfluencerProfileScreen> createState() =>
      _CreateInfluencerProfileScreenState();
}

class _CreateInfluencerProfileScreenState
    extends State<CreateInfluencerProfileScreen> {
  // --- Controllers ---
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<TextEditingController> _linkControllers = [
    TextEditingController(),
  ];

  // --- Form State ---
  File? _profileImage;
  bool _isAlive = true;
  DateTime? _dob;
  DateTime? _dod;
  String? _selectedGender;
  String? _selectedDomain;
  String? _selectedSubDomain;

  // Default Country Selection
  Country _selectedCountry = Country(name: "India", code: "+91", flag: "🇮🇳");

  // --- Data Sets ---
  final List<Country> _countries = [
    Country(name: "United States", code: "+1", flag: "🇺🇸"),
    Country(name: "United Kingdom", code: "+44", flag: "🇬🇧"),
    Country(name: "India", code: "+91", flag: "🇮🇳"),
    Country(name: "United Arab Emirates", code: "+971", flag: "🇦🇪"),
    Country(name: "Australia", code: "+61", flag: "🇦🇺"),
    Country(name: "Japan", code: "+81", flag: "🇯🇵"),
    Country(name: "Germany", code: "+49", flag: "🇩🇪"),
    Country(name: "Canada", code: "+1", flag: "🇨🇦"),
  ];

  final List<Map<String, dynamic>> _genders = [
    {"name": "Male", "icon": Icons.male_rounded},
    {"name": "Female", "icon": Icons.female_rounded},
    {"name": "Other", "icon": Icons.horizontal_rule_rounded},
  ];

  final Map<String, Map<String, dynamic>> _domainData = {
    "Technology": {
      "icon": Icons.biotech_rounded,
      "subs": ["Software", "AI", "Gadgets", "Cybersecurity"],
    },
    "Lifestyle": {
      "icon": Icons.auto_awesome_rounded,
      "subs": ["Fashion", "Travel", "Wellness", "Design"],
    },
    "Finance": {
      "icon": Icons.payments_rounded,
      "subs": ["Crypto", "Stock Market", "Personal Finance"],
    },
  };

  // --- Image Picker Logic ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => _profileImage = File(image.path));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    for (var c in _linkControllers) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 40.h),
          children: [
            _buildProfilePicPicker(colorScheme),
            SizedBox(height: 32.h),

            _buildSectionTitle("Identity"),
            _buildTextField(
              label: "Full Name",
              controller: _nameController,
              icon: Icons.badge_outlined,
              hint: "Enter legal name",
              colorScheme: colorScheme,
            ),
            _buildSelectorTile(
              label: "Gender",
              value: _selectedGender,
              onTap:
                  () => _openSearchSheet(
                    "Gender",
                    _genders,
                    (val) => setState(() => _selectedGender = val),
                  ),
              icon: Icons.face_retouching_natural_rounded,
              colorScheme: colorScheme,
            ),

            SizedBox(height: 24.h),
            _buildSectionTitle("Vital Status"),
            _buildStatusSwitch(colorScheme),
            Row(
              children: [
                Expanded(
                  child: _buildDateTile(
                    "Date of Birth",
                    _dob,
                    (date) => setState(() => _dob = date),
                    colorScheme,
                  ),
                ),
                if (!_isAlive) ...[
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildDateTile(
                      "Date of Death",
                      _dod,
                      (date) => setState(() => _dod = date),
                      colorScheme,
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: 24.h),
            _buildSectionTitle("Professional Niche"),
            _buildSelectorTile(
              label: "Domain",
              value: _selectedDomain,
              onTap:
                  () => _openSearchSheet(
                    "Domain",
                    _domainData.keys
                        .map(
                          (k) => {"name": k, "icon": _domainData[k]!['icon']},
                        )
                        .toList(),
                    (val) {
                      setState(() {
                        _selectedDomain = val;
                        _selectedSubDomain = null;
                      });
                    },
                  ),
              icon: Icons.category_outlined,
              colorScheme: colorScheme,
            ),
            _buildSelectorTile(
              label: "Sub Domain",
              value: _selectedSubDomain,
              onTap:
                  _selectedDomain == null
                      ? null
                      : () => _openSearchSheet(
                        "Sub Domain",
                        _domainData[_selectedDomain]!['subs']
                            .map(
                              (s) => {
                                "name": s,
                                "icon": Icons.subdirectory_arrow_right_rounded,
                              },
                            )
                            .toList(),
                        (val) => setState(() => _selectedSubDomain = val),
                      ),
              hint:
                  _selectedDomain == null
                      ? "Select domain first"
                      : "Select niche",
              icon: Icons.layers_outlined,
              colorScheme: colorScheme,
            ),

            SizedBox(height: 24.h),
            _buildSectionTitle("Contact Details"),
            _buildTextField(
              label: "Email Address (Optional)",
              controller: _emailController,
              icon: Icons.alternate_email_rounded,
              hint: "name@domain.com",
              colorScheme: colorScheme,
            ),
            _buildPhoneInput(colorScheme),

            SizedBox(height: 24.h),
            _buildSectionTitle("Biography"),
            _buildTextField(
              label: "About the Influencer",
              controller: _bioController,
              icon: Icons.description_outlined,
              hint: "Write a summary...",
              isMultiline: true,
              colorScheme: colorScheme,
            ),

            _buildLinksSection(colorScheme),

            SizedBox(height: 48.h),
            _buildSubmitButton(colorScheme),
          ],
        ),
      ),
    );
  }

  // --- Specialized Builders ---

  Widget _buildProfilePicPicker(ColorScheme colorScheme) {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                color: colorScheme.onSurface.withOpacity(0.02),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.3),
                  width: 1.5,
                ),
                image:
                    _profileImage != null
                        ? DecorationImage(
                          image: FileImage(_profileImage!),
                          fit: BoxFit.cover,
                        )
                        : null,
              ),
              child:
                  _profileImage == null
                      ? Icon(
                        Icons.person_outline_rounded,
                        size: 48.sp,
                        color: Colors.grey[400],
                      )
                      : null,
            ),
            Positioned(
              bottom: 4.h,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneInput(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel("Mobile Number (Optional)"),
        SizedBox(height: 8.h),
        Row(
          children: [
            InkWell(
              onTap: _openCountryPicker,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.h),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _selectedCountry.flag,
                      style: TextStyle(fontSize: 18.sp),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _selectedCountry.code,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.w800,
                        fontSize: 14.sp,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 18.sp,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.lato(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: "Phone number",
                  filled: true,
                  fillColor: colorScheme.onSurface.withOpacity(0.02),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  contentPadding: EdgeInsets.all(16.w),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  void _openCountryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _GenericSearchSheet(
            title: "Country",
            options:
                _countries
                    .map(
                      (c) => {"name": c.name, "code": c.code, "flag": c.flag},
                    )
                    .toList(),
            onSelect: (val) {
              setState(
                () =>
                    _selectedCountry = _countries.firstWhere(
                      (c) => c.name == val,
                    ),
              );
            },
          ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required ColorScheme colorScheme,
    String? hint,
    bool isMultiline = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          maxLines: isMultiline ? null : 1,
          minLines: isMultiline ? 3 : 1,
          style: GoogleFonts.lato(fontSize: 14.sp, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20.sp,
              color: colorScheme.primary.withOpacity(0.7),
            ),
            hintText: hint,
            filled: true,
            fillColor: colorScheme.onSurface.withOpacity(0.02),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildSelectorTile({
    required String label,
    required String? value,
    required VoidCallback? onTap,
    required IconData icon,
    required ColorScheme colorScheme,
    String hint = "Select",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20.sp,
                  color: colorScheme.primary.withOpacity(0.7),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: GoogleFonts.lato(
                      fontSize: 14.sp,
                      color:
                          value == null
                              ? colorScheme.onSurfaceVariant.withOpacity(0.4)
                              : colorScheme.onSurface,
                      fontWeight:
                          value == null ? FontWeight.normal : FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.unfold_more_rounded,
                  size: 18.sp,
                  color: colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildDateTile(
    String label,
    DateTime? value,
    Function(DateTime) onPicked,
    ColorScheme colorScheme,
  ) => _buildSelectorTile(
    label: label,
    value: value != null ? DateFormat('MMM dd, yyyy').format(value) : null,
    onTap: () async {
      final date = await showDatePicker(
        context: context,
        initialDate: DateTime(1995),
        firstDate: DateTime(1850),
        lastDate: DateTime.now(),
      );
      if (date != null) onPicked(date);
    },
    icon: Icons.calendar_today_rounded,
    colorScheme: colorScheme,
  );

  Widget _buildLinksSection(ColorScheme colorScheme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildSectionTitle("Social & Website Links"),
          TextButton.icon(
            onPressed:
                () => setState(
                  () => _linkControllers.add(TextEditingController()),
                ),
            icon: const Icon(Icons.add_link_rounded, size: 18),
            label: Text(
              "Add Link",
              style: GoogleFonts.lato(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
      ..._linkControllers.asMap().entries.map(
        (e) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: e.value,
                  decoration: InputDecoration(
                    hintText: "https://...",
                    filled: true,
                    fillColor: colorScheme.onSurface.withOpacity(0.02),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    contentPadding: EdgeInsets.all(12.w),
                  ),
                ),
              ),
              if (_linkControllers.length > 1)
                IconButton(
                  onPressed:
                      () => setState(() => _linkControllers.removeAt(e.key)),
                  icon: Icon(Icons.cancel_outlined, color: Colors.red[300]),
                ),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildStatusSwitch(ColorScheme colorScheme) => Container(
    margin: EdgeInsets.only(bottom: 16.h),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: colorScheme.onSurface.withOpacity(0.02),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Is the influencer alive?",
          style: GoogleFonts.lato(fontSize: 14.sp, fontWeight: FontWeight.w700),
        ),
        Switch(
          value: _isAlive,
          onChanged: (v) => setState(() => _isAlive = v),
          activeColor: colorScheme.primary,
        ),
      ],
    ),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
    child: Text(
      title.toUpperCase(),
      style: GoogleFonts.lato(
        fontSize: 11.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
  Widget _buildFieldLabel(String text) => Text(
    text,
    style: GoogleFonts.lato(
      fontSize: 12.sp,
      fontWeight: FontWeight.w800,
      color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
    ),
  );

  PreferredSizeWidget _buildAppBar(BuildContext context) => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new, size: 18.sp),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      "INFLUENCER PROFILE",
      style: GoogleFonts.lato(
        fontSize: 13.sp,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
    ),
    centerTitle: true,
  );

  Widget _buildSubmitButton(ColorScheme colorScheme) => SizedBox(
    width: double.infinity,
    height: 56.h,
    child: ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        elevation: 0,
      ),
      child: Text(
        "Register Influencer",
        style: GoogleFonts.lato(fontSize: 16.sp, fontWeight: FontWeight.w900),
      ),
    ),
  );

  void _openSearchSheet(
    String title,
    List<dynamic> options,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _GenericSearchSheet(
            title: title,
            options: options,
            onSelect: onSelect,
          ),
    );
  }
}

// --- Generic Search Sheet with Upgraded Icon/Flag Logic ---
class _GenericSearchSheet extends StatefulWidget {
  final String title;
  final List<dynamic> options;
  final Function(String) onSelect;
  const _GenericSearchSheet({
    required this.title,
    required this.options,
    required this.onSelect,
  });
  @override
  State<_GenericSearchSheet> createState() => _GenericSearchSheetState();
}

class _GenericSearchSheetState extends State<_GenericSearchSheet> {
  late List<dynamic> filtered;
  @override
  void initState() {
    super.initState();
    filtered = widget.options;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 0.75.sh,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Select ${widget.title}",
                  style: GoogleFonts.lato(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: TextField(
              onChanged:
                  (val) => setState(
                    () =>
                        filtered =
                            widget.options.where((e) {
                              final name =
                                  (e is Map) ? e['name'] : e.toString();
                              final code =
                                  (e is Map && e.containsKey('code'))
                                      ? e['code']
                                      : "";
                              return name.toLowerCase().contains(
                                    val.toLowerCase(),
                                  ) ||
                                  code.contains(val);
                            }).toList(),
                  ),
              decoration: InputDecoration(
                hintText: "Search items...",
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final String name =
                    (item is Map) ? item['name'] : item.toString();

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 4.h,
                  ),
                  leading:
                      (item is Map && item.containsKey('flag'))
                          ? Text(
                            item['flag'],
                            style: TextStyle(fontSize: 24.sp),
                          )
                          : (item is Map && item.containsKey('icon'))
                          ? Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(
                                0.05,
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              item['icon'],
                              color: theme.colorScheme.primary,
                              size: 20.sp,
                            ),
                          )
                          : null,
                  title: Text(
                    name,
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w700,
                      fontSize: 15.sp,
                    ),
                  ),
                  trailing:
                      (item is Map && item.containsKey('code'))
                          ? Text(
                            item['code'],
                            style: GoogleFonts.lato(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          )
                          : Icon(
                            Icons.chevron_right_rounded,
                            size: 18.sp,
                            color: theme.colorScheme.outline,
                          ),
                  onTap: () {
                    widget.onSelect(name);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
