import '../core/imports.dart';

class HomeScreen extends StatefulWidget {
  final void Function(bool isExpanded)? onExpandChange;
  final void Function(int index)? onNavigateTo;
  const HomeScreen({super.key, this.onExpandChange, this.onNavigateTo});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController ipController = TextEditingController();
  final authService = FirebaseAuthService();
  final firestoreService = FirestoreService();
  bool isExpanded = false;
  bool showTopSection = true;
  bool _isTopSectionVisible = true;
  final lockController = LockController();
  String firstName = '';
  StreamSubscription<Map<String, dynamic>?>? _userDataSubscription;
  List<Lock> currentLocks = [];


  @override
  void initState() {
    super.initState();
    _subscribeToUserFirstName();
  }

  void _subscribeToUserFirstName() {
    _userDataSubscription =
        firestoreService.getCurrentUserData().listen((userData) {
          if (userData != null && mounted) {
            setState(() {
              final fullName = userData['firstName'] ?? '';
              final rawFirstName = fullName
                  .split(' ')
                  .first;
              firstName = rawFirstName.length > 7
                  ? '${rawFirstName.substring(0, 7)}...'
                  : rawFirstName;
            });
          }
        });
  }

  void addLock() async {
    final name = nameController.text;
    final ip = ipController.text;

    if (name.isNotEmpty && ip.isNotEmpty) {
      await lockController.agregarLock(name, ip);
      nameController.clear();
      ipController.clear();
      Navigator.of(context).pop();
    }
  }

  void showAddLockDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddNewLockModal(
          nameController: nameController,
          ipController: ipController,
          onAdd: addLock,
        );
      },
    );
  }


  void toggleAllItemsView() async {
    if (!isExpanded) {
      // 1. Fade-out del TopSection
      setState(() {
        _isTopSectionVisible = false;
      });

      // 2. Espera a que termine el fade-out
      await Future.delayed(const Duration(milliseconds: 300));

      // 3. Elimina del layout
      setState(() {
        showTopSection = false;
        isExpanded = true;
      });

      widget.onExpandChange?.call(true);

    } else {
      // 1. Agrega al layout pero invisible
      setState(() {
        showTopSection = true;
        _isTopSectionVisible = false;
      });

      // 2. Espera a que se reestructure con su tamaño original
      await Future.delayed(const Duration(milliseconds: 50));

      // 3. Disminuye grid (AnimatedSize se encarga)
      setState(() {
        isExpanded = false;
      });

      // 4. Luego de la transición, fade-in
      await Future.delayed(const Duration(milliseconds: 300));

      setState(() {
        _isTopSectionVisible = true;
      });

      widget.onExpandChange?.call(false);
    }
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
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
                Opacity(
                  opacity: isExpanded ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !isExpanded,
                    child: Material(
                      color: Colors.transparent,
                      child: InkResponse(
                        onTap: toggleAllItemsView,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        radius: 24,
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkResponse(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        isScrollControlled: true,
                        builder: (context) => const PerfilInfoModal(),
                      );
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

          const SizedBox(height: 40),

          // Botón de agregar
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: showTopSection
                ? AnimatedOpacity(
              opacity: _isTopSectionVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: TopSectionHome(
                firstName: firstName,
                onAddLock: showAddLockDialog,
                onNavigateTo: widget.onNavigateTo,
              ),
            )
                : const SizedBox.shrink(),
          ),


          // Grid
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: StreamBuilder<List<Lock>>(
                stream: lockController.obtenerLocks(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      currentLocks.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    currentLocks = snapshot.data!;
                    lockController.inicializarEstadoDispositivos(currentLocks);
                    lockController.iniciarVerificacionPeriodica(currentLocks);
                  }

                  if (currentLocks.isEmpty) {
                    return const Center(
                        child: Text("No hay candados registrados"));
                  }

                  return LockGridScreen(
                    locks: currentLocks,
                    isExpanded: isExpanded,
                    onToggle: toggleAllItemsView,
                    lockController: lockController,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}