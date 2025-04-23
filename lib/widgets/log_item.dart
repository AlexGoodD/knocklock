import 'package:knocklock_flutter/core/imports.dart';

class LogCard extends StatelessWidget {

  const LogCard({ super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: AppColors.backgroundHelperColor,
        elevation: 0.1,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Casa (192.168.1.80)',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryColor,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          '22 de abril del 2025, 10:42 am',
                          style: AppTextStyles.HelperItemsSecondaryStyle
                        ),
                        Spacer(),
                        StatusLog(isSuccess: false),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}