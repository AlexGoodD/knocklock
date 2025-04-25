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
}