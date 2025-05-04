import 'package:knocklock_flutter/core/imports.dart';
import 'package:intl/intl.dart';

class LatestLogCard extends StatelessWidget {
  final LockController lockController;
  final VoidCallback? onPressed;

  const LatestLogCard({required this.lockController, this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MapEntry<AccessLog, Lock>>>(
      stream: lockController.obtenerLogsConLocks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'Error al cargar el último acceso',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text(
              'No hay accesos recientes.',
              style: TextStyle(color: AppColors.of(context).primaryColor),
            ),
          );
        }

        // Obtén el último log
        final latestLog = snapshot.data!.first;
        final log = latestLog.key;
        final lock = latestLog.value;

        return GestureDetector(
          onTap: onPressed, // Usa el callback aquí
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: AppColors.of(context).backgroundHelperColor,
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.of(context).primaryColor,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Último acceso: ${DateFormat('h:mm a').format(log.timestamp)}',
                          style: TextStyle(
                            color: AppColors.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Desde: ${lock.name} (${lock.ip})',
                          style: TextStyle(
                            color: AppColors.of(context).primaryColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.of(context).primaryColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}