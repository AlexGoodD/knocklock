import 'package:flutter/material.dart';

class ScaleAnimationHelper {
  final AnimationController controller;
  late Animation<double> scaleAnimation;

  ScaleAnimationHelper({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 250),
  }) : controller = AnimationController(vsync: vsync, duration: duration) {
    _setScaleTween();
  }

  void _setScaleTween() {
    scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void triggerAnimation() {
    controller.forward(from: 0.0).then((_) => controller.reverse());
  }

  void dispose() {
    controller.dispose();
  }
}