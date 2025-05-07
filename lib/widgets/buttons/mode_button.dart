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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: screenWidth * 0.23,
        height: screenHeight * 0.13,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.of(context).primaryColor
              : AppColors.of(context).secondaryBackgroundHelperColor,
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
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.of(context).primaryColor : AppColors.of(context).modeIconBackgroundColor,
                border: isSelected
                    ? Border.all(color: AppColors.of(context).modeIconColorSelected, width: 2.0)
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
                color: isSelected ? AppColors.of(context).modeIconColorSelected : AppColors.of(context).modeIconColor, size: screenWidth * 0.05,
              ),
            ),
            const SizedBox(height: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: AppTextStyles(context).helperPrimaryStyle.copyWith(
                color: isSelected ? AppColors.of(context).modeBackgroundColorSelected : AppColors.of(context).primaryColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}