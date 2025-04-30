import 'dart:developer' as console;

import '../../core/imports.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isEditing = false;

  Future<void> _updateUserData() async {
    try {
      await _userService.updateUserDataSecure(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados correctamente')),
      );

      setState(() {
        _isEditing = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar los datos: $e')),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundTop,
            AppColors.backgroundBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              onPressed: () {
                if (_isEditing) {
                  _updateUserData(); // guarda
                } else {
                  setState(() {
                    _isEditing = true; // habilita edición
                  });
                }
              },
            ),
          ],
        ),
        body: StreamBuilder<Map<String, dynamic>?>(
          stream: _userService.streamUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No se pudo cargar la información del usuario.'));
            }

            final userData = snapshot.data!;
            if (_firstNameController.text.isEmpty) {
              _firstNameController.text = userData['firstName'] ?? '';
            }
            if (_lastNameController.text.isEmpty) {
              _lastNameController.text = userData['lastName'] ?? '';
            }
            if (_emailController.text.isEmpty) {
              _emailController.text = userData['email'] ?? '';
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Text('Cuenta', style: AppTextStyles.sectionPrimaryStyle),
                  const SizedBox(height: 10),
                  const Text('Administra tu perfil y preferencias', style: AppTextStyles.sectionSecondaryStyle),
                  const SizedBox(height: 30),
                  GeneralInput(
                    headerLabel: 'Nombre(s)',
                    controller: _firstNameController,
                    obscureText: false,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 20),
                  GeneralInput(
                    headerLabel: 'Apellido(s)',
                    controller: _lastNameController,
                    obscureText: false,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 20),
                  GeneralInput(
                    headerLabel: 'Correo electrónico',
                    controller: _emailController,
                    obscureText: false,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 20),
                  GeneralInput(
                    headerLabel: 'Contraseña actual',
                    controller: _currentPasswordController,
                    obscureText: true,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 20),
                  GeneralInput(
                    headerLabel: 'Nueva contraseña',
                    controller: _newPasswordController,
                    obscureText: true,
                    enabled: _isEditing,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}