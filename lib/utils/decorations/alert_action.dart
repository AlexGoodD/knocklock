import 'package:flutter/material.dart';
import 'package:knocklock_flutter/core/colors.dart';

class AlertAction extends StatelessWidget {
  final String tipo;
  final String texto;

  const AlertAction({
    super.key,
    required this.tipo,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (Navigator.of(context).canPop()) Navigator.of(context).pop();
    });

    final tipoConfig = {
      'success': {
        'bg': AlertColors.of(context).successAlertBackgroundColor,
        'icon': Icons.check_outlined,
        'iconColor': AlertColors.of(context).successAlertIconColor,
        'titulo': 'Acción realizada correctamente',
      },
      'error': {
        'bg': AppColors.of(context).errorBackgroundColor,
        'icon': Icons.error_outline,
        'iconColor': AlertColors.of(context).errorAlertIconColor,
        'titulo': 'Acción realizada sin éxito',
      },
      'warning': {
        'bg': AppColors.of(context).warningBackgroundColor,
        'icon': Icons.warning_outlined,
        'iconColor': AlertColors.of(context).warningAlertIconColor,
        'titulo': 'Precaución',
      },
    };

    final config = tipoConfig[tipo] ?? tipoConfig['success']!;
    final Color bgColor = config['bg'] as Color;
    final IconData icon = config['icon'] as IconData;
    final String titulo = config['titulo'] as String;
    final Color iconColor = config['iconColor'] as Color;

    return Align(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: iconColor, size: 25),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: AppTextStyles(context).titleAlertTextStyle,
                    ),
                    Text(
                      texto,
                      style: AppTextStyles(context).subtitleAlertTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}