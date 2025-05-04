import 'package:knocklock_flutter/core/imports.dart';

class OptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;

  const OptionButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.of(context).backgroundHelperColor,
          padding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: AppColors.of(context).helperBorderColor),
          ),
        ).copyWith(
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          splashFactory: NoSplash.splashFactory,
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              width: 35,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.of(context).helperColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.of(context).primaryColor, width: 1),
              ),
              child: Icon(icon, color: AppColors.of(context).primaryColor),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles(context).primaryModalStyle,
                ),
                Text(
                  description,
                  style: AppTextStyles(context).secondaryModalStyle,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}