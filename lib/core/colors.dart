import 'package:flutter/material.dart';

class AppColors {
  final bool isDark;

  AppColors._(this.isDark);

  factory AppColors.of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AppColors._(brightness == Brightness.dark);
  }

  Color get backgroundTop =>
      isDark ? const Color(0xFF1B232D) : const Color(0xFFFFFFFF);

  Color get backgroundBottom =>
      isDark ? const Color(0xFF1B232D) : const Color(0xFFF0F7FF);

  Color get backgroundHelperColor =>
      isDark ? const Color(0xFF2E3E4F) : const Color(0xFFFFFFFF);

  Color get secondaryBackgroundHelperColor =>
      isDark ? const Color(0xFF2E3E4F) : const Color(0xFFFCFCFC);

  Color get primaryColor =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

  Color get secondaryColor =>
      isDark ? const Color(0xFFBBBBBB) : const Color(0xFF939393);

  Color get thirdColor =>
      isDark ? const Color(0xFF888888) : const Color(0xFF6C6C6C);

  Color get helperColor =>
      isDark ? const Color(0xFF2E2E2E) : const Color(0xFFF6F6F6);

  Color get errorTextColor =>
      isDark ? const Color(0xFFFF8080) : const Color(0xFFFE7474);

  Color get errorBackgroundColor =>
      isDark ? const Color(0xFF330000) : const Color(0xFFFFEDED);

  Color get successTextColor =>
      isDark ? const Color(0xFF80FF80) : const Color(0xFF00AA28);

  Color get successBackgroundColor =>
      isDark ? const Color(0xFF003300) : const Color(0xFFEDFFEF);

  Color get warningBackgroundColor =>
      isDark ? const Color(0xFF2E2E00) : const Color(0xFFFFFFF1);

  Color get warningTextColor =>
      isDark ? const Color(0xFFFFD740) : const Color(0xFFCEA100);

  Color get helperBorderColor =>
      isDark ? const Color(0xFF444444) : const Color(0xFFEFEFEF);

  Color get trueConnectionColor =>
      isDark ? const Color(0xFF00FF00) : const Color(0xFF00A500);

  Color get falseConnectionColor =>
      isDark ? const Color(0xFFFFA500) : const Color(0xFFA50003);

  Color get helperInputColor =>
      isDark ? const Color(0xFF3A3A3A) : const Color(0xFFEFEFEF);

  Color get bottomBarBackground =>
      isDark ? const Color(0xFF242E3B) : const Color(0xFFFFFFFF);

  Color get bottomBarPrimaryItem =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFF000000);

  Color get bottomBarSecondaryItem =>
      isDark ? const Color(0xFF63788B) : const Color(0xFF949494);

  Color get modeIconColor =>
      isDark ? const Color(0xFF577E9D) : const Color(0xFF000000);

  Color get modeIconColorSelected =>
      isDark ? const Color(0xFF577E9D) : const Color(0xFFFFFFFF);

  Color get modeIconBackgroundColor =>
      isDark ? const Color(0xFF2E3E4F) : const Color(0xFFFFFFFF);

  Color get modeIconBorderColor =>
      isDark ? const Color(0xFF435267) : const Color(0xFFFFFFFF);

  Color get modeIconBackgroundColorSelected =>
      isDark ? const Color(0xFF2E3E4F) : const Color(0xFF000000);

  Color get modeBackgroundColor =>
      isDark ? const Color(0xFF2E3E4F) : const Color(0xFFFFFFFF);

  Color get modeBackgroundColorSelected =>
      isDark ? const Color(0xFF2E3E4F) : const Color(0xFFFFFFFF);
}

class AppTextStyles {
  final BuildContext context;
  final AppColors colors;

  AppTextStyles(this.context) : colors = AppColors.of(context);

