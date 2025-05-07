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
  String? _selectedAvatar;
  bool _isEditing = false;

  Future<void> _updateUserData() async {
    try {
      await _userService.updateUserDataSecure(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
        avatar: _selectedAvatar,
      );

      mostrarAlertaGlobal('exito', 'Datos actualizados correctamente');

      setState(() {
        _isEditing = false;
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _selectedAvatar = null;
      });
    } catch (e) {

      mostrarAlertaGlobal('error', 'Ocurrió un error al actualizar tus datos');
    }
  }

  void _showSelectAvatarModal(BuildContext context,
      String currentAvatar) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SelectAvatarModal(currentAvatar: currentAvatar),
    );

    if (selected != null && selected != _selectedAvatar) {
      setState(() {
        _selectedAvatar = selected;
      });
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.of(context).backgroundTop,
            AppColors.of(context).backgroundBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            _CustomAppBar(
              isEditing: _isEditing,
              onSave: _updateUserData,
              onEdit: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
            Expanded(
              child: StreamBuilder<Map<String, dynamic>?>(
                stream: _userService.streamUserData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text(
                        'No se pudo cargar la información del usuario.'));
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
                        Text(
                            'Cuenta', style: AppTextStyles(context).sectionPrimaryStyle),
                        const SizedBox(height: 10),
                        Text('Administra tu perfil y preferencias',
                            style: AppTextStyles(context).sectionSecondaryStyle),
                        const SizedBox(height: 30),
                        Center(
                          child: CircularProfileButton(
                            imageUrl: '${_selectedAvatar ??
                                userData['avatar'] ?? 'avatar1.png'}',
                            onPressed: _isEditing
                                ? () =>
                                _showSelectAvatarModal(context,
                                    userData['avatar'] ?? 'avatar1.png')
                                : () {},
                          ),
                        ),
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
                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onEdit;

  const _CustomAppBar({
    required this.isEditing,
    required this.onSave,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: kToolbarHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            IconButton(
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              onPressed: isEditing ? onSave : onEdit,
            ),
          ],
        ),
      ),
    );
  }
}