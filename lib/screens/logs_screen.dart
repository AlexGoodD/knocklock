import '../core/imports.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero, // Elimina la separación superior
                  itemCount: 10, // Hardcodea 10 elementos
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: LogCard(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}