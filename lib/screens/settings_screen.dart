import '../core/imports.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isTestMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30.0, 100.0, 30.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Configuración',
                  style: AppTextStyles.sectionPrimaryStyle,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Administra los ajustes generales de tu sistema y la aplicación',
                  style: AppTextStyles.sectionSecondaryStyle,
                ),
                const SizedBox(height: 30),
                OptionButton(
                  icon: Icons.person_outline,
                  title: 'Cuenta',
                  description: 'Administra de perfil y preferencias',
                  onPressed: () {
                    // Acción al presionar el botón
                    print('Botón de configuración presionado');
                  },
                ),
                const SizedBox(height: 20),
                OptionButton(
                  icon: Icons.wifi,
                  title: 'Conexión de red',
                  description: 'Ajusta direcciones IP y red local',
                  onPressed: () {
                    // Acción al presionar el botón
                    print('Botón de configuración presionado');
                  },
                ),
                const SizedBox(height: 20),
                OptionButton(
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  description: 'Administra alertas importantes',
                  onPressed: () {
                    // Acción al presionar el botón
                    print('Botón de configuración presionado');
                  },
                ),
                const SizedBox(height: 20),
                OptionButton(
                  icon: Icons.mode_night_outlined,
                  title: 'Apariencia',
                  description: 'Cambia el tema visual',
                  onPressed: () {
                    // Acción al presionar el botón
                    print('Botón de configuración presionado');
                  },
                ),
                const SizedBox(height: 20),
                OptionButton(
                  icon: Icons.ios_share_outlined,
                  title: 'Exportar historial',
                  description: 'Exporta tu historial de accesos',
                  onPressed: () {
                    // Acción al presionar el botón
                    print('Botón de configuración presionado');
                  },
                ),
                const SizedBox(height: 20),
                OptionButton(
                  icon: Icons.info_outline,
                  title: 'Acerca de KnockLock',
                  description: 'Información de la app y versión',
                  onPressed: () {
                    // Acción al presionar el botón
                    print('Botón de configuración presionado');
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 20),

          SizedBox(height: 30),
        ],
      ),
    );
  }
}