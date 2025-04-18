// ignore_for_file: deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/utils/theme.dart';

class HomeFeatureCard extends StatefulWidget {
  final String text;
  final IconData icon;
  final Function? onTap;
  final bool isMobile;
  final double? width;

  const HomeFeatureCard({
    super.key,
    this.text = "Add a new task",
    this.icon = FontAwesomeIcons.plus,
    this.onTap,
    this.isMobile = false,
    this.width,
  });

  @override
  State<HomeFeatureCard> createState() => _HomeFeatureCardState();
}

class _HomeFeatureCardState extends State<HomeFeatureCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => setState(() => _isHovered = true),
      onExit: (event) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: () {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        splashColor: AppColors.shadowColor(context),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: widget.isMobile ? 120 : 160,
          width: widget.width,
          decoration: BoxDecoration(
            color: AppColors.getContainerColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.shadowColor( context),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.shadowColor(context).withOpacity(0.2),
                      blurRadius: 2,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FaIcon(
                  widget.icon,
                  color: AppColors.getIconsColor(context),
                  size: widget.isMobile ? 25 : 30,
                ),
                Gap(widget.isMobile ? 20 : 10),
                AutoSizeText(
                  widget.text,
                  style: AppTheme.textFieldBodyTheme(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
