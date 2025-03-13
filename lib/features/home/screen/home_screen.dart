// ignore_for_file: deprecated_member_use

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:zenzen/config/app_colors.dart';
import 'package:zenzen/config/size_config.dart';
import 'package:zenzen/utils/theme.dart';

import '../../../config/constants.dart';
import '../../../config/responsive.dart';
import '../widget/feature_card.dart';
import '../widget/header_action_item.dart';
import '../widget/side_drawer_menu.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

  List<String> featureList = [
    "New Document",
    "New Project",
    "Add memebers/friends",
    "Transfer Files/docs",
  ];

  List<IconData> iconList = [
    FontAwesomeIcons.file,
    FontAwesomeIcons.projectDiagram,
    FontAwesomeIcons.userFriends,
    FontAwesomeIcons.fileExport,
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: AppColors.white,
      key: drawerKey,
      drawer: SizedBox(
        width: SizeConfig.screenWidth / 2,
        child: Responsive.isMobile(context) ? const SideDrawerMenu() : null,
      ),
      appBar: !Responsive.isDesktop(context)
          ? AppBar(
              backgroundColor: AppColors.lightGrey.withOpacity(0.2),
              elevation: 0,
              leading: Responsive.isMobile(context)
                  ? IconButton(
                      onPressed: () {
                        drawerKey.currentState!.openDrawer();
                      },
                      icon: Icon(Icons.menu,
                          color: AppColors.getIconsColor(context)),
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
            )
          : const PreferredSize(
              preferredSize: Size.zero,
              child: SizedBox(),
            ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Side Drawer section - only on larger screens
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 2,
                child: SideDrawerMenu(),
              ),
            if (Responsive.isTablet(context))
              const Expanded(
                flex: 3,
                child: SideDrawerMenu(),
              ),

            // Main content area
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  // Tablet divider
                  if (Responsive.isTablet(context))
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Divider(
                        color: AppColors.primary.withOpacity(0.3),
                        thickness: 1,
                      ),
                    ),

                  // Welcome header section with divider
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 10),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Text(
                            "Welcome",
                            style: AppTheme.textTitleLarge(context),
                          ),
                        ),
                        if (Responsive.isMobile(context))
                          Expanded(
                            child: Divider(
                              color: AppColors.primary.withOpacity(0.3),
                              thickness: 2,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const Gap(20),

                  Expanded(
                    flex: Responsive.isMobile(context) ? 4 : 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LayoutBuilder(builder: (context, constraints) {
                        double cardWidth = Responsive.isMobile(context)
                            ? constraints.maxWidth / 2 - 15
                            : constraints.maxWidth / 4 - 20;

                        return Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 20,
                          runSpacing: 20,
                          children: List.generate(4, (index) {
                            return HomeFeatureCard(
                              onTap: () {
                                switch (index) {
                                  case 0:
                                    // Navigator.pushNamed(context, AppRouter.newDocument);
                                    context.pushNamed(RoutesName.doc,
                                        extra: '123');
                                    break;
                                  case 1:
                                    // Navigator.pushNamed(context, AppRouter.newProject);
                                    break;
                                  case 2:
                                    // Navigator.pushNamed(context, AppRouter.addMembers);
                                    break;
                                  case 3:
                                    // Navigator.pushNamed(context, AppRouter.transferFiles);
                                    break;
                                  default:
                                    // Navigator.pushNamed(context, AppRouter.newDocument);
                                    break;
                                }
                              },
                              icon: iconList[index],
                              text: featureList[index],
                              isMobile: Responsive.isMobile(context),
                              width: cardWidth,
                            );
                          }),
                        );
                      }),
                    ),
                  ),
                  const Gap(20),
                  Expanded(
                    flex: 6,
                    child: SizedBox(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 10),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: Text(
                                    "All Folders",
                                    style: AppTheme.textTitleLarge(context),
                                  ),
                                ),
                                if (Responsive.isMobile(context))
                                  Expanded(
                                    child: Divider(
                                      color: AppColors.primary.withOpacity(0.3),
                                      thickness: 2,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 10,
                              ),
                              child: AnimatedTab(),
                            ),
                          ),
                          const Gap(20),
                          // Container(
                          //   height: 500,
                          // ),
                          // Container(
                          //   height: 500,
                          // ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class AnimatedTab extends ConsumerStatefulWidget {
  const AnimatedTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnimatedTabState();
}

class _AnimatedTabState extends ConsumerState<AnimatedTab>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<String> _tabLabels = [
    'Recent',
    'Favorites',
    'Shared',
    'External',
    'Archived'
  ];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this, // TickerProviderStateMixin supports multiple tickers
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (_selectedIndex != index) {
      _animationController.reset();
      _animationController.forward();

      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Responsive.isMobile(context)
              ? SizeConfig.screenWidth
              : Responsive.isTablet(context)
                  ? SizeConfig.screenWidth / 1.5
                  : SizeConfig.screenWidth / 2.5,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
          ),
          child: Row(
            children: List.generate(
              _tabLabels.length,
              (index) => _buildTabItem(index),
            ),
          ),
        ),
        const Gap(12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            )),
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text('Content for ${_tabLabels[_selectedIndex]}'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(int index) {
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : AppColors.surface,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            border: isSelected
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.3), width: 2)
                : null,
          ),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: isSelected
                  ? AppTheme.textSmall(context).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    )
                  : AppTheme.textSmall(context),
              child: Text(_tabLabels[index]),
            ),
          ),
        ),
      ),
    );
  }
}
