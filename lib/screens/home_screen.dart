import '../core/imports.dart';

class HomeScreen extends StatefulWidget {
  final void Function(bool isExpanded)? onExpandChange;
  const HomeScreen({super.key, this.onExpandChange});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final authService = FirebaseAuthService();
  bool isExpanded = false;
  bool showTopSection = true;
  bool displayTopSection = true;
  final LockController lockController = LockController();

  void addLock() async {
    final name = nameController.text;
    final ip = ipController.text;
    final id = ipController.text;


    if (name.isNotEmpty && ip.isNotEmpty) {
      await lockController.agregarLock(name, ip);
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

  void toggleAllItemsView() async {
    if (!isExpanded) {
      setState(() {
        showTopSection = false;
      });

      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        displayTopSection = false;
        isExpanded = true;
      });

      widget.onExpandChange?.call(true); // <- Notifica a MainNavigator
    } else {
      setState(() {
        displayTopSection = true;
      });

      await Future.delayed(const Duration(milliseconds: 16));

      setState(() {
        showTopSection = true;
        isExpanded = false;
      });

      widget.onExpandChange?.call(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 80),
          // Boton modal y perfil de usuario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    onTap: () {
                      if (!isExpanded) {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (context) => const QuickAccessModal(),
                        );
                      } else {
                        toggleAllItemsView();
                      }
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    radius: 24,
                    child: Icon(
                      isExpanded ? Icons.arrow_back : Icons.apps,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    onTap: () async {
                      await authService.logoutUser();
                    },
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    radius: 24,
                    child: const Icon(
                      Icons.account_circle_outlined,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          !isExpanded ? const SizedBox(height: 30) : const SizedBox.shrink(),

          // Botón de agregar
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            child: displayTopSection
                ? Column(
              children: [
                AnimatedOpacity(
                  opacity: showTopSection ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Hola Alejandro', style: AppTextStyles.primaryTextStyle),
                            SizedBox(height: 5),
                            Text('Bienvenido de vuelta', style: TextStyle(color: AppColors.primaryColor, fontSize: 14)),
                          ],
                        ),
                        ButtonAddLock(onPressed: showAddLockDialog),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedOpacity(
                  opacity: showTopSection ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: LatestLogCard(onPressed: showAddLockDialog),
                  ),
                ),
              ],
            )
                : const SizedBox.shrink(),
          ),


          !isExpanded ? const SizedBox(height: 30) : const SizedBox.shrink(),

          // Grid
          Expanded(
            child: StreamBuilder<List<Lock>>(
              stream: lockController.obtenerLocks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No hay candados registrados"));
                }

                final locks = snapshot.data!;

                return LockGridScreen(
                  locks: locks,
                  isExpanded: isExpanded,
                  onToggle: toggleAllItemsView,
                  lockController: lockController,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}