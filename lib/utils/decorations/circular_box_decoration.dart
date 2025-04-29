import 'package:flutter/material.dart';

BoxDecoration circularBoxDecoration({
  required Color color,
  double spreadRadius = 2,
  double blurRadius = 80,
}) {
  return BoxDecoration(
    color: color,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        spreadRadius: spreadRadius,
        blurRadius: blurRadius,
        offset: const Offset(0, 0),
      ),
    ],
  );
}