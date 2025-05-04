import '../../core/imports.dart';

class LockGridScreen extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onToggle;
  final List<Lock> locks;
  final LockController lockController;

  const LockGridScreen({
    super.key,
    required this.isExpanded,
    required this.onToggle,
    required this.locks,
    required this.lockController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Locks vinculados",
                style: AppTextStyles(context).helperPrimaryStyle,
              ),
              AnimatedOpacity(
                opacity: isExpanded ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: Visibility(
                  visible: !isExpanded,
                  maintainState: true,
                  maintainAnimation: true,
                  maintainSize: true,
                  child: GestureDetector(
                    onTap: onToggle,
                    child: Row(
                      children: [
                        Text("Ver todos", style: AppTextStyles(context).helperSecondaryStyle),
                        const SizedBox(width: 5),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxHeight: 900),
            clipBehavior: Clip.hardEdge,
            decoration: const BoxDecoration(),
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              physics: const BouncingScrollPhysics(),
              itemCount: locks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                if (!isExpanded && index >= 4) {
                  return const SizedBox.shrink(); // Oculta los ítems adicionales sin romper el layout
                }

                final lock = locks[index];
                final isConnectedNotifier = lockController.dispositivosConectados[lock.id] ?? ValueNotifier<bool>(false);

                return ValueListenableBuilder<bool>(
                  valueListenable: isConnectedNotifier,
                  builder: (context, isConnected, child) {
                    return LockItem(
                      key: ValueKey(lock.id),
                      name: lock.name,
                      ip: lock.ip,
                      lock: lock,
                      lockController: lockController,
                    );
                  },
                );
              },
            ),
          ),
        )
      ],
    );
  }
}