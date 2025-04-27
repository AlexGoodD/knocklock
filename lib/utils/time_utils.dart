class TimeUtils {
  static String calcularTiempoTranscurrido(DateTime timestamp) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(timestamp);

    if (diferencia.inMinutes < 1) {
      return 'justo ahora';
    } else if (diferencia.inMinutes < 60) {
      return 'hace ${diferencia.inMinutes} min';
    } else if (diferencia.inHours < 24) {
      return 'hace ${diferencia.inHours} hrs';
    } else {
      return 'hace ${diferencia.inDays} días';
    }
  }
}