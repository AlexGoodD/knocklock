import 'package:flutter/material.dart';
import 'package:knocklock_flutter/core/colors.dart';

class GeneralInput extends StatelessWidget {
  // TODO Modificar elementos opcionales (controller/label)
  final TextEditingController controller;
  final String? label;
  final String? headerLabel;
  final bool obscureText;
  final bool enabled;

  const GeneralInput({
    super.key,
    required this.controller,
    this.label,
    this.headerLabel,
    this.obscureText = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (headerLabel != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              headerLabel!,
              style: AppTextStyles.headerLabelTextStyle,
            ),
          ),
        SizedBox(
          width: 340,
          height: 65,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              enabled: enabled, // Controla si el input está habilitado
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: Colors.black),
                floatingLabelStyle: const TextStyle(color: Colors.black),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}