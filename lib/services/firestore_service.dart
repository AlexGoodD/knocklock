import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getLockById(String lockId) {
    return _firestore.collection('locks').doc(lockId).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPassword(String lockId, String tipoPassword) {
    return _firestore
        .collection('locks')
        .doc(lockId)
        .collection('passwords')
        .doc(tipoPassword)
        .get();
  }

  Future<void> savePattern(String lockId, List<int> patronGrabado) async {
    await _firestore
        .collection('locks')
        .doc(lockId)
        .collection('passwords')
        .doc('Patron')
        .set({
      'type': 'arreglo_numeros',
      'value': patronGrabado,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> addLock(Map<String, dynamic> lockData) {
    return _firestore.collection('locks').add(lockData);
  }

  Future<void> setInitialPasswords(String lockId) async {
    final passwords = _firestore.collection('locks').doc(lockId).collection('passwords');
    await passwords.doc('Clave').set({
      'type': 'alfanumerico',
      'value': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
    await passwords.doc('Patron').set({
      'type': 'arreglo_numeros',
      'value': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
    await passwords.doc('Token').set({
      'type': 'alfanumerico',
      'value': '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> getLocks() {
    return _firestore.collection('locks').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> updateLockMode(String lockId, String modo) {
    return _firestore.collection('locks').doc(lockId).update({'modo': modo});
  }

  Future<void> updateLockSecureState(String lockId, bool seguroActivo) {
    return _firestore.collection('locks').doc(lockId).update({'seguroActivo': seguroActivo});
  }

  Stream<List<Map<String, dynamic>>> getAccessLogs() {
    return _firestore
        .collectionGroup('accessLogs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}