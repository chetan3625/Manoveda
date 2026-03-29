import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final AppBar? appBar;
  final Widget? drawer;
  final Color? backgroundColor;

  const AppScaffold({
    Key? key,
    required this.body,
    this.appBar,
    this.drawer,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? const Color(0xFF0F172A),
      appBar: appBar,
      drawer: drawer,
      body: Stack(
        children: [
          Lottie.asset(
            'assets/lottie/Background_shooting_star.json',
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
            
          ),
          body,
        ],
      ),
    );
  }
}
