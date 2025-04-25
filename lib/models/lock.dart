import 'package:cloud_firestore/cloud_firestore.dart';

class Lock {
  final String id;
  final String name;
  final String ip;
  final bool seguroActivo;

  Lock({
    required this.id,
    required this.name,
    required this.ip,
    required this.seguroActivo,
  });

  factory Lock.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Lock(
      id: doc.id,
      name: data['name'] ?? '',
      ip: data['ip'] ?? '',
      seguroActivo: data['seguroActivo'] ?? false,
    );
  }
}