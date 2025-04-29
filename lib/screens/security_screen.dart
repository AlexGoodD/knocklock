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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(30.0, 100.0, 30.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Control de Seguridad',
                  style: AppTextStyles.sectionPrimaryStyle,
                ),
                SizedBox(height: 10),
                Text(
                  'Gestiona el estado de todos tus dispositivos',
                  style: AppTextStyles.sectionSecondaryStyle,
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}