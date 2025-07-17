import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Theme.of(context).platform == TargetPlatform.iOS ? const CupertinoActivityIndicator(radius: 20.0) : const CircularProgressIndicator()));
  }
}
