import 'package:flutter/material.dart';
import '../../core/colors.dart';

class TokenDisplay extends StatelessWidget {
  final String value;       // El token a mostrar
  final int length;         // Cantidad de cuadros a mostrar
  final TextStyle? textStyle;

  const TokenDisplay({
    super.key,
    required this.value,
    this.length = 6,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final boxWidth = screenWidth / (length + 2);
    final boxHeight = boxWidth * 1.2;

    return SizedBox(
      height: boxHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(length, (index) {
          final char = index < value.length ? value[index] : '';

          return Container(
            width: boxWidth,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: char.isNotEmpty
                  ? AppColors.helperInputColor
                  : AppColors.helperInputColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.helperInputColor,
                width: 1.5,
              ),
            ),
            child: Text(
              char,
              style: textStyle ??
                  const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
        }),
      ),
    );
  }
}