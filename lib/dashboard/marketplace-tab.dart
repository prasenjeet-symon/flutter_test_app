import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MarketPlaceTab {
  static final List<Map<String, String>> childRoutes = [
    {'routeId': '12', 'name': 'Product Details', 'route': '/marketplace/product', 'id': '2'},
    {'routeId': '13', 'name': 'Cart', 'route': '/marketplace/cart', 'id': '2'},
  ];

  static Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/marketplace':
        return GetPageRoute(settings: settings, page: () => const MarketPlaceScreen());
      case '/marketplace/product':
        return GetPageRoute(settings: settings, page: () => const ProductScreen(), transition: Transition.rightToLeft);
      case '/marketplace/cart':
        return GetPageRoute(settings: settings, page: () => const CartScreen(), transition: Transition.rightToLeft);
      default:
        return null;
    }
  }
}

class MarketPlaceScreen extends StatelessWidget {
  const MarketPlaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Market Place')), body: Center(child: Text('Market Place Home', style: TextStyle(fontSize: 20.sp))));
  }
}

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Product Details')), body: Center(child: ElevatedButton(onPressed: () => Get.back(id: 2), child: const Text('Back to Market Place Home'))));
  }
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Cart')), body: Center(child: ElevatedButton(onPressed: () => Get.back(id: 2), child: const Text('Back to Market Place Home'))));
  }
}
