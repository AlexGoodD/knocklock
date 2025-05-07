import 'package:knocklock_flutter/core/imports.dart';

class LockDetailModal extends StatelessWidget {
  final Lock lock;
  final LockController controller;

  const LockDetailModal({
    super.key,
    required this.lock,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.of(context).backgroundTop,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Configuración del Dispositivo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Realiza ajustes esenciales en tu candado.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            OptionButton(
              icon: Icons.lock_outline,
              title: 'Cambiar Nombre',
              description: 'Renombra el candado.',
              onPressed: () async {
                final nuevoNombre = await mostrarDialogoTexto(
                  context,
                  'Nuevo Nombre del Lock',
                  lock.name,
                  label: 'Nombre del Lock', // aquí pasas el label personalizado
                );
                if (nuevoNombre != null && nuevoNombre.trim().isNotEmpty) {
                  await FirebaseFirestore.instance.collection('locks').doc(lock.id).update({
                    'name': nuevoNombre.trim(),
                  });
                  Navigator.pop(context); // Cierra modal después del cambio
                }
              },
            ),
            const SizedBox(height: 15),
            OptionButton(
              icon: Icons.wifi,
              title: 'Actualizar IP',
              description: 'Edita la dirección IP del candado.',
              onPressed: () async {
                controller.desconectar();
                final nuevaIp = await mostrarDialogoTexto(context, 'Nueva IP', lock.ip, label: 'IP del Lock');
                if (nuevaIp != null && nuevaIp.trim().isNotEmpty) {
                  await FirebaseFirestore.instance.collection('locks').doc(lock.id).update({
                    'ip': nuevaIp.trim(),
                  });
                  Navigator.pop(context);
                }
              },
            ),
            const SizedBox(height: 15),
            OptionButton(
              icon: Icons.delete_outline,
              title: 'Eliminar Dispositivo',
              description: 'Elimina el candado de forma permanente',
              onPressed: () async {
                controller.desconectar();
                final confirm = await mostrarDialogoConfirmacion(context, '¿Estás seguro de eliminar este dispositivo? Esta acción no se puede deshacer.');
                if (confirm) {
                  await FirebaseFirestore.instance.collection('locks').doc(lock.id).delete();
                  Navigator.pop(context); // Cierra modal
                  Navigator.pop(context); // Regresa a la pantalla anterior
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}