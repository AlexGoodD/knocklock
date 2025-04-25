import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

class AnimatedRecordingIcon extends StatelessWidget {
  const AnimatedRecordingIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 120,
      child: WaveWidget(
        config: CustomConfig(
          gradients: [
            [Colors.white, Colors.white70],
            [Colors.white54, Colors.white24],
          ],
          durations: [1000, 1200, 1400, 1600],
          heightPercentages: [0.25, 0.35, 0.45, 0.55],
          blur: const MaskFilter.blur(BlurStyle.solid, 3),
          gradientBegin: Alignment.bottomLeft,
          gradientEnd: Alignment.topRight,
        ),
        waveAmplitude: 25, // Mayor amplitud para simular oscilación
        backgroundColor: Colors.transparent,
        size: const Size(double.infinity, double.infinity),
      ),
    );
  }
}