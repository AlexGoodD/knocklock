import '../core/imports.dart';

class LogsScreen extends StatefulWidget {
  const LogsScreen({super.key});

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  final LockController lockController = LockController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(35.0, 100.0, 35.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Historial de Accesos',
              style: AppTextStyles.sectionPrimaryStyle,
            ),
            const SizedBox(height: 10),
            const Text(
              'Revisa todos los intentos de desbloqueo de tus dispositivos',
              style: AppTextStyles.sectionSecondaryStyle,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<MapEntry<AccessLog, Lock>>>(
                stream: lockController.obtenerLogsConLocks(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error al cargar los logs: ${snapshot.error}',
                        style: TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final entries = snapshot.data!;

                  if (entries.isEmpty) {
                    return const Center(
                      child: Text('No hay logs disponibles.'),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final log = entries[index].key;
                      final lock = entries[index].value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: LogCard(log: log, lock: lock),
                      );
                    },
                  );
                },
              )
            ),
          ],
        ),
      ),
    );
  }
}