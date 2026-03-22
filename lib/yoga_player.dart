import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class YogaPlayer extends StatefulWidget {
  final int exerciseIndex;

  const YogaPlayer({super.key, required this.exerciseIndex});

  @override
  State<YogaPlayer> createState() => _YogaPlayerState();
}

class _YogaPlayerState extends State<YogaPlayer> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade400,
              Colors.pink.shade300,
              Colors.deepPurple.shade400,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                title: Text('Exercise ${widget.exerciseIndex}'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.white),
                titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
              ),
              Expanded(
                child: Center(
                  child: Lottie.asset(
                    'assets/yoga/${widget.exerciseIndex}.json',
                    controller: _controller,
                    onLoaded: (composition) {
                      _controller.duration = composition.duration;
                      _controller.repeat();
                    },
                    height: 400,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'Exercise ${widget.exerciseIndex}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Colors.black45,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
