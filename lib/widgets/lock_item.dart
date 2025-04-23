import '../core/imports.dart';

class LockItem extends StatelessWidget {
  final String name;
  final String ip;
  final Lock lock;

  const LockItem({required this.name, required this.ip, required this.lock});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LockDetailScreen(lock: lock),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
        decoration: BoxDecoration(
          color: AppColors.backgroundHelperColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(Icons.lock, color: AppColors.backgroundHelperColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              ip,
              style: AppTextStyles.lockItemDescriptionStyle,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 0),
            Text(
              name,
              style: AppTextStyles.lockItemTitleStyle,
              textAlign: TextAlign.left,
            ),
            Switch(
              value: true,
              onChanged: (bool value) {
                // Acción cuando cambia
              },
              activeColor: AppColors.backgroundHelperColor,
              activeTrackColor: AppColors.primaryColor,
              inactiveThumbColor: AppColors.backgroundHelperColor,
              inactiveTrackColor: AppColors.secondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}