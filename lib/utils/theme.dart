import 'package:flutter/material.dart';

import '../config/constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.black,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: AppColors.black,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.primary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.primary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.lightGrey,
        ),
        titleMedium: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.primary.withOpacity(0.7),
        ),
        titleLarge: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.black.withOpacity(0.8),
        ),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.black,
        brightness: Brightness.dark,
      ),
      primaryColor: AppColors.black,
      scaffoldBackgroundColor: AppColors.black.withOpacity(0.9),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.black,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.black,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: AppColors.surface,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.surface,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.surface,
        ),
        bodySmall: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: AppColors.surface,
        ),
        titleMedium: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.surface,
        ),
        titleLarge: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.surface,
        ),
      ),
    );
  }

  static TextStyle introPageTitleStyle(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.black,
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
        color: AppColors.white,
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
        color: AppColors.white,
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
        color: AppColors.primary,
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
        color: AppColors.black,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.white,
      );
    }
  }

  static TextStyle textFieldBodyTheme(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.primary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.lightGrey,
      );
    }
  }

  static TextStyle textMedium(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.lightGrey,
      );
    }
  }

  static TextStyle textSmall(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.lightGrey,
      );
    }
  }

  static TextStyle textLarge(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.lightGrey,
      );
    }
  }

  static TextStyle buttonText(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.surface,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.lightGrey,
      );
    }
  }

  static TextStyle textTitle(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.lightGrey,
      );
    }
  }

  static TextStyle textTitleLarge(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.black.withOpacity(0.8),
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.surface,
      );
    }
  }

  static TextStyle buttonTheme(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.black.withOpacity(0.8),
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.surface,
      );
    }
  }
}
