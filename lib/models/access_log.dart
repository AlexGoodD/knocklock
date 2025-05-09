import 'package:cloud_firestore/cloud_firestore.dart';

class AccessLog {
  final String estado;
  final DateTime timestamp;
  final String lockId;

  AccessLog({
    required this.estado,
    required this.timestamp,
    required this.lockId,
  });

  // Cargar desde un DocumentSnapshot
  factory AccessLog.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final pathSegments = doc.reference.path.split('/');
    final lockId = pathSegments.length >= 2 ? pathSegments[1] : 'Desconocido';

    return AccessLog(
      estado: data['estado'] ?? 'Desconocido',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      lockId: lockId,
    );
  }

  // Cargar desde un Map<String, dynamic>
  factory AccessLog.fromMap(Map<String, dynamic> data) {
    return AccessLog(
      estado: data['estado'] ?? 'Desconocido',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      lockId: data['lockId'] ?? 'Desconocido',
    );
  }
}