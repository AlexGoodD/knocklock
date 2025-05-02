import 'package:flutter/material.dart';
import '../../core/colors.dart';

class CircularProfileButton extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onPressed;

  const CircularProfileButton({
    Key? key,
    required this.imageUrl,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: AppColors.helperColor, width: 2), // Borde gris
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/avatars/$imageUrl',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, size: 100, color: Colors.grey); // Icono por defecto
            },
          ),
        ),
      ),
    );
  }
}