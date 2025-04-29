import 'package:firebase_database/firebase_database.dart';

class RealtimeDatabaseService {
  final FirebaseDatabase _realtimeDB = FirebaseDatabase.instance;

  Future<DataSnapshot> getPattern(String lockId) {
    return _realtimeDB.ref('locks/$lockId/passwords/Patron').get();
  }

  Future<void> savePattern(String lockId, List<int> patronGrabado) {
    return _realtimeDB.ref('locks/$lockId/passwords/Patron').set(patronGrabado);
  }

  Future<void> createInitialPasswords(String lockId) {
    return _realtimeDB.ref('locks/$lockId/passwords').set({
      'Patron': [400, 500, 600],
    });
  }

  Future<void> updateLockMode(String lockId, String modo) {
    return _realtimeDB.ref('locks/$lockId').update({'modo': modo});
  }

  Future<void> updateLockSecureState(String lockId, bool seguroActivo) {
    return _realtimeDB.ref('locks/$lockId').update({'seguroActivo': seguroActivo});
  }

  Future<void> bloquearLock(String lockId, DateTime bloqueoTermina) async {
    await _realtimeDB.ref('locks/$lockId').update({
      'seguroActivo': true,
      'bloqueoActivo': true,
      'bloqueoTimestamp': bloqueoTermina.toIso8601String(), // formato String ISO
    });
  }

  Future<void> desbloquearLock(String lockId) async {
    await _realtimeDB.ref('locks/$lockId').update({
      'bloqueoActivo': false,
      'bloqueoTimestamp': null,
    });
  }
}