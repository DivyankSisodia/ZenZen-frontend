import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../config/app_colors.dart';

class SocialMediaIcon extends StatelessWidget {
  const SocialMediaIcon({
    super.key,
    required this.text,
    required this.icon,
    this.onTap,
  });

  final String text;
  final IconData icon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Expanded(
      child: InkWell(
        splashColor: AppColors.primary,
        onTap: onTap,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FaIcon(
                icon,
                color: AppColors.primary,
                size: w > 1000 ? 30 : 20,
              ),
              AutoSizeText(
                text,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
