import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedRecordingIcon extends StatefulWidget {
  const AnimatedRecordingIcon({super.key});

  @override
  _AnimatedRecordingIconState createState() => _AnimatedRecordingIconState();
}

class _AnimatedRecordingIconState extends State<AnimatedRecordingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _AudioWavePainter(_controller.value),
          );
        },
      ),
    );
  }
}

class _AudioWavePainter extends CustomPainter {
  final double progress;
  final int barCount = 4;

  _AudioWavePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    final centerY = size.height / 2;
    final barSpacing = size.width / (barCount + 1);

    for (int i = 0; i < barCount; i++) {
      final dx = (i + 1) * barSpacing;
      final sine = sin((progress * 2 * pi) + (i * 1));
      final barHeight = (sine * 20) + 25;

      canvas.drawLine(
        Offset(dx, centerY - barHeight / 2),
        Offset(dx, centerY + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}