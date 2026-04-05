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
      backgroundColor: Colors.transparent,
      appBar: appBar,
      drawer: drawer,
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              'assets/lottie/Background_shooting_star.json',
              fit: BoxFit.cover,
              repeat: true,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          body,
        ],
      ),
    );
  }
}

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Lottie.asset(
            'assets/lottie/Background_shooting_star.json',
            fit: BoxFit.cover,
            repeat: true,
          ),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: 0.4),
          ),
        ),
        child,
      ],
    );
  }
}