  TextStyle get primaryTextStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 22,
  );

  TextStyle get secondaryTextStyle => TextStyle(
    color: colors.secondaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );

  TextStyle get lockItemTitleStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w900,
    fontSize: 15,
  );

  TextStyle get lockItemDescriptionStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );

  TextStyle get helperPrimaryStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w900,
    fontSize: 18,
  );

  TextStyle get helperSecondaryStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );

  TextStyle get sectionPrimaryStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 22,
  );

  TextStyle get sectionSecondaryStyle => TextStyle(
    color: colors.secondaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 15,
  );

  TextStyle get helperItemsPrimaryStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w900,
    fontSize: 18,
  );

  TextStyle get helperItemsSecondaryStyle => TextStyle(
    color: colors.secondaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );

  TextStyle get primaryModalStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );

  TextStyle get secondaryModalStyle => TextStyle(
    color: colors.secondaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 12,
  );

  TextStyle get authTextStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w300,
    fontSize: 30,
  );

  TextStyle get authBottomTextStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w300,
    fontSize: 14,
  );

  TextStyle get authButtonTextStyle => TextStyle(
    color: colors.backgroundHelperColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w600,
    fontSize: 18,
  );

  TextStyle get headerLabelTextStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 14,
  );

  TextStyle get sectionAboutTitleTextStyle => TextStyle(
    color: colors.primaryColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 15,
  );

  TextStyle get sectionAboutContentTextStyle => TextStyle(
    color: colors.thirdColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 14,
  );

  TextStyle get titleAlertTextStyle => TextStyle(
    color: AlertColors.titleAlertColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w500,
    fontSize: 16,
  );

  TextStyle get subtitleAlertTextStyle => TextStyle(
    color: AlertColors.subtitleAlertColor,
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
    fontSize: 13,
  );
}

class AlertColors {
  final bool isDark;

  AlertColors(this.isDark);

  factory AlertColors.of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return AlertColors(brightness == Brightness.dark);
  }

  static const Color titleAlertColor = Color(0xFF000000);

  static const Color subtitleAlertColor = Color(0xFF767D79);

  Color get successAlertBackgroundColor =>
      isDark ? const Color(0xFFEBFAF2) : const Color(0xFFEBFAF2);

  Color get successAlertIconColor =>
      isDark ? const Color(0xFF2DA67B) : const Color(0xFF2DA67B);

  Color get successAlertIconBackgroundColor =>
      isDark ? const Color(0xFFC1EED4) : const Color(0xFFC1EED4);

  Color get errorAlertBackgroundColor =>
      isDark ? const Color(0xFFFFE6E7) : const Color(0xFFFFE6E7);

  Color get errorAlertIconColor =>
      isDark ? const Color(0xFFEA574E) : const Color(0xFFEA574E);

  Color get errorAlertIconBackgroundColor =>
      isDark ? const Color(0xFFFFC8BA) : const Color(0xFFFFC8BA);

  Color get warningAlertBackgroundColor =>
      isDark ? const Color(0xFFFFF2DB) : const Color(0xFFFFF2DB);

  Color get warningAlertIconColor =>
      isDark ? const Color(0xFFCBA822) : const Color(0xFFCBA822);

  Color get warningAlertIconBackgroundColor =>
      isDark ? const Color(0xFFFFEAC0) : const Color(0xFFFFEAC0);

  Color get infoAlertBackgroundColor =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

  Color get infoAlertBorderColor =>
      isDark ? const Color(0xFF767D79) : const Color(0xFF767D79);

  Color get infoAlertIconColor =>
      isDark ? const Color(0xFF767D79) : const Color(0xFF767D79);

  Color get infoAlertIconBackgroundColor =>
      isDark ? const Color(0xFFFFFFFF) : const Color(0xFFFFFFFF);

  Color get darkInfoAlertBackgroundColor =>
      isDark ? const Color(0xFFE0E0E0) : const Color(0xFFE0E0E0);

  Color get darkInfoAlertIconColor =>
      isDark ? const Color(0xFF464E52) : const Color(0xFF464E52);

  Color get darkInfoAlertIconBackgroundColor =>
      isDark ? const Color(0xFFC6C8C5) : const Color(0xFFC6C8C5);
}