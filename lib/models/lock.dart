import 'package:cloud_firestore/cloud_firestore.dart';

class Lock {
  final String id;
  final String name;
  final String ip;
  final bool seguroActivo;
  final bool bloqueoActivo;

  Lock({
    required this.id,
    required this.name,
    required this.ip,
    required this.seguroActivo,
    required this.bloqueoActivo,
  });

  factory Lock.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Lock(
      id: doc.id,
      name: data['name'] ?? '',
      ip: data['ip'] ?? '',
      seguroActivo: data['seguroActivo'] ?? false,
      bloqueoActivo: data['bloqueoActivo'] ?? false,
    );
  }
}