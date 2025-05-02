import '../../core/imports.dart';

class RegisterContent extends StatelessWidget {
  final VoidCallback onToggle;
  const RegisterContent({required this.onToggle, super.key});

  @override
  Widget build(BuildContext context) {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final authService = FirebaseAuthService();

    Future<void> handleRegister() async {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();

      if (password != confirmPassword) {
        mostrarAlertaGlobal('error', 'Las contraseñas no coinciden.');
        return;
      }

      final user = await authService.registerUser(email, password, firstName, lastName);
      if (user != null) {
        mostrarAlertaGlobal('exito', 'Registro correcto.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      } else {
        mostrarAlertaGlobal('error', 'Registro fallido.');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text('Registro', style: AppTextStyles.authTextStyle),
        const SizedBox(height: 50),
        AuthInputField(controller: firstNameController, label: 'Nombre(s)'),
        const SizedBox(height: 16),
        AuthInputField(controller: lastNameController, label: 'Apellido(s)'),
        const SizedBox(height: 16),
        AuthInputField(controller: emailController, label: 'Correo electrónico'),
        const SizedBox(height: 16),
        AuthInputField(controller: passwordController, label: 'Contraseña', obscureText: true),
        const SizedBox(height: 16),
        AuthInputField(controller: confirmPasswordController, label: 'Confirmar contraseña', obscureText: true),
        const SizedBox(height: 60),
        AuthButton(label: 'Registrarme', onPressed: () {handleRegister();}),
        const SizedBox(height: 20),
        TextButton(
          onPressed: onToggle,
          child: const Text('¿Tienes una cuenta? Inicia sesión', style: AppTextStyles.authBottomTextStyle),
        ),
      ],
    );
  }
}