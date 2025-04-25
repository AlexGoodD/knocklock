import 'package:flutter/material.dart';

class ScaleAnimationHelper {
  final AnimationController controller;
  late Animation<double> scaleAnimation;

  ScaleAnimationHelper({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 250),
  }) : controller = AnimationController(vsync: vsync, duration: duration) {
    _setScaleTween(false);
  }

  void _setScaleTween(bool isScaledDown) {
    double begin = isScaledDown ? 0.9 : 1.0;
    double end = isScaledDown ? 1.0 : 0.9;

    scaleAnimation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void toggleScale(bool isScaledDown) {
    _setScaleTween(isScaledDown);
    controller.forward(from: 0.0);
  }

  void dispose() {
    controller.dispose();
  }
}