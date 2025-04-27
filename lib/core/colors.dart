import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundTop = Color(0xFFFFFFFF);
  static const Color backgroundBottom = Color(0xFFF0F7FF);
  static const Color backgroundHelperColor = Color(0xFFFFFFFF);
  static const Color secondaryBackgroundHelperColor = Color(0xFFFCFCFC);
  static const Color primaryColor = Color(0xFF000000);
  static const Color secondaryColor = Color(0xFF939393);

  static const Color errorTextColor = Color(0xFFFE7474);
  static const Color errorBackgroundColor = Color(0xFFFFEDED);

  static const Color successTextColor = Color(0xFF00AA28);
  static const Color successBackgroundColor = Color(0xFFEDFFEF);

  static const Color warningBackgroundColor = Color(0xFFFFFFF1);
  static const Color warningTextColor = Color(0xFFCEA100);

  static const Color HelperBorderColor = Color(0xFFEFEFEF);
  static const Color trueConnectionColor = Color(0xFF00A500);
  static const Color falseConnectionColor = Color(0xFFA50003);

  // Viejos colores
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

  static const TextStyle primaryTextStyle = TextStyle(color: AppColors.primaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.bold, fontSize: 22);
  static const TextStyle secondaryTextStyle = TextStyle(color: AppColors.secondaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 15);

  static const TextStyle lockItemTitleStyle = TextStyle(color: AppColors.primaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 15);
  static const TextStyle lockItemDescriptionStyle = TextStyle(color: AppColors.primaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12);

  static const TextStyle HelperPrimaryStyle = TextStyle(color: AppColors.primaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 18);
  static const TextStyle HelperSecondaryStyle = TextStyle(color: AppColors.primaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12);

  static const TextStyle sectionPrimaryStyle = TextStyle(color: AppColors.primaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 22);
  static const TextStyle sectionSecondaryStyle = TextStyle(color: AppColors.secondaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 15);

  static const TextStyle HelperItemsPrimaryStyle = TextStyle(color: AppColors.primaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 18);
  static const TextStyle HelperItemsSecondaryStyle = TextStyle(color: AppColors.secondaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12);

  static const TextStyle primaryModalStyle = TextStyle(color: AppColors.primaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 15.5);
  static const TextStyle secondaryModalStyle = TextStyle(color: AppColors.secondaryColor, fontFamily: 'Roboto', fontWeight: FontWeight.w500, fontSize: 12);





  // Viejos estilos
  static const TextStyle appBarTextStyle = TextStyle(color: AppColors.primaryText, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 27);
  static const TextStyle appBarSecondaryTextStyle = TextStyle(color: AppColors.secondaryText, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 27);
  static const TextStyle dialogTitleTextStyle = TextStyle(color: AppColors.secondaryText, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 25);
  static const TextStyle dialogLabelTextStyle = TextStyle(color: AppColors.secondaryText, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 18);
  static const TextStyle dialogInputTextStyle = TextStyle(color: AppColors.secondaryText, fontFamily: 'Roboto', fontWeight: FontWeight.w900, fontSize: 15);
}