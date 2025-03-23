import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF000000);
  static const Color backgroundDetail = Color(0xFFEEF3CB);
  static const Color primaryText = Color(0xFFEEF3CB);
  static const Color secondaryText = Colors.black;
  static const Color buttonBackground = Color(0xFFEEF3CB);
  static const Color backgroundLockItem = Colors.black;
  static const Color text1LockItem = Color(0xFFEEF3CB);
  static const Color text2LockItem = Color(0xFF8A8A8A);
  static const Color confirmTextButton = Colors.black;
  static const Color confirmBackgroundButton = Color(0xFFEEF3CB);
  static const Color cancelTextButton = Colors.black;
}

class AppTextStyles {
  static const TextStyle appBarTextStyle = TextStyle(color: AppColors.primaryText, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 27);
  static const TextStyle appBarSecondaryTextStyle = TextStyle(color: AppColors.secondaryText, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 27);
  static const TextStyle dialogTitleTextStyle = TextStyle(color: AppColors.secondaryText, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 25);
  static const TextStyle dialogLabelTextStyle = TextStyle(color: AppColors.secondaryText, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 18);
  static const TextStyle dialogInputTextStyle = TextStyle(color: AppColors.secondaryText, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 15);
  static const TextStyle primaryTextStyle = TextStyle(color: AppColors.primaryText, fontFamily: 'Roboto',);
  static const TextStyle secondaryTextStyle = TextStyle(color: AppColors.secondaryText, fontFamily: 'Roboto',);
}