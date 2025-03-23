import '../imports.dart';

class LockItem extends StatelessWidget {
  final String name;
  final String ip;
  final Lock lock;

  LockItem({required this.name, required this.ip, required this.lock});

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
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundLockItem,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Colors.transparent, // Color del borde
            width: 2.0, // Ancho del borde
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.0,
              height: 40.0,
              decoration: BoxDecoration(
                color: AppColors.backgroundDetail,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(Icons.lock, color: AppColors.backgroundLockItem),
            ),
            SizedBox(width: 16.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text1LockItem,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  ip,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: AppColors.text2LockItem,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}