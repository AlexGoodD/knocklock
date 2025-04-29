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
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 0.1,
        padding: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.HelperBorderColor),
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
              color: AppColors.helperColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: Icon(icon, color: AppColors.primaryColor),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.primaryModalStyle,
              ),
              Text(
                description,
                style: AppTextStyles.secondaryModalStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}