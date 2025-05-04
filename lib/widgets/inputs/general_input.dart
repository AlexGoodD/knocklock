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
          width: width ?? MediaQuery.of(context).size.width * 0.8,
          height: 65,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.of(context).backgroundHelperColor,
              borderRadius: BorderRadius.circular(15),
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
                labelText: label,
                labelStyle: TextStyle(color: AppColors.of(context).primaryColor,),
                floatingLabelStyle: TextStyle(color: AppColors.of(context).primaryColor,),
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