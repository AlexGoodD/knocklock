import 'package:knocklock_flutter/core/imports.dart';

class NewPasswordModal extends StatefulWidget {
  final String lockId;

  const NewPasswordModal({
    super.key,
    required this.lockId,
  });

  @override
  State<NewPasswordModal> createState() => _NewPasswordModalState();
}

class _NewPasswordModalState extends State<NewPasswordModal> {
  final GlobalKey<InputPasswordState> _passwordKey = GlobalKey<InputPasswordState>();

  bool isConfirmingPassword = false;
  String? firstPassword;
  final lockController = LockController();

  Future<void> _handleContinueOrConfirm() async {
    final enteredPassword = _passwordKey.currentState?.password ?? '';

    if (!isConfirmingPassword) {
      firstPassword = enteredPassword;
      _passwordKey.currentState?.clear();
      setState(() {
        isConfirmingPassword = true;
      });
    } else {
      if (enteredPassword == firstPassword) {
        await lockController.guardarClave(widget.lockId, enteredPassword);
        Navigator.pop(context, enteredPassword);
      } else {
        print("Contraseñas diferentes");
        mostrarAlertaGlobal('error', 'Las contraseñas no coinciden');
        _passwordKey.currentState?.clear();
      }
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
                      isConfirmingPassword
                          ? 'Confirma tu contraseña'
                          : 'Crea una contraseña',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isConfirmingPassword
                          ? 'Verifica tu contraseña para poder usarla'
                          : 'Procura no olvidar tu contraseña porque la necesitarás al cambiar de modo.',
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
                        onPressed: _handleContinueOrConfirm,
                        child: Text(
                          isConfirmingPassword ? 'Confirmar' : 'Continuar',
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