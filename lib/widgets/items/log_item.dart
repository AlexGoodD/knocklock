import 'package:knocklock_flutter/core/imports.dart';
import 'package:intl/intl.dart';

class LogCard extends StatelessWidget {
  final AccessLog log;
  final Lock lock;

  const LogCard({super.key, required this.log, required this.lock});

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
          padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 15),
          child: Row(
            children: [
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${lock.name} (${lock.ip})',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.primaryColor,
                          size: 12,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${log.timestamp.day} de ${_getMonthName(log.timestamp.month)} del ${log.timestamp.year}, ${DateFormat('h:mm a').format(log.timestamp)}',
                          style: AppTextStyles.HelperItemsSecondaryStyle,
                        ),
                        const Spacer(),
                        StatusLog(isSuccess: log.estado == 'Acceso correcto'),
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

  String _getMonthName(int month) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return months[month - 1];
  }
}