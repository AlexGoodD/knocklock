import '../core/imports.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getLockById(String lockId) {
    return _firestore.collection('locks').doc(lockId).get();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getPassword(String lockId,
      String tipoPassword) {
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

  Future<DocumentReference<Map<String, dynamic>>> addLock(
      Map<String, dynamic> lockData) {
    return _firestore.collection('locks').add(lockData);
  }

  Future<void> setInitialPasswords(String lockId) async {
    final passwords = _firestore.collection('locks').doc(lockId).collection(
        'passwords');
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
    return _firestore.collection('locks').doc(lockId).update(
        {'seguroActivo': seguroActivo});
  }

  Stream<List<Map<String, dynamic>>> getLocksByUserStream(String userId) {
    return _firestore
        .collection('locks')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> getLocksByUser(String userId) async {
    final querySnapshot = await _firestore
        .collection('locks')
        .where('createdBy', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> getAccessLogsByUser(String userId) {
    return _firestore
        .collection('accessLogs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  Stream<List<Map<String, dynamic>>> streamLocksByUser(String userId) {
    return _firestore
        .collection('locks')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> registerUser(String uid, String firstName, String lastName, String email) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> streamUserById(String uid) {
    return _firestore.collection('users').doc(uid).snapshots();
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserById(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }

  Stream<Map<String, dynamic>?> getCurrentUserData() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value(null);
    }

    return _firestore.collection('users').doc(user.uid).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        return {
          'email': data?['email'],
          'firstName': data?['firstName'],
          'lastName': data?['lastName'],
          'avatar': data?['avatar'],
        };
      }
      return null;
    });
  }
  bool _registroEnProgreso = false;

  Future<void> registrarAccesoFallido(String lockId) async {
    if (_registroEnProgreso) return;
    _registroEnProgreso = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Lógica de intentos
      final doc = await FirebaseFirestore.instance.collection('locks').doc(lockId).get();
      final data = doc.data();
      if (data == null) return;

      final bool modoPrueba = data['modoPrueba'] ?? false;
      if (modoPrueba) return;

      int intentos = data['intentos'] ?? 3;
      final bloqueoActivo = data['bloqueoActivoIntentos'] ?? false;
      if (bloqueoActivo) return;

      intentos--;
      if (intentos <= 0) {
        await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
          'bloqueoActivoIntentos': true,
          'bloqueoTimestamp': Timestamp.now(),
          'intentos': 0,
        });
      } else {
        await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
          'intentos': intentos,
        });
      }

      // Registrar solo si pasó los checks anteriores
      await FirebaseFirestore.instance.collection('accessLogs').add({
        'lockId': lockId,
        'userId': user.uid,
        'access': false,
        'timestamp': FieldValue.serverTimestamp(),
      });

    } finally {
      _registroEnProgreso = false;
    }
  }

  Future<void> registrarAccesoCorrecto(String lockId) async {
    if (_registroEnProgreso) return;
    _registroEnProgreso = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('accessLogs').add({
        'lockId': lockId,
        'userId': user.uid,
        'access': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance.collection('locks').doc(lockId).update({
        'intentos': 3,
        'bloqueoActivoIntentos': false,
        'bloqueoTimestamp': null,
      });

      print('✅ Acceso correcto registrado en accessLogs');
    } finally {
      _registroEnProgreso = false;
    }
  }

  Future<List<Map<String, dynamic>>> getLocksByIp(String ip) async {
    final querySnapshot = await _firestore
        .collection('locks')
        .where('ip', isEqualTo: ip)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> asociarUsuarioInvitado(String userId, String lockId) async {
    // Agrega al usuario a la subcolección 'invitados' del lock
    await _firestore
        .collection('locks')
        .doc(lockId)
        .collection('invitados')
        .doc(userId)
        .set({
      'desde': FieldValue.serverTimestamp(),
    });

    // (Opcional) Marcar este lock como compartido en algún campo
    await _firestore.collection('locks').doc(lockId).update({
      'tieneInvitados': true,
    });
  }
}
