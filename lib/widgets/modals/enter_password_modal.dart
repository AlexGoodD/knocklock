import 'package:flutter/material.dart';
import '../inputs/input_password.dart';
import 'package:knocklock_flutter/core/imports.dart';

class EnterPasswordModal extends StatefulWidget {
  final String lockId;
  final String tipoPassword;

  const EnterPasswordModal({
    super.key,
    required this.lockId,
    required this.tipoPassword,
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

    final isValid = await lockController.verificarClave(widget.lockId, enteredPassword, widget.tipoPassword,);

    if (isValid) {
      await firestoreService.updateLockSecureState(widget.lockId, false);
     // await firestoreService.saveAccess(widget.lockId, 'Acceso correcto');
      await lockController.restablecerIntentos(widget.lockId);
      Navigator.pop(context);
    } else {
      //await firestoreService.saveAccess(widget.lockId, 'Acceso fallido');
      //await lockController.registrarIntentoFallido(widget.lockId);
      Navigator.pop(context);

    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: AppColors.of(context).backgroundTop,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                          backgroundColor: AppColors.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _handleVerifyPassword,
                        child: Text(
                          'Ingresar',
                          style: TextStyle(
                            color: AppColors.of(context).helperColor,
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