import 'package:knocklock_flutter/core/imports.dart';

class PerfilInfoModal extends StatelessWidget {
  const PerfilInfoModal({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService(); // Instancia del servicio de usuario
    final authService = FirebaseAuthService(); // Servicio de autenticación
    final TextEditingController _firstNameController = TextEditingController();
    final TextEditingController _lastNameController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();


    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.of(context).backgroundHelperColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: StreamBuilder<Map<String, dynamic>?>(
          stream: userService.streamUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No se pudo cargar la información del usuario.'));
            }

            final userData = snapshot.data!;

            // Inicializar los controladores con los datos del usuario
            if (_firstNameController.text.isEmpty) {
              _firstNameController.text = userData['firstName'] ?? '';
            }
            if (_lastNameController.text.isEmpty) {
              _lastNameController.text = userData['lastName'] ?? '';
            }
            if (_emailController.text.isEmpty) {
              _emailController.text = userData['email'] ?? '';
            }

            return Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 45),
                        Expanded(
                          child: Text(
                            'Perfil',
                            style: AppTextStyles(context).sectionPrimaryStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.logout, color: AppColors.of(context).primaryColor),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await authService.logoutUser(context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Foto de perfil
                    Center(
                      child: CircularProfileButton(
                        imageUrl: '${userData['avatar'] ?? 'avatar1.png'}',
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(height: 20),

                    GeneralInput(
                      headerLabel: 'Nombre(s)',
                      controller: _firstNameController,
                      obscureText: false,
                      enabled: false,
                    ),

                    const SizedBox(height: 20),

                    GeneralInput(
                      headerLabel: 'Apellido(s)',
                      controller: _lastNameController,
                      obscureText: false,
                      enabled: false,
                    ),
                    const SizedBox(height: 20),

                    // Correo electrónico
                    GeneralInput(
                      headerLabel: 'Correo electrónico',
                      controller: _emailController,
                      obscureText: false,
                      enabled: false, // Cambiar a `false` si no debe ser editable
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}