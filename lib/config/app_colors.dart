import 'package:flutter/material.dart';

class AppColors {
  static Color primary = Colors.grey[800]!;
  static Color secondary = Colors.grey[300]!;
  static Color accent = Colors.blue[400]!;
  static Color error = Colors.red[400]!;
  static Color success = Colors.green[400]!;
  static Color warning = Colors.orange[400]!;
  static Color info = Colors.blue[400]!;
  static Color background = Colors.grey[100]!;
  static Color surface = Colors.grey[200]!;
  static Color white = Colors.white;
  static Color black = Colors.black;
  static Color onAccent = Colors.white;
  static Color chatBubble = Colors.green[500]!;
  static Color lightGrey = Colors.grey[300]!;

  static Color getBackgroundColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.black;
    } else {
      return AppColors.white;
    }
  }

  static Color getIconsColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.white;
    } else {
      return AppColors.black;
    }
  }
}
