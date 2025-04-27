import 'package:knocklock_flutter/core/imports.dart';

class ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isSelected;

  const ModeButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isSelected = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 110,
        height: 120,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor
              : AppColors.secondaryBackgroundHelperColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryColor : Colors.white,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 2.0)
                    : null,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: AppTextStyles.HelperPrimaryStyle.copyWith(
                color: isSelected ? Colors.white : AppColors.primaryColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}