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

  Stream<List<Map<String, dynamic>>> getAccessLogs() {
    return _firestore
        .collectionGroup('accessLogs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
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
        .collection('locks')
        .where('createdBy', isEqualTo: userId)
        .snapshots()
        .asyncExpand((locksSnapshot) {
      final lockIds = locksSnapshot.docs.map((doc) => doc.id).toList();

      if (lockIds.isEmpty) {
        return Stream.value([]);
      }

      final List<Stream<List<Map<String, dynamic>>>> streams = lockIds.map((lockId) {
        return _firestore
            .collection('locks')
            .doc(lockId)
            .collection('accessLogs')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['lockId'] = lockId;
            return data;
          }).toList();
        });
      }).toList();

      return Rx.combineLatestList(streams).map((listOfLists) {
        final allLogs = listOfLists.expand((logs) => logs).toList();
        allLogs.sort((a, b) {
          final tsA = (a['timestamp'] as Timestamp).toDate();
          final tsB = (b['timestamp'] as Timestamp).toDate();
          return tsB.compareTo(tsA);
        });
        return allLogs;
      });
    });
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

  Future<void> saveAccess(String lockId, String estado) async {
    try {
      await FirebaseFirestore.instance
          .collection('locks')
          .doc(lockId)
          .collection('accessLogs')
          .add({
        'estado': estado,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Acceso guardado correctamente');
    } catch (e) {
      print('❌ Error al guardar el acceso: $e');
    }
  }

  Future<void> registrarIntentoFallido(String lockId) async {
    final docRef = FirebaseFirestore.instance.collection('locks').doc(lockId);
    final doc = await docRef.get();

    int intentos = doc.data()?['intentos'] ?? 3;
    intentos = intentos - 1;

    if (intentos <= 0) {
      await docRef.update({
        'intentos': 0,
        'bloqueoActivoIntentos': true,
        'bloqueoTimestamp': Timestamp.fromDate(DateTime.now().add(Duration(minutes: 5))),
      });
    } else {
      await docRef.update({
        'intentos': intentos,
      });
    }
  }

  Future<void> registrarAccesoCorrecto(String lockId) async {
    final docRef = FirebaseFirestore.instance.collection('locks').doc(lockId);

    await docRef.update({
      'intentos': 3,
      'bloqueoActivoIntentos': false,
      'bloqueoTimestamp': null,
    });
  }
}
