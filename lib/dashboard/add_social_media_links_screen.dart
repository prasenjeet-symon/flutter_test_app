import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uuid/uuid.dart'; // Make sure you've added this to your pubspec.yaml

// Data Model for a Social Media Link (remains unchanged)
class SocialMediaLink {
  String id;
  String platform;
  String url;
  String? customPlatformName;

  SocialMediaLink({String? id, required this.platform, required this.url, this.customPlatformName}) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {'id': id, 'platform': platform, 'url': url, 'customPlatformName': customPlatformName};

  factory SocialMediaLink.fromJson(Map<String, dynamic> json) => SocialMediaLink(id: json['id'], platform: json['platform'], url: json['url'], customPlatformName: json['customPlatformName']);
}

class AddSocialMediaLinksScreen extends StatefulWidget {
  final List<SocialMediaLink>? initialLinks;

  const AddSocialMediaLinksScreen({Key? key, this.initialLinks}) : super(key: key);

  @override
  State<AddSocialMediaLinksScreen> createState() => _AddSocialMediaLinksScreenState();
}

class _AddSocialMediaLinksScreenState extends State<AddSocialMediaLinksScreen> {
  late List<SocialMediaLink> _links;
  final _formKey = GlobalKey<FormState>();

  final List<String> _commonPlatforms = ['Facebook', 'Twitter (X)', 'Instagram', 'LinkedIn', 'YouTube', 'TikTok', 'Pinterest', 'Snapchat', 'Reddit', 'GitHub', 'Website', 'Custom'];

  @override
  void initState() {
    super.initState();
    _links = widget.initialLinks != null ? List<SocialMediaLink>.from(widget.initialLinks!) : [];

    if (_links.isEmpty) {
      _addLink();
    }
  }

  void _addLink() {
    setState(() {
      _links.add(SocialMediaLink(platform: _commonPlatforms[0], url: ''));
    });
  }

  void _removeLink(String id) {
    setState(() {
      _links.removeWhere((link) => link.id == id);
      if (_links.isEmpty) {
        _addLink();
      }
    });
  }

  void _saveLinks() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      List<SocialMediaLink> validLinks = _links.where((link) => link.url.trim().isNotEmpty).toList();

      print('--- Saved Social Media Links ---');
      for (var link in validLinks) {
        print('ID: ${link.id}, Platform: ${link.platform}' + (link.customPlatformName != null ? ' (${link.customPlatformName})' : '') + ', URL: ${link.url}');
      }
      print('------------------------------');

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Social media links saved successfully!'), backgroundColor: Theme.of(context).colorScheme.primary, duration: const Duration(seconds: 2)));

      Navigator.of(context).pop(validLinks);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please correct the errors in the form.'), backgroundColor: Theme.of(context).colorScheme.error, duration: const Duration(seconds: 2)));
    }
  }

  String? _urlValidator(String? value, String platform) {
    if (value == null || value.trim().isEmpty) {
      if (platform == 'Custom') {
        return 'Link or handle cannot be empty';
      }
      return 'URL cannot be empty';
    }
    if (platform != 'Custom' && !value.startsWith('http://') && !value.startsWith('https://')) {
      return 'Please enter a valid URL (start with http:// or https://)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Social Links', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 24.sp, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [IconButton(icon: Icon(Icons.check, size: 24.sp, color: Theme.of(context).colorScheme.primary), onPressed: _saveLinks, tooltip: 'Save Links')],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Tutorial Description - Adjust horizontal padding for wider content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h), // Reduced horizontal padding
                child: Text(
                  'Add your social media profiles and personal website links. Your followers can easily connect with you there.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  // Reduced horizontal padding for list items
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h), // Reduced vertical padding here too
                  itemCount: _links.length,
                  itemBuilder: (context, index) {
                    final link = _links[index];
                    return Padding(
                      // Reduced padding between cards
                      padding: EdgeInsets.only(bottom: 8.h), // Was 16.h
                      child: Card(
                        key: ValueKey(link.id),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)), // Slightly smaller radius
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        child: Padding(
                          // Reduced internal card padding
                          padding: EdgeInsets.all(12.w), // Was 16.w
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: link.platform,
                                      decoration: InputDecoration(
                                        labelText: 'Platform',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                        // Made contentPadding more compact
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                      ),
                                      isDense: true, // Makes the dropdown button itself more compact vertically
                                      items:
                                          _commonPlatforms.map((String platform) {
                                            return DropdownMenuItem<String>(
                                              value: platform,
                                              child: Text(platform, style: TextStyle(fontSize: 14.sp)), // Adjust font size for compactness
                                            );
                                          }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          setState(() {
                                            link.platform = newValue;
                                            if (newValue != 'Custom') {
                                              link.customPlatformName = null;
                                            }
                                          });
                                        }
                                      },
                                      onSaved: (newValue) => link.platform = newValue ?? '',
                                      validator: (value) => value == null || value.isEmpty ? 'Please select a platform' : null,
                                    ),
                                  ),
                                  if (_links.length > 1)
                                    IconButton(
                                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error, size: 22.sp), // Slightly smaller icon
                                      onPressed: () => _removeLink(link.id),
                                      tooltip: 'Remove Link',
                                    ),
                                ],
                              ),
                              // Reduced SizedBox height
                              SizedBox(height: 10.h), // Was 12.h
                              if (link.platform == 'Custom')
                                Column(
                                  children: [
                                    TextFormField(
                                      initialValue: link.customPlatformName,
                                      decoration: InputDecoration(
                                        labelText: 'Custom Platform Name',
                                        hintText: 'e.g., My Blog, Portfolio',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                        // Made contentPadding more compact
                                        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                      ),
                                      onChanged: (value) => link.customPlatformName = value,
                                      onSaved: (value) => link.customPlatformName = value,
                                      validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a name for your custom platform' : null,
                                    ),
                                    // Reduced SizedBox height
                                    SizedBox(height: 10.h), // Was 12.h
                                  ],
                                ),
                              TextFormField(
                                initialValue: link.url,
                                keyboardType: TextInputType.url,
                                decoration: InputDecoration(
                                  labelText: link.platform == 'Website' ? 'Website URL' : (link.platform == 'Custom' ? 'Link/Handle' : '${link.platform} URL/Username'),
                                  hintText: link.platform == 'Website' ? 'https://yourwebsite.com' : 'https://www.facebook.com/yourprofile',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                  // Made contentPadding more compact
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                ),
                                onChanged: (value) => link.url = value,
                                onSaved: (value) => link.url = value ?? '',
                                validator: (value) => _urlValidator(value, link.platform),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLink,
        child: Icon(Icons.add, size: 28.sp),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        tooltip: 'Add new social link',
      ),
    );
  }
}
