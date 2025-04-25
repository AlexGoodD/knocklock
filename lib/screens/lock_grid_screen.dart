import '../core/imports.dart';

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
                style: AppTextStyles.HelperPrimaryStyle,
              ),
              AnimatedOpacity(
                opacity: isExpanded ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: IgnorePointer(
                  ignoring: isExpanded,
                  child: GestureDetector(
                    onTap: onToggle,
                    child: Row(
                      children: [
                        Text("Ver todos", style: AppTextStyles.HelperSecondaryStyle),
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
              itemCount: isExpanded ? locks.length : (locks.length > 4 ? 4 : locks.length),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final lock = locks[index];
                return LockItem(
                  name: lock.name,
                  ip: lock.ip,
                  lock: lock,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}