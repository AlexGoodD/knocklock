import 'package:flutter/material.dart';
import 'package:knocklock_flutter/core/colors.dart';

class AlertAction extends StatelessWidget {
  final String tipo; // 'error' o 'exito'
  final String texto;

  const AlertAction({
    Key? key,
    required this.tipo,
    required this.texto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    });

    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 6,
        color: tipo == 'error' ? AppColors.of(context).errorBackgroundColor : AppColors.of(context).successBackgroundColor,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: tipo == 'error' ? AppColors.of(context).errorTextColor : AppColors.of(context).successTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}