// home_screen.dart
import '../core/imports.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Lock> locks = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ipController = TextEditingController();

  void addLock() {
    final name = nameController.text;
    final ip = ipController.text;

    if (name.isNotEmpty && ip.isNotEmpty) {
      setState(() {
        locks.add(Lock(name: name, ip: ip));
      });

      nameController.clear();
      ipController.clear();
      Navigator.of(context).pop();
    }
  }

  void showAddLockDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CreateDialog(
          nameController: nameController,
          ipController: ipController,
          onAdd: addLock,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundTop,
              AppColors.backgroundBottom,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 80),
            // Boton modal y perfil de usuario
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.apps),
                    color: AppColors.primaryColor,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.account_circle_outlined),
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Botón de agregar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Textos a la izquierda
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Hola Alejandro',
                        style: AppTextStyles.primaryTextStyle
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Bienvenido de vuelta',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  // Botón a la derecha
                  ButtonAddLock(onPressed: showAddLockDialog),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Tarjeta de último acceso
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: LatestLogCard(onPressed: showAddLockDialog),
            ),

            const SizedBox(height: 20),

            // Grid
            Expanded(
              child: LockGridScreen(
                locks: locks,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomBar(),
    );
  }
}