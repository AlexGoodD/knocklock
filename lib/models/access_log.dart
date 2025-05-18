import '../core/imports.dart';

class AccessLog {
  final bool estado; // true = acceso correcto, false = fallido
  final DateTime timestamp;
  final String lockId;

  AccessLog({
    required this.estado,
    required this.timestamp,
    required this.lockId,
  });

  factory AccessLog.fromMap(Map<String, dynamic> data) {
    return AccessLog(
      estado: data['access'] == true, // 🔄 CAMBIA 'estado' por 'access'
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      lockId: data['lockId'] ?? 'Desconocido',
    );
  }
}