import '../../core/imports.dart';

class LoginContent extends StatelessWidget {
  final VoidCallback onToggle;
  const LoginContent({required this.onToggle, super.key});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    Future<void> handleLogin() async {
      final email = emailController.text;
      final password = passwordController.text;
      final user = await authService.loginUser(email, password);

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigator()),
        );
      } else {
        mostrarAlertaGlobal('error', 'Inicio de sesión fallido.');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Inicio de sesión', style: AppTextStyles(context).authTextStyle),
        const SizedBox(height: 50),
        AuthInputField(controller: emailController, label: 'Correo electrónico'),
        const SizedBox(height: 16),
        AuthInputField(controller: passwordController, label: 'Contraseña', obscureText: true),
        const SizedBox(height: 155),
        AuthButton(label: 'Iniciar sesión', onPressed: () {handleLogin();}),
        const SizedBox(height: 20),
        TextButton(
          onPressed: onToggle,
          child: Text('¿No tienes una cuenta? Crea una', style: AppTextStyles(context).authBottomTextStyle),
        ),
      ],
    );
  }
}