// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/config/constants/size_config.dart';
import 'package:zenzen/utils/common/custom_appbar.dart';
import 'package:zenzen/utils/common/custom_dialogs.dart';
import 'package:zenzen/utils/theme.dart';

import '../../../../config/constants/responsive.dart';
import '../../docs/repo/socket_repo.dart';
import '../widget/animated_tab.dart';
import '../widget/feature_card.dart';
import '../widget/side_drawer_menu.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();

  CustomDialogs customDialogs = CustomDialogs();

  FocusNode focusNode = FocusNode();
  FocusNode focusNode2 = FocusNode();
  TextEditingController controller = TextEditingController();
  TextEditingController controller2 = TextEditingController();

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

  SocketRepository repository = SocketRepository();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.dispose();
    focusNode2.dispose();
    controller.dispose();
    controller2.dispose();
  }

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
      appBar: CustomAppBar(
        drawerKey: drawerKey,
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
              child: SingleChildScrollView(
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

                    const Gap(10),

                    // Feature cards section
                    Padding(
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
                                    customDialogs.createDocCustomDialog(
                                      context,
                                      ref,
                                      'Select Project for which you want to create a document',
                                    );
                                    break;
                                  case 1:
                                    customDialogs.createProjectCustomDialog(
                                      'Create a New Project',
                                      context,
                                      ref,
                                      controller,
                                      focusNode,
                                      'Enter title',
                                      controller2,
                                      focusNode2,
                                      'Enter description',
                                    );
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
                    
                    const Gap(20),
                    
                    // All Folders section
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
                    
                    // AnimatedTab section - use a Container with fixed height
                    SingleChildScrollView(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10,
                        ),
                        child: const AnimatedTab(),
                      ),
                    ),
                    
                    const Gap(20),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}