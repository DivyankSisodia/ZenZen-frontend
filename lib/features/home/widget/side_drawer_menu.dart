// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:zenzen/config/app_colors.dart';
import 'package:zenzen/config/responsive.dart';
import '../../../data/local/provider/user_provider.dart';
import '../../../utils/theme.dart';

class SideDrawerMenu extends ConsumerWidget {
  SideDrawerMenu({super.key});

  int _selectedIndex = 0;

  final List<String> _menuItems = [
    "Home",
    "Settings",
    "About",
    "Help",
    "Logout"
  ];

  void _onMenuItemTap(int index) {
    _selectedIndex = index;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiveService = ref.watch(userDataProvider);
    final currentUser = hiveService.userBox.get('currentUser');
    return Drawer(
      shadowColor: Colors.grey,
      elevation: 5,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo Section
            Container(
              alignment: Alignment.topCenter,
              padding: const EdgeInsets.all(20),
              child: !Responsive.isMobile(context)
                  ? Image.asset(
                      color: Colors.white,
                      "assets/images/logo-no-background.png",
                      height: 300,
                      width: 300,
                      fit: BoxFit.contain,
                    )
                  : Image.asset(
                      color: Colors.white,
                      "assets/images/logo-no-background.png",
                      height: 140,
                      width: 140,
                      fit: BoxFit.contain,
                    ),
            ),
            const Gap(10),
            // Menu Items Section
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  for (var i = 0; i < _menuItems.length; i++)
                    MenuItem(
                      title: _menuItems[i],
                      index: i,
                      selectedIndex: _selectedIndex,
                      onTap: _onMenuItemTap,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuItem extends ConsumerWidget {
  final String title;
  final int index;
  final int selectedIndex;
  final Function(int) onTap;
  // final IconData icon;

  const MenuItem({
    super.key,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    // required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        decoration: BoxDecoration(
          color:
              index == selectedIndex ? AppColors.lightGrey : AppColors.onAccent,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(
            color:
                index == selectedIndex ? AppColors.primary : AppColors.onAccent,
            width: 2,
          ),
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.document_scanner,
              color: index == selectedIndex
                  ? AppColors.primary
                  : AppColors.onAccent,
              size: 20,
            ),
            const Gap(20),
            Text(
              title,
              style: AppTheme.textFieldBodyTheme(context),
            ),
          ],
        ),
      ),
    );
  }
}
