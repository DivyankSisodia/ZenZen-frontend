import 'package:flutter/material.dart';

import '../../config/constants/app_colors.dart';
import '../../config/constants/responsive.dart';
import '../../features/dashboard/home/widget/header_action_item.dart';
import '../theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState>? drawerKey;

  const CustomAppBar({super.key, this.drawerKey});

  @override
  Widget build(BuildContext context) {
    return Responsive.isDesktop(context)
        ? const PreferredSize(
            preferredSize: Size.zero,
            child: SizedBox(),
          )
        : AppBar(
            backgroundColor: AppColors.lightGrey.withOpacity(0.2),
            elevation: 0,
            leading: Responsive.isMobile(context)
                ? IconButton(
                    onPressed: () {
                      drawerKey?.currentState?.openDrawer();
                    },
                    icon: Icon(
                      Icons.menu,
                      color: AppColors.getIconsColor(context),
                    ),
                  )
                : const SizedBox.shrink(),
            centerTitle: false,
            title: !Responsive.isDesktop(context)
                ? Text(
                    'ZenZen',
                    style: AppTheme.textTitleLarge(context),
                  )
                : null,
            actions: const [
              HeaderActionItems(),
            ],
          );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
