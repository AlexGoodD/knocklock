import '../core/imports.dart';

Map<String, dynamic> calcularEstadoBloqueo(List<Map<String, dynamic>> locks) {
  bool bloqueoActivado = false;
  int minutosRestantes = 60;

  for (final lock in locks) {
    if (lock['bloqueoActivo'] == true && lock['bloqueoTimestamp'] != null) {
      final bloqueoTimestamp = (lock['bloqueoTimestamp'] as Timestamp).toDate();
      final ahora = DateTime.now();
      final diffMinutes = bloqueoTimestamp.difference(ahora).inMinutes;

      if (diffMinutes > 0) {
        bloqueoActivado = true;
        minutosRestantes = diffMinutes;
      }
      break;
    }
  }

  return {
    'bloqueoActivado': bloqueoActivado,
    'minutosRestantes': minutosRestantes,
  };
}