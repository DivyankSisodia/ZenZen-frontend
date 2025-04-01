import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/config/constants/app_images.dart';
import 'package:zenzen/config/router/constants.dart';
import 'package:zenzen/config/constants/responsive.dart';
import 'package:zenzen/config/constants/size_config.dart';
import 'package:zenzen/data/local_data.dart';
import 'package:zenzen/utils/providers/selected_screen_provider.dart';
import '../../../../data/local/provider/hive_provider.dart';
import '../../../../utils/theme.dart';

class SideDrawerMenu extends ConsumerStatefulWidget {
  const SideDrawerMenu({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SideDrawerMenuState();
}

class _SideDrawerMenuState extends ConsumerState<SideDrawerMenu> {
  bool _isProfileExpanded = true;

  final List<String> _menuItems = [
    "Home",
    "Documents",
    "Projects",
    "Messages",
    "Contact Us",
  ];

  void _onMenuItemTap(int index) {
    // setState(() {
    //   _selectedIndex = index;
    // });

    ref.watch(selectedScreenProvider.notifier).state = index;

    // Perform actions based on the selected menu item
    switch (index) {
      case 0:
        // Navigate to Home
        context.goNamed(RoutesName.home);
        print('Home');
        break;
      case 1:
        // Navigate to Documents
        context.goNamed(RoutesName.allDocs);
        print('Documents');
        break;
      case 2:
        // Navigate to Projects
        context.goNamed(RoutesName.allProjects);
        print('Projects');
        break;
      case 3:
        // Navigate to Messages
        // Navigator.pushNamed(context, '/messages');
        print('Messages');
        break;
      case 4:
        // Open Contact Us page
        // Navigator.pushNamed(context, '/contact');
        print('Contact Us');
        break;
      default:
        break;
    }
  }

  void _toggleProfileExpansion() {
    setState(() {
      _isProfileExpanded = !_isProfileExpanded;
    });
  }

  List<String> icons = [
    AppImages.homeLight,
    AppImages.docLight,
    AppImages.folderLight,
    AppImages.messageLight,
    AppImages.menuLight
  ];

  // List<String> darkIcons = [
  //   AppImages.homeDark,
  //   AppImages.docDark,
  //   AppImages.folderDark,
  //   AppImages.messageDark,
  //   AppImages.menuDark
  // ];

  TokenManager tokenManager = TokenManager();

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final hiveService = ref.watch(userDataProvider);
    final currentUser = hiveService.userBox.get('currentUser');
    final isLowHeight = MediaQuery.of(context).size.height < 600;

    return Drawer(
      backgroundColor: AppColors.getDrawerColor(context),
      shadowColor: const Color.fromARGB(255, 237, 237, 237),
      elevation: 5,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.getBackgroundColor(context),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 20),
            // User Profile Section - Collapsible
            GestureDetector(
              onTap: _toggleProfileExpansion,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(isLowHeight ? 8 : 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.getDrawerColor(context),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(-10, 10),
                      color: AppColors.black.withOpacity(0.4),
                      blurRadius: 5,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: isLowHeight ? 20 : 30,
                                backgroundColor:
                                    AppColors.getIconsColor(context),
                                child: Text(
                                  currentUser!.avatar
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: isLowHeight
                                      ? AppTheme.buttonText(context)
                                          .copyWith(fontSize: 14)
                                      : AppTheme.buttonText(context),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  currentUser.userName,
                                  style: isLowHeight
                                      ? AppTheme.textMedium(context)
                                          .copyWith(fontSize: 14)
                                      : AppTheme.textMedium(context),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          _isProfileExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: AppColors.getIconsColor(context),
                        ),
                      ],
                    ),
                    if (_isProfileExpanded) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: FaIcon(
                              FontAwesomeIcons.envelope,
                              color: AppColors.getIconsColor(context),
                              size: isLowHeight ? 16 : 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 6,
                            child: SizedBox(
                              width: 120,
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                currentUser.email,
                                style: AppTheme.textFieldBodyTheme(context)
                                    .copyWith(
                                  fontSize: isLowHeight ? 12 : 14,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.copy_all,
                                size: isLowHeight ? 16 : 20,
                                color: AppColors.getIconsColor(context),
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          )
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: isLowHeight ? 8 : 10),

            // Menu Items
            Consumer(
              builder: (context, ref, child) {
                final selectedIndex = ref.watch(selectedScreenProvider);
                return Padding(
                  padding: EdgeInsets.all(isLowHeight ? 10 : 20),
                  child: Column(
                    children: [
                      for (var i = 0; i < 4; i++)
                        MenuItem(
                          icon: icons[i],
                          title: _menuItems[i],
                          index: i,
                          selectedIndex: selectedIndex,
                          onTap: _onMenuItemTap,
                          isCompact: isLowHeight,
                        ),
                    ],
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Divider(
                color: AppColors.getIconsColor(context),
                thickness: 0.5,
              ),
            ),

            SizedBox(
              height: isLowHeight ? 8 : 20,
            ),

            // Contact Menu
            Consumer(
              builder: (context, ref, child) {
                final selectedIndex0 = ref.watch(selectedScreenProvider);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MenuItem(
                    title: _menuItems[4],
                    index: 4,
                    selectedIndex: selectedIndex0,
                    onTap: _onMenuItemTap,
                    icon: icons[4],
                    isCompact: isLowHeight,
                  ),
                );
              },
            ),

            if (!Responsive.isDesktop(context)) ...[
              SizedBox(height: isLowHeight ? 8 : 10),
              OtherItems(
                color: AppColors.warning,
                title: 'Open in Browser',
                icon: FontAwesomeIcons.firefox,
                style: AppTheme.textLarge(context)
                    .copyWith(fontSize: isLowHeight ? 14 : 16),
                isCompact: isLowHeight,
              ),
            ],

            SizedBox(height: isLowHeight ? 20 : 40),

            // Support and Logout
            OtherItems(
              color: AppColors.getTextColor(context),
              title: 'Support',
              icon: FontAwesomeIcons.question,
              isCompact: isLowHeight,
            ),

            SizedBox(height: isLowHeight ? 8 : 10),

            OtherItems(
              color: AppColors.error,
              title: 'Logout',
              icon: FontAwesomeIcons.signOutAlt,
              isCompact: isLowHeight,
              onTap: (){
                hiveService.userBox.delete('currentUser');
                tokenManager.clearTokens();
                context.goNamed(RoutesName.login);
              },
            ),

            SizedBox(height: isLowHeight ? 20 : 30),
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
  final String icon;
  final bool isCompact;

  const MenuItem({
    super.key,
    required this.title,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
    required this.icon,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () => onTap(index),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color:
              index == selectedIndex ? AppColors.shadowColor(context) : AppColors.lightContainerColor(context),
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        margin: EdgeInsets.only(bottom: isCompact ? 6 : 10),
        padding: EdgeInsets.all(isCompact ? 6 : 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: Image.asset(
                icon,
                color: AppColors.getIconsColor(context),
                height: isCompact ? 20 : 30,
                width: isCompact ? 20 : 30,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: isCompact ? 10 : 20),
            Expanded(
              flex: 7,
              child: Text(
                overflow: TextOverflow.ellipsis,
                title,
                style: index != selectedIndex
                    ? AppTheme.textFieldBodyTheme(context).copyWith(
                        fontSize: isCompact ? 12 : 14,
                      )
                    : AppTheme.textMedium(context).copyWith(
                        fontSize: isCompact ? 12 : 14,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OtherItems extends ConsumerWidget {
  final String title;
  final IconData? icon;
  final Color color;
  final VoidCallback? onTap;
  final TextStyle? style;
  final bool isCompact;

  const OtherItems({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.style,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var width = SizeConfig.blockSizeHorizontal;
    // print('SizeConfig.blockSizeHorizontal: ${SizeConfig.blockSizeHorizontal}');
    // print(width);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(isCompact ? 6 : 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 3,
              child: FaIcon(
                icon,
                color: AppColors.black,
                size: isCompact ? 16 : 20,
              ),
            ),
            SizedBox(width: isCompact ? 5 : 20),
            Expanded(
              flex: 7,
              child: SizedBox(
                width: (isCompact || (width > 6 && width < 9)) ? 90 : 120,
                child: Text(
                  title,
                  style: style ??
                      AppTheme.textLarge(context).copyWith(
                        fontSize: isCompact ? 14 : 16,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
