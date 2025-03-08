import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/config/app_colors.dart';
import 'package:zenzen/config/size_config.dart';

import '../../../config/responsive.dart';
import '../../../utils/providers/theme_provider.dart';
import '../../../utils/theme.dart';
import '../widget/header_action_item.dart';
import '../widget/side_drawer_menu.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    // final toggleTheme = ref.watch(themeProvider.notifier);
    SizeConfig().init(context);
    return Scaffold(
      key: drawerKey,
      drawer:
          SizedBox(width: SizeConfig.screenWidth / 2, child: SideDrawerMenu()),
      appBar: !Responsive.isDesktop(context)
          ? AppBar(
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  drawerKey.currentState!.openDrawer();
                },
                icon: Icon(Icons.menu, color: AppColors.getIconsColor(context)),
              ),
              title: !Responsive.isDesktop(context)
                  ? Text(
                      'ZenZen',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                  : null,
              actions: const [
                HeaderActionItems(),
              ],
            )
          : const PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox(),
            ),
      body: SafeArea(
        child: Row(
          children: [
            if (Responsive.isDesktop(context))
              Expanded(
                flex: 2,
                child: SideDrawerMenu(),
              ),
            Expanded(
              flex: 8,
              child: Container(),
            )
          ],
        ),
      ),
    );
  }
}
