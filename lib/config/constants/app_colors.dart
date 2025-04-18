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
      return AppColors.black.withOpacity(0.9);
    } else {
      return AppColors.white;
    }
  }

  static Color getNegativeBackgroundColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.white;
    } else {
      return AppColors.black.withOpacity(0.9);
    }
  }

  static Color getDrawerColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.primary;
    } else {
      return AppColors.lightGrey;
    }
  }

  static Color getContainerColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.primary;
    } else {
      return AppColors.white;
    }
  }

  static ButtonStyle getButtonStyle(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 10,
            ),
          )
        : ElevatedButton.styleFrom(
            elevation: 2,
            backgroundColor: AppColors.lightGrey,
            foregroundColor: AppColors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 10,
            ),
          );
  }

  static Color shadowColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.lightGrey.withOpacity(0.5);
    } else {
      return AppColors.primary.withOpacity(0.5);
    }
  }

  static Color getTextColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.white;
    } else {
      return AppColors.black;
    }
  }

  static Color getButtonTextColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.black;
    } else {
      return AppColors.black;
    }
  }

  static Color getIconsColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.white;
    } else {
      return AppColors.black;
    }
  }

  static Color lightContainerColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.primary.withOpacity(0.4);
    } else {
      return AppColors.white;
    }
  }

  static Color misc1(BuildContext context){
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.black.withOpacity(0.8);
    } else {
      return AppColors.primary;
    }
  }
}
