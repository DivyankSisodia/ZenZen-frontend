import 'package:flutter/material.dart';

class AppColors {
  static Color primary = Colors.grey[700]!;
  static Color secondary = Colors.grey[300]!;
  static Color accent = Colors.blue[400]!;
  static Color error = Colors.red[400]!;
  static Color success = Colors.green[400]!;
  static Color warning = Colors.orange[400]!;
  static Color info = Colors.blue[400]!;
  static Color background = Colors.grey[100]!;
  static Color surface = Colors.grey[200]!;
  static Color onPrimary = Colors.white;
  static Color onSecondary = Colors.black;
  static Color onAccent = Colors.white;
  static Color chatBubble = Colors.green[500]!;

  static Color getBackgroundColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return AppColors.onSecondary;
    } else {
      return AppColors.onPrimary;
    }
  }
}

class AppTheme {
  static TextStyle introPageTitleStyle(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.onPrimary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
    }
  }

  static TextStyle descriptionTextStyle(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.onPrimary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      );
    }
  }

  static TextStyle largeBodyTheme(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: AppColors.onPrimary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
      );
    }
  }

  static TextStyle smallBodyTheme(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.onPrimary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      );
    }
  }

  static TextStyle mediumBodyTheme(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.onPrimary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      );
    }
  }

  static TextStyle textFieldBodyTheme(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.onPrimary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      );
    }
  }
}
