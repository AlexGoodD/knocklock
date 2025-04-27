import 'package:knocklock_flutter/core/imports.dart';

class StatusLog extends StatelessWidget {
  final bool isSuccess;

  const StatusLog({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 25.0, // Altura fija
      width: 100.0, // Ancho fijo
      decoration: BoxDecoration(
        color: isSuccess
            ? AppColors.successBackgroundColor
            : AppColors.errorBackgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center( // Centra el texto
        child: Text(
          isSuccess ? 'Acceso correcto' : 'Acceso fallido',
          style: TextStyle(
            color: isSuccess
                ? AppColors.successTextColor
                : AppColors.errorTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}