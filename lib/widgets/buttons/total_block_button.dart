import 'package:flutter/material.dart';
import 'package:knocklock_flutter/core/imports.dart';

class TotalBlockButton extends StatelessWidget {
  const TotalBlockButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorBackgroundColor,
        border: Border.all(color: AppColors.errorTextColor, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.errorTextColor, size: 40),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Activar Bloqueo Total',
                  style: TextStyle(color: AppColors.errorTextColor, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'Inhabilita desbloqueos durante 1 hora',
                  style: TextStyle(color: AppColors.errorTextColor),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}