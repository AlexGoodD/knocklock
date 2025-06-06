import '../core/imports.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  bool _showBottomBar = true;

  final LockController _lockController = LockController();

  @override
  void initState() {
    super.initState();
    _lockController.iniciarChequeoDesbloqueo();
  }

  @override
  void dispose() {
    _lockController.detenerChequeoDesbloqueo();
    super.dispose();
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onExpandChange: (isExpanded) {
          setState(() {
            _showBottomBar = !isExpanded;
          });
        },
        onNavigateTo: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      const LogsScreen(),
      const SecurityScreen(),
      const SettingsScreen(),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.of(context).backgroundTop,
            AppColors.of(context).backgroundBottom,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: AnimatedSlide(
          offset: _showBottomBar ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: _showBottomBar ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: BottomBar(
              currentIndex: _selectedIndex,
              onTap: _onTap,
            ),
          ),
        ),
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}