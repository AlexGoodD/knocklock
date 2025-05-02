import 'package:knocklock_flutter/core/imports.dart';
import '../../main.dart';

void mostrarAlertaGlobal(String tipo, String texto) {
  final context = navigatorKey.currentContext;

  if (context != null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertAction(tipo: tipo, texto: texto),
    );
  } else {
    print('⚠️ No hay contexto disponible para mostrar la alerta');
  }
}