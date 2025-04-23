import 'package:knocklock_flutter/core/imports.dart';

class LatestLogCard extends StatelessWidget {
  final VoidCallback onPressed;

  const LatestLogCard({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: AppColors.backgroundHelperColor,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primaryColor,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Último acceso: 10:42 am',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Desde: Casa (192.168.1.80)',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primaryColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}