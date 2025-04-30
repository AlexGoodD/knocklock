import '../core/imports.dart';
import '../services/firebase_auth_service.dart';
import '../services/firestore_service.dart';

class UserService {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  /// Escucha los cambios en los datos del usuario autenticado.
  Stream<Map<String, dynamic>?> streamUserData() {
    final user = _authService.auth.currentUser;
    if (user != null) {
      return _firestoreService
          .streamUserById(user.uid)
          .map((doc) => doc.data());
    }
    return const Stream.empty();
  }

  /// Actualiza los datos del usuario, solo si realmente cambiaron.
  Future<void> updateUserDataSecure({
    required String firstName,
    required String lastName,
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _authService.auth.currentUser;
    if (user == null) throw Exception("Usuario no autenticado");

    final doc = await _firestoreService.getUserById(user.uid);
    final currentData = doc.data() ?? {};

    final updates = <String, dynamic>{};

    if (firstName != currentData['firstName']) {
      updates['firstName'] = firstName;
    }
    if (lastName != currentData['lastName']) {
      updates['lastName'] = lastName;
    }

    final willUpdateEmail = email != user.email;
    final willUpdatePassword = newPassword.isNotEmpty;

    // Solo reautenticar si es necesario
    if (willUpdateEmail || willUpdatePassword) {
      if (currentPassword.isEmpty) {
        throw Exception('Debes ingresar tu contraseña actual para actualizar el correo o la contraseña.');
      }

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      if (willUpdateEmail) {
        await user.updateEmail(email);
        updates['email'] = email;
      }

      if (willUpdatePassword) {
        await user.updatePassword(newPassword);
      }
    }

    if (updates.isNotEmpty) {
      await _firestoreService.updateUserFields(user.uid, updates);
    }
  }
}