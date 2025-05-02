import 'package:knocklock_flutter/core/imports.dart';

class TokenModal extends StatefulWidget {
  final String lockId;

  const TokenModal({
    super.key,
    required this.lockId,
  });

  @override
  State<TokenModal> createState() => _TokenModalState();
}

class _TokenModalState extends State<TokenModal> {
  final GlobalKey<InputPasswordState> _passwordKey = GlobalKey<InputPasswordState>();

  final lockController = LockController();
  final firestoreService = FirestoreService();
  String? _generatedToken;

  @override
  void initState() {
    super.initState();
    _generateAndSetPassword();
  }


  Future<void> _generateAndSetPassword() async {
    print('Entrando a la función _handleVerifyPassword');

    // Generar una contraseña aleatoria de 8 caracteres
    const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final generatedPassword = List.generate(5, (index) => characters[random.nextInt(characters.length)]).join();

    // Precargar la contraseña generada en el InputPassword
    setState(() {
      _generatedToken = generatedPassword;
    });

    // Guardar la contraseña hasheada en Firestore en el documento 'Token'
    await lockController.guardarToken(widget.lockId, generatedPassword, 'Token');
  }

  void closeModal() {
    Navigator.of(context).pop();
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
                      'Token',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Tu token se genera automáticamente y es único. Recuerda usarlo para ingresar.',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_generatedToken != null)
                      TokenDisplay(
                        value: _generatedToken!,
                        length: 5,
                      )
                    else
                      const CircularProgressIndicator(),
                    const SizedBox(height: 30),
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
                        onPressed: closeModal,
                        child: Text(
                          'Aceptar',
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