import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrgsTab {
  static final List<Map<String, String>> childRoutes = [
    {'routeId': '1', 'name': 'Org Details', 'route': '/orgs/details', 'id': '1'},
    {'routeId': '2', 'name': 'Org Settings', 'route': '/orgs/settings', 'id': '1'},
  ];

  static Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/orgs':
        return GetPageRoute(settings: settings, page: () => const OrgsScreen());
      case '/orgs/details':
        return GetPageRoute(settings: settings, page: () => const OrgsDetailsScreen(), transition: Transition.fadeIn);
      case '/orgs/settings':
        return GetPageRoute(settings: settings, page: () => const OrgsSettingsScreen(), transition: Transition.fadeIn);
      default:
        return null;
    }
  }
}

class OrgsScreen extends StatelessWidget {
  const OrgsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Organizations')), body: Center(child: Text('Orgs Home', style: TextStyle(fontSize: 20.sp))));
  }
}

class OrgsDetailsScreen extends StatelessWidget {
  const OrgsDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Org Details')), body: Center(child: ElevatedButton(onPressed: () => Get.back(id: 1), child: const Text('Back to Orgs Home'))));
  }
}

class OrgsSettingsScreen extends StatelessWidget {
  const OrgsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Org Settings')), body: Center(child: ElevatedButton(onPressed: () => Get.back(id: 1), child: const Text('Back to Orgs Home'))));
  }
}
