import 'package:firebase_auth/firebase_auth.dart';
import 'package:knocklock_flutter/services/firestore_service.dart';

import '../core/imports.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseAuth get auth => _auth;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Registro de usuario
  Future<User?> registerUser(String email, String password, String firstName, String lastName) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Guardar datos del usuario en Firestore
        final firestoreService = FirestoreService();
        await firestoreService.registerUser(user.uid, firstName, lastName, email);
      }

      return user;
    } catch (e) {
      print('Error al registrar usuario: $e');
      return null;
    }
  }

  // Inicio de sesión
  Future<User?> loginUser(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print('Error al iniciar sesión: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> logoutUser(BuildContext context) async {
    try {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
            (route) => false, // Elimina todas las rutas anteriores
      );
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Verificar estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}