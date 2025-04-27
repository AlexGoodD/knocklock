import '../core/imports.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool isTestMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(35.0, 100.0, 35.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Control de Seguridad',
              style: AppTextStyles.sectionPrimaryStyle,
            ),
            const SizedBox(height: 10),
            const Text(
              'Gestiona el estado de todos tus dispositivos',
              style: AppTextStyles.sectionSecondaryStyle,
            ),
            const SizedBox(height: 35),
            const BlockAllButton(),
            const SizedBox(height: 35),
            const GlobalStatusCard(),
            const SizedBox(height: 35),
            Row(
              children: [
                TestModeButton(
                  isTestMode: isTestMode,
                  onSwitchChanged: (value) {
                    setState(() {
                      isTestMode = value;
                    });
                  },
                ),
                const TempBlockButton(),
              ],
            ),
            const SizedBox(height: 35),
            const TotalBlockButton(),
          ],
        ),
      ),
    );
  }
}