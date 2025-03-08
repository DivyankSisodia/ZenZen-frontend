// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zenzen/config/app_colors.dart';
import 'package:zenzen/config/responsive.dart';
import 'package:zenzen/utils/common/custom_textfield.dart';

class HeaderActionItems extends StatefulWidget {
  const HeaderActionItems({super.key});

  @override
  State<HeaderActionItems> createState() => _HeaderActionItemsState();
}

class _HeaderActionItemsState extends State<HeaderActionItems> {
  late FocusNode focusNode;
  late TextEditingController controller;
  late String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.nightlight,
              color: AppColors.surface,
            ),
          ),
        ],
      ),
    );
  }
}
