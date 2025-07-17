import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

class AwsImageCommonWidget extends StatefulWidget {
  final String imageKey;
  final double radius;

  const AwsImageCommonWidget({super.key, required this.imageKey, this.radius = 15.0});

  @override
  State<AwsImageCommonWidget> createState() => _AwsImageCommonWidgetState();
}

class _AwsImageCommonWidgetState extends State<AwsImageCommonWidget> {
  final ValueNotifier<String?> imageUrlNotifier = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    if (widget.imageKey.isNotEmpty) {
      if (widget.imageKey.startsWith('http') || widget.imageKey.startsWith('https')) {
        imageUrlNotifier.value = widget.imageKey;
        isLoading.value = false;
      } else {
        _loadImageUrl();
      }
    } else {
      imageUrlNotifier.value = '';
      isLoading.value = false;
    }
  }

  Future<void> _loadImageUrl() async {
    try {
      if (mounted) isLoading.value = true;

      final HttpClient orbitHttp = HttpClient();
      final Map<String, String> queryParam = {'key': widget.imageKey};
      final String url = "";

      final request = await orbitHttp.getUrl(Uri.parse(url));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        imageUrlNotifier.value = data['data'] ?? '';
      } else {
        imageUrlNotifier.value = '';
      }
    } catch (e) {
      if (!mounted) return;
      imageUrlNotifier.value = '';
    } finally {
      if (mounted) isLoading.value = false;
    }
  }

  @override
  void dispose() {
    imageUrlNotifier.dispose();
    isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double avatarRadius = widget.radius;

    return ValueListenableBuilder<bool>(
      valueListenable: isLoading,
      builder: (context, loading, _) {
        if (loading) {
          return _buildShimmer(avatarRadius);
        }

        return ValueListenableBuilder<String?>(
          valueListenable: imageUrlNotifier,
          builder: (context, imageUrl, _) {
            if (imageUrl?.isNotEmpty ?? false) {
              return _buildNetworkImage(avatarRadius, imageUrl!);
            } else {
              return _buildDefaultImage(avatarRadius);
            }
          },
        );
      },
    );
  }

  Widget _buildShimmer(double radius) {
    return Shimmer.fromColors(baseColor: Colors.grey[300]!, highlightColor: Colors.grey[100]!, child: CircleAvatar(radius: radius, backgroundColor: Colors.grey[300]));
  }

  Widget _buildNetworkImage(double radius, String imageUrl) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      child: ClipOval(child: CachedNetworkImage(cacheKey: widget.imageKey, imageUrl: imageUrl, width: radius * 2.w, height: radius * 2.h, fit: BoxFit.cover, errorWidget: (context, url, error) => _buildDefaultImage(radius))),
    );
  }

  Widget _buildDefaultImage(double radius) {
    return CircleAvatar(radius: radius, backgroundColor: Colors.grey[200], child: ClipOval(child: Icon(Icons.person, size: radius * 2.r, color: Colors.grey[400])));
  }
}
