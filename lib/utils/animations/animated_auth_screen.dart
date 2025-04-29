import 'package:flutter/material.dart';

class AnimatedAuthScreen extends StatefulWidget {
  final Widget child;
  final double height;

  const AnimatedAuthScreen({
    required this.child,
    required this.height,
    super.key,
  });

  @override
  State<AnimatedAuthScreen> createState() => _AnimatedAuthScreenState();
}

class _AnimatedAuthScreenState extends State<AnimatedAuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Column(
          children: [
            const Expanded(
              flex: 1,
              child: SizedBox(),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              width: double.infinity,
              height: widget.height,
              padding: const EdgeInsets.all(40.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                ),
              ),
              child: SingleChildScrollView(
                child: widget.child,
              ),
            ),
          ],
        ),
    );
  }
}