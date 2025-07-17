import 'package:flutter/material.dart';
import 'package:flutter_test_app/dashboard/marketplace-tab.dart';
import 'package:flutter_test_app/dashboard/org-tab.dart';
import 'package:flutter_test_app/dashboard/social-tab.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(onTap: () => scaffoldKey.currentState?.openDrawer(), child: CircleAvatar(radius: 20.r, backgroundImage: const NetworkImage('https://picsum.photos/200'))),
        actions: [
          IconButton(icon: const Icon(Icons.live_tv_rounded), onPressed: () => Get.snackbar('Broadcast', 'Broadcast feature tapped')),
          IconButton(icon: const Icon(Icons.video_call_rounded), onPressed: () => Get.snackbar('Video Call', 'Video call feature tapped')),
          IconButton(icon: const Icon(Icons.chat_bubble_outline), onPressed: () => Get.snackbar('Chat', 'Chat feature tapped')),
          Obx(
            () => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {
                    controller.clearNotifications();
                    Get.snackbar('Notifications', 'Notifications cleared');
                  },
                ),
                if (controller.notificationCount.value > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      child: Text('${controller.notificationCount.value}', style: TextStyle(color: Colors.white, fontSize: 12.sp)),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
        ],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.grey[100]!, Colors.white])),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer Header with Gradient Background
              Container(
                padding: const EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.7)]),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Profile Picture with Shadow
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                            image: const DecorationImage(
                              image: NetworkImage('https://via.placeholder.com/80'), // Placeholder image
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Name and Username
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('John Doe', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600, fontFamily: 'Roboto')),
                              const SizedBox(height: 6),
                              Text('@johndoe', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, fontFamily: 'Roboto')),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Profile Action Button with Animation
                    GestureDetector(
                      onTap: () => Get.toNamed('/profile'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [const Icon(Icons.person, color: Colors.white, size: 20), const SizedBox(width: 8), Text('View Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Expandable Sections with Icons
              _buildExpansionTile(context, title: 'Dashboard', icon: Icons.dashboard, items: [_buildListTile(context, 'Overview', Icons.dashboard, () => Get.back()), _buildListTile(context, 'Statistics', Icons.bar_chart, () => Get.back())]),
              _buildExpansionTile(context, title: 'Settings', icon: Icons.settings, items: [_buildListTile(context, 'Account', Icons.account_circle, () => Get.back()), _buildListTile(context, 'Preferences', Icons.tune, () => Get.back())]),
              const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
              // Logout Button with Icon
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: GestureDetector(
                  onTap: () => Get.offAllNamed('/login'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.red, Colors.redAccent]), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [Icon(Icons.logout, size: 24, color: Colors.white), const SizedBox(width: 16), const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500))]),
                  ),
                ),
              ),
              // Application Version
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), child: Text('Version 1.0.0', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600], fontSize: 14, fontFamily: 'Roboto'))),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Obx(
            () => IndexedStack(
              index: controller.selectedIndex.value,
              children: [
                Navigator(key: Get.nestedKey(1), initialRoute: '/orgs', onGenerateRoute: OrgsTab.onGenerateRoute),
                Navigator(key: Get.nestedKey(2), initialRoute: '/marketplace', onGenerateRoute: MarketPlaceTab.onGenerateRoute),
                Navigator(key: Get.nestedKey(3), initialRoute: '/social', onGenerateRoute: SocialTab.onGenerateRoute),
              ],
            ),
          ),
          Positioned(
            bottom: 0.h,
            left: 0,
            right: 0,
            child: Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: controller.isExpanded.value ? 50.h : 0.h,
                color: Theme.of(context).scaffoldBackgroundColor,
                child:
                    controller.isExpanded.value
                        ? Container(
                          decoration: BoxDecoration(border: Border.all(width: 1.5.w, color: Theme.of(context).primaryColor), borderRadius: BorderRadius.circular(100.r)),
                          margin: EdgeInsets.only(left: 5.w, right: 5.w, bottom: 1.h),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                            child: Row(
                              children:
                                  controller.getChildRoutes().map((route) {
                                    return Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                                      child: ActionChip(
                                        backgroundColor: controller.currentChildId.value == int.parse(route['routeId']!) ? Theme.of(context).primaryColor : Theme.of(context).scaffoldBackgroundColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
                                        side: BorderSide(color: controller.currentChildId.value == int.parse(route['routeId']!) ? Theme.of(context).primaryColor : Theme.of(context).primaryColor),
                                        labelStyle: TextStyle(color: controller.currentChildId.value == int.parse(route['routeId']!) ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).primaryColor),
                                        label: Text(route['name']!, style: TextStyle(fontSize: 12.sp)),
                                        onPressed: () {
                                          controller.selectChildRoute(route['route']!, route['id']!, route['routeId']!);
                                        },
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        )
                        : const SizedBox.shrink(),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: (index) => controller.toggleTab(index),
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(icon: const Icon(Icons.business), label: 'Orgs', activeIcon: Icon(Icons.business, color: Theme.of(context).primaryColor)),
            BottomNavigationBarItem(icon: const Icon(Icons.store), label: 'Market Place', activeIcon: Icon(Icons.store, color: Theme.of(context).primaryColor)),
            BottomNavigationBarItem(icon: const Icon(Icons.group), label: 'Social', activeIcon: Icon(Icons.group, color: Theme.of(context).primaryColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(BuildContext context, {required String title, required IconData icon, required List<Widget> items}) {
    return ExpansionTile(
      leading: Icon(icon, size: 24, color: Theme.of(context).primaryColor),
      title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, fontFamily: 'Roboto')),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      children: items,
      backgroundColor: Theme.of(context).cardColor,
      shape: const Border(), // Remove border when expanded
      collapsedShape: const Border(), // Ensure no border when collapsed
    );
  }

  Widget _buildListTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(leading: Icon(icon, size: 20, color: Theme.of(context).primaryColor), title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, fontFamily: 'Roboto')), onTap: onTap);
  }
}

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  var notificationCount = 3.obs;
  var isExpanded = false.obs;
  var currentTabId = 1.obs;
  var currentChildId = 1.obs;

  final Map<int, Map<String, dynamic>> tabConfig = {
    0: {'id': 1, 'children': OrgsTab.childRoutes},
    1: {'id': 2, 'children': MarketPlaceTab.childRoutes},
    2: {'id': 3, 'children': SocialTab.childRoutes},
  };

  void toggleTab(int index) {
    if (selectedIndex.value == index && isExpanded.value) {
      isExpanded.value = false;
    } else {
      selectedIndex.value = index;
      isExpanded.value = true;

      // Safely access tabConfig
      final tab = tabConfig[index];
      if (tab == null) {
        print('Error: tabConfig[$index] is null');
        return;
      }

      // Handle 'id'
      final tabId = tab['id'];
      if (tabId is String) {
        currentTabId.value = int.tryParse(tabId) ?? 0; // Fallback to 0 if parsing fails
      } else if (tabId is int) {
        currentTabId.value = tabId; // Already an int
      } else {
        print('Error: tabConfig[$index]["id"] is of type ${tabId.runtimeType}, expected String or int');
        currentTabId.value = 0; // Fallback
      }

      // Handle 'children' and 'routeId'
      final children = tab['children'] as List<dynamic>?;
      if (children == null || children.isEmpty) {
        print('Error: tabConfig[$index]["children"] is null or empty');
        currentChildId.value = 0; // Fallback
        return;
      }

      final childRouteId = children[0]['routeId'];
      if (childRouteId is String) {
        currentChildId.value = int.tryParse(childRouteId) ?? 0; // Fallback to 0 if parsing fails
      } else if (childRouteId is int) {
        currentChildId.value = childRouteId; // Already an int
      } else {
        print('Error: tabConfig[$index]["children"][0]["routeId"] is of type ${childRouteId.runtimeType}, expected String or int');
        currentChildId.value = 0; // Fallback
      }
    }
  }

  List<Map<String, String>> getChildRoutes() {
    final config = tabConfig[selectedIndex.value];
    if (config == null || config['children'] == null) {
      return []; // Return empty list to avoid null issues
    }
    return config['children'] as List<Map<String, String>>;
  }

  void selectChildRoute(String route, String idString, String routeId) {
    print('Selected Child Route: $route, ID: $idString, Route ID: $routeId');
    isExpanded.value = false;
    final id = int.parse(idString); // Convert string ID to int
    final routeIdInt = int.parse(routeId);
    currentChildId.value = routeIdInt;
    Get.toNamed(route, id: id); // Push child route onto the stack
  }

  void clearNotifications() {
    notificationCount.value = 0;
  }
}
