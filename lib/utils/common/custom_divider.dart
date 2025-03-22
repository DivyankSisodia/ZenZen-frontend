import 'package:flutter/material.dart';

import '../../config/constants/app_colors.dart';
import '../theme.dart';

class CustomDividerWithText extends StatelessWidget {
  final String? title;
  const CustomDividerWithText({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.lightGrey,
                  Colors.grey[500]!,
                  AppColors.primary,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            title ?? 'ZenZen',
            style: AppTheme.textMedium(context),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  Colors.grey[500]!,
                  AppColors.lightGrey,
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}
