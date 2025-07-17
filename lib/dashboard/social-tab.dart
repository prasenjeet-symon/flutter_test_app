import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SocialTab {
  static final List<Map<String, String>> childRoutes = [
    {'routeId': '1', 'name': 'Post Details', 'route': '/social/post', 'id': '3'},
    {'routeId': '2', 'name': 'Messages', 'route': '/social/messages', 'id': '3'},
  ];

  static Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/social':
        return GetPageRoute(settings: settings, page: () => const SocialScreen());
      case '/social/post':
        return GetPageRoute(settings: settings, page: () => const PostScreen(), transition: Transition.zoom);
      case '/social/messages':
        return GetPageRoute(settings: settings, page: () => const MessagesScreen(), transition: Transition.zoom);
      default:
        return null;
    }
  }
}

class SocialScreen extends StatelessWidget {
  const SocialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Social')), body: Center(child: Text('Social Home', style: TextStyle(fontSize: 20.sp))));
  }
}

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Post Details')), body: Center(child: ElevatedButton(onPressed: () => Get.back(id: 3), child: const Text('Back to Social Home'))));
  }
}

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Messages')), body: Center(child: ElevatedButton(onPressed: () => Get.back(id: 3), child: const Text('Back to Social Home'))));
  }
}
