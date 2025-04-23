import '../core/imports.dart';

class LockGridScreen extends StatelessWidget {
  final List<Lock> locks;

  const LockGridScreen({super.key, required this.locks});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Locks vinculados",
                style: AppTextStyles.HelperPrimaryStyle,
              ),
              Row(
                children: [
                  Text(
                    "Ver todos",
                    style: AppTextStyles.HelperSecondaryStyle,
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.arrow_forward, size: 16),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0),
            child: GridView.builder(
              clipBehavior: Clip.none,
              itemCount: locks.length > 4 ? 4 : locks.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 30,
                mainAxisSpacing: 30,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final lock = locks[index];
                return LockItem(name: lock.name, ip: lock.ip, lock: lock);
              },
            ),
          ),
        ),
      ],
    );
  }
}