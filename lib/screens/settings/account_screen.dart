import '../../core/imports.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
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
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cuenta',
                      style: AppTextStyles.sectionPrimaryStyle,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Administra tu perfil y preferencias',
                      style: AppTextStyles.sectionSecondaryStyle,
                    ),
                    const SizedBox(height: 30),
                    GeneralInput(
                      headerLabel: 'Nombre(s)',
                      controller: TextEditingController(),
                    ),
                    const SizedBox(height: 20),
                    GeneralInput(
                      headerLabel: 'Apellido(s)',
                      controller: TextEditingController(),
                    ),
                    const SizedBox(height: 20),
                    GeneralInput(
                      headerLabel: 'Correo electrónico',
                      controller: TextEditingController(),
                    ),
                    const SizedBox(height: 20),
                    GeneralInput(
                      headerLabel: 'Contraseña',
                      controller: TextEditingController(),
                    ),
                    const SizedBox(height: 20),
                    GeneralInput(
                      headerLabel: 'Número telefónico',
                      controller: TextEditingController(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}