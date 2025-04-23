import 'dart:developer' as console;

import 'package:knocklock_flutter/core/imports.dart';

class QuickAccessModal extends StatelessWidget {
  const QuickAccessModal({super.key});

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
            const SizedBox(height: 10),
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
            const SizedBox(height: 20),
            _buildButton(
              context,
              icon: Icons.lock,
              title: 'Administrar Locks',
              description: 'Cambiar nombre/IP o eliminar un candado',
              onPressed: () {
                console.log('Acción: Administrar Locks');
                // Lógica para administrar candados
              },
            ),
            const SizedBox(height: 10),
            _buildButton(
              context,
              icon: Icons.settings,
              title: 'Modo Prueba',
              description: 'Prueba patrones sin gastar intentos reales',
              onPressed: () {
                console.log('Acción: Modo Prueba');
                // Lógica para activar modo prueba
              },
            ),
            const SizedBox(height: 10),
            _buildButton(
              context,
              icon: Icons.info,
              title: 'Notificaciones',
              description: 'Activa o silencia alertas de intentos fallidos',
              onPressed: () {
                console.log('Acción: Notificaciones');
                // Lógica para administrar notificaciones
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required VoidCallback onPressed,
      }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0.1,
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.HelperBorderColor),
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          const SizedBox(width: 10),
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.primaryModalStyle
              ),
              Text(
                description,
                  style: AppTextStyles.secondaryModalStyle
              ),
            ],
          ),
        ],
      ),
    );
  }
}