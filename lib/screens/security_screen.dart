import '../core/imports.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  @override
  void initState() {
    super.initState();
    _cargarEstadoModoPrueba();
  }

  bool isTestMode = false;

  Future<void> _cargarEstadoModoPrueba() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final locks = await FirestoreService().getLocksByUser(user.uid);
    if (locks.isEmpty) return;

    // Verifica si al menos uno tiene modoPrueba activo
    final algunoEnModo = locks.any((lock) => lock['modoPrueba'] == true);

    setState(() {
      isTestMode = algunoEnModo;
    });
  }

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
                        onSwitchChanged: (value) async {
                          setState(() {
                            isTestMode = value;
                          });
                          if (value) {
                            await LockController().activarModoPruebaEnTodosLosLocks();
                          } else {
                            await LockController().desactivarModoPruebaEnTodosLosLocks();
                          }
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