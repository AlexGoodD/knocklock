import '../core/imports.dart';

class LogsScreen extends StatelessWidget {
  const LogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Historial de accesos',
              style: AppTextStyles.primaryTextStyle,
            ),
            SizedBox(height: 10),
            Text(
              'Revisa todos los intentos de desbloqueo de tus dispositivos',
              style: AppTextStyles.sectionSecondaryStyle,
            ),
          ],
        ),
      ),
    );
  }
}