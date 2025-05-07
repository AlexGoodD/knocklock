import 'package:flutter/material.dart';
import 'package:knocklock_flutter/core/colors.dart';

class GeneralInput extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? headerLabel;
  final bool obscureText;
  final bool enabled;
  final double? width;

  const GeneralInput({
    super.key,
    required this.controller,
    this.label,
    this.headerLabel,
    this.obscureText = false,
    this.enabled = true,
    this.width,
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
              style: AppTextStyles(context).headerLabelTextStyle,
            ),
          ),
        SizedBox(
          width: width ?? MediaQuery.of(context).size.width * 0.9,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.of(context).backgroundHelperColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.of(context).primaryColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(color: AppColors.of(context).primaryColor),
                isCollapsed: true, // elimina el espacio extra vertical
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              ),
            ),
          ),
        ),
      ],
    );
  }
}