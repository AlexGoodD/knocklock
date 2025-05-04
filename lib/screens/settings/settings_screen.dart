import 'package:provider/provider.dart';

import '../../core/imports.dart';

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
                Text(
                  'Configuración',
                  style: AppTextStyles(context).sectionPrimaryStyle,
                ),
                const SizedBox(height: 10),
                Text(
                  'Administra los ajustes generales de tu sistema y la aplicación',
                  style: AppTextStyles(context).sectionSecondaryStyle,
                ),
                const SizedBox(height: 30),
                Column(
                  children: [
                    ...[
                      OptionButton(
                        icon: Icons.person_outline,
                        title: 'Cuenta',
                        description: 'Administra de perfil y preferencias',
                        onPressed: () {
                          Navigator.push(
                            context,
                            RouteTransitions.slideTransition(const AccountScreen()),
                          );
                        },
                      ),
                      SwitchOptionButton(
                        icon: Icons.mode_night_outlined,
                        title: 'Apariencia',
                        description: 'Cambia el tema visual',
                        initialValue: Provider.of<ThemeProvider>(context).isDarkMode,
                        onChanged: (value) {
                          Provider.of<ThemeProvider>(context, listen: false).toggleTheme(value);
                        },
                      ),
                      OptionButton(
                        icon: Icons.ios_share_outlined,
                        title: 'Exportar historial',
                        description: 'Exporta tu historial de accesos',
                        onPressed: () {
                          LockController().exportarLogsDelUsuarioAExcel();
                        },
                      ),
                      OptionButton(
                        icon: Icons.info_outline,
                        title: 'Acerca de nosotros',
                        description: 'Información de la app y versión',
                        onPressed: () {
                          Navigator.push(
                            context,
                            RouteTransitions.slideTransition(const AboutScreen()),
                          );
                        },
                      ),
                    ].expand((widget) => [
                      widget,
                      const SizedBox(height: 30),
                    ]).toList()
                      ..removeLast(),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}