import 'package:knocklock_flutter/core/imports.dart';

class GlobalStatusCard extends StatelessWidget {
  const GlobalStatusCard({super.key});

  @override
  Widget build(BuildContext context) {

    final LockController lockController = LockController();
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado Global',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            StreamBuilder<Map<String, int>>(
              stream: lockController.obtenerEstadoGlobalLocksDelUsuario(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bloqueados = snapshot.data!['bloqueados']!;
                final desbloqueados = snapshot.data!['desbloqueados']!;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statusBox(context, '$desbloqueados desbloqueados', AppColors.successTextColor, AppColors.successBackgroundColor, AppColors.successTextColor),
                    _statusBox(context, '$bloqueados bloqueados', AppColors.errorTextColor, AppColors.errorBackgroundColor, AppColors.errorTextColor),
                  ],
                );
              },
            ),
            const SizedBox(height: 15),
            StreamBuilder<List<MapEntry<AccessLog, Lock>>>(
              stream: lockController.obtenerLogsConLocks(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.warningTextColor, width: 1),
                      color: AppColors.warningBackgroundColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'No hay intentos recientes.',
                      style: TextStyle(color: AppColors.warningTextColor),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final latestLog = snapshot.data!.first.key;
                final estado = latestLog.estado == 'Acceso correcto' ? 'Correcto' : 'Fallido';
                final nombreLock = snapshot.data!.first.value.name;
                final tiempoTranscurrido = TimeUtils.calcularTiempoTranscurrido(latestLog.timestamp);

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.warningTextColor, width: 1),
                    color: AppColors.warningBackgroundColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Último intento: $estado en $nombreLock – $tiempoTranscurrido',
                          style: const TextStyle(
                            color: AppColors.warningTextColor,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _statusBox(BuildContext context, String text, Color color, Color background, Color borderColor) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.32,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}