import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../config/constants/app_colors.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    // Create your base theme
    final baseTheme = ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        titleTextStyle: AppTheme.textTitleLarge(context),
        backgroundColor: AppColors.lightGrey.withOpacity(0.2),
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.getIconsColor(context),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'SpaceGrotesk',
          fontSize: 36,
          fontWeight: FontWeight.w900,
          color: AppColors.black,
        ),
        // Other text styles...
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

    // Add the PullDownButton extension to the light theme
    return baseTheme.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        // PullDownButton theme extension for light mode
        PullDownButtonTheme(
          
          itemTheme: PullDownMenuItemTheme(
            textStyle: TextStyle(
              color: AppColors.primary,
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
            ),
            iconActionTextStyle: TextStyle(
              color: AppColors.primary,
              fontFamily: 'SpaceGrotesk',
              fontSize: 12,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
            ),
            subtitleStyle: TextStyle(
              color: AppColors.primary,
              fontFamily: 'SpaceGrotesk',
              fontSize: 12,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
            ),
            destructiveColor: Colors.red,
          ),
          routeTheme: PullDownMenuRouteTheme(
            backgroundColor: Colors.white,
          ),
          titleTheme: PullDownMenuTitleTheme(
            style: TextStyle(
              color: AppColors.lightGrey,
              fontFamily: 'SpaceGrotesk',
              fontSize: 14,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // Add other package extensions as needed
        SkeletonizerConfigData(),
      ],
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    final baseTheme = ThemeData(
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

    // extensions for dark mode
    return baseTheme.copyWith(
      extensions: <ThemeExtension<dynamic>>[
        // PullDownButton theme extension for light mode
        PullDownButtonTheme(
          // dividerTheme: PullDownMenuDividerTheme(
          //   dividerColor: Colors.white
          // ),
          itemTheme: PullDownMenuItemTheme(
            textStyle: TextStyle(
              color: AppColors.lightGrey,
              fontFamily: 'SpaceGrotesk',
              fontSize: 16,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
            ),
            iconActionTextStyle: TextStyle(
              color: AppColors.lightGrey,
              fontFamily: 'SpaceGrotesk',
              fontSize: 12,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
            ),
            subtitleStyle: TextStyle(
              color: AppColors.lightGrey,
              fontFamily: 'SpaceGrotesk',
              fontSize: 12,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
            ),
            destructiveColor: Colors.red,
          ),
          routeTheme: PullDownMenuRouteTheme(
            backgroundColor: Colors.black,
          ),
          titleTheme: PullDownMenuTitleTheme(
            style: TextStyle(
              color: AppColors.lightGrey,
              fontFamily: 'SpaceGrotesk',
              fontSize: 14,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // Add other package extensions as needed
        SkeletonizerConfigData.dark(),
      ],
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
        color: AppColors.lightGrey,
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
        color: AppColors.lightGrey,
      );
    }
  }

  static TextStyle largeBodyTheme(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 36,
        fontWeight: FontWeight.w900,
        color: AppColors.white,
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
        color: AppColors.white,
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

  static TextStyle tinyText(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.light) {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
      );
    } else {
      return TextStyle(
        fontFamily: 'SpaceGrotesk',
        fontSize: 12,
        fontWeight: FontWeight.w400,
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
        color: AppColors.black,
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
        color: AppColors.primary,
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

  static TextStyle misc1(BuildContext context){
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
        color: AppColors.primary,
      );
    }
  }
}
