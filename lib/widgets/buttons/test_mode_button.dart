import 'package:flutter/material.dart';
import 'package:knocklock_flutter/core/imports.dart';

class TestModeButton extends StatelessWidget {
  final bool isTestMode;
  final Function(bool) onSwitchChanged;

  const TestModeButton({
    super.key,
    required this.isTestMode,
    required this.onSwitchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.of(context).backgroundHelperColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.science_outlined, size: 30),
                Switch(
                  value: isTestMode,
                  onChanged: onSwitchChanged,
                  activeColor: AppColors.of(context).backgroundHelperColor,
                  activeTrackColor: AppColors.of(context).primaryColor,
                  inactiveThumbColor: AppColors.of(context).backgroundHelperColor,
                  inactiveTrackColor: AppColors.of(context).secondaryColor,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              'Modo Prueba',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 5),
            const Text(
              'Los intentos no afectarán el conteo',
              style: TextStyle(fontSize: 11.5),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}