import 'package:knocklock_flutter/core/imports.dart';

class QuickAccessModal extends StatefulWidget {
  const QuickAccessModal({super.key});

  @override
  State<QuickAccessModal> createState() => _QuickAccessModalState();
}

class _QuickAccessModalState extends State<QuickAccessModal> {
  bool isTestMode = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Accede rápidamente a las funciones más importantes de tu sistema de seguridad.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(height: 20),

            OptionButton(
              icon: Icons.build_outlined,
              title: 'Administrar Locks',
              description: 'Cambiar nombre/IP o eliminar un candado',
              onPressed: () {
                // Acción al presionar el botón
                print('Botón de configuración presionado');
              },
            ),
            SizedBox(height: 15),
            SwitchOptionButton(
              icon: Icons.science_outlined,
              title: 'Modo Prueba',
              description: 'Prueba patrones sin gastar intentos',
              initialValue: isTestMode,
              onChanged: (value) {
                setState(() {
                  isTestMode = value;
                });
              },
            ),
            SizedBox(height: 15),
            OptionButton(
              icon: Icons.notifications_outlined,
              title: 'Notificaciones',
              description: 'Activa o silencia alertas de intentos fallidos',
              onPressed: () {
                Navigator.push(
                  context,
                  RouteTransitions.slideTransition(const NotificationsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}