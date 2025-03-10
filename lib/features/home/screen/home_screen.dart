import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:zenzen/config/app_colors.dart';
import 'package:zenzen/config/size_config.dart';
import 'package:zenzen/utils/theme.dart';

import '../../../config/responsive.dart';
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

                  // Content area - FIXED: Expanded ListView
                  // In your HomeScreen class, modify the Wrap section:
                  Expanded(
                    flex: Responsive.isMobile(context) ? 4 : 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: LayoutBuilder(builder: (context, constraints) {
                        // Calculate responsive card width based on available space
                        double cardWidth = Responsive.isMobile(context)
                            ? constraints.maxWidth / 2 -
                                15 // 2 cards per row on mobile with gap
                            : constraints.maxWidth / 4 -
                                20; // 4 cards per row otherwise

                        return Wrap(
                          alignment: WrapAlignment.start,
                          spacing: 20, // horizontal space between items
                          runSpacing: 20, // vertical space between lines
                          children: List.generate(4, (index) {
                            return HomeFeatureCard(
                              icon: iconList[index],
                              text: featureList[index],
                              isMobile: Responsive.isMobile(context),
                              width: cardWidth, // Pass calculated width
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
        onTap: () {},
        splashColor: AppColors.black.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: widget.isMobile ? 120 : 160,
          width: widget.width,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.1),
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.1),
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
                  color: AppColors.black.withOpacity(0.6),
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
