import 'package:knocklock_flutter/core/imports.dart';

class ButtonAddLock extends StatelessWidget {
  final VoidCallback onPressed;

  const ButtonAddLock({required this.onPressed, super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.of(context).primaryColor,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      label: Row(
        children: [
          Text(
            'Agregar',
            style: TextStyle(color: AppColors.of(context).backgroundHelperColor),
          ),
          SizedBox(width: 10),
          Icon(Icons.add_circle_outline, color: AppColors.of(context).backgroundHelperColor),
        ],
      ),
    );
  }
}