import 'package:flutter/material.dart';
import 'package:knocklock_flutter/core/colors.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const AuthButton({
    required this.onPressed,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
              topRight: Radius.circular(0),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: AppTextStyles.authButtonTextStyle,
        ),
      ),
    );
  }
}