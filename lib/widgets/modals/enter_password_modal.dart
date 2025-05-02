import 'package:flutter/material.dart';
import '../inputs/input_password.dart';
import 'package:knocklock_flutter/core/imports.dart';

class EnterPasswordModal extends StatefulWidget {
  final String lockId;

  const EnterPasswordModal({
    super.key,
    required this.lockId,
  });

  @override
  State<EnterPasswordModal> createState() => _EnterPasswordModalState();
}

class _EnterPasswordModalState extends State<EnterPasswordModal> {
  final GlobalKey<InputPasswordState> _passwordKey = GlobalKey<InputPasswordState>();

  final lockController = LockController();
  final firestoreService = FirestoreService();

  Future<void> _handleVerifyPassword() async {
    final enteredPassword = _passwordKey.currentState?.password ?? '';

    final isValid = await lockController.verificarClave(widget.lockId, enteredPassword);

    if (isValid) {
      await firestoreService.updateLockSecureState(widget.lockId, false);
      await firestoreService.saveAccess(widget.lockId, 'Acceso correcto');
      Navigator.pop(context);
    } else {
      await firestoreService.saveAccess(widget.lockId, 'Acceso fallido');
      Navigator.pop(context);

    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Ingresa tu contraseña',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Si no recuerdas tu contraseña, no podrás cambiar el modo de tu dispositivo.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    InputPassword(
                      key: _passwordKey,
                      length: 5,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _handleVerifyPassword,
                        child: Text(
                          'Ingresar',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}