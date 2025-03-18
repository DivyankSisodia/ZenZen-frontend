// ignore_for_file: deprecated_member_use

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zenzen/config/app_colors.dart';
import 'package:zenzen/config/size_config.dart';
import 'package:zenzen/utils/theme.dart';

import '../../../config/constants.dart';
import '../../../config/responsive.dart';
import '../../../data/failure.dart';
import '../../docs/model/document_model.dart';
import '../../docs/view-model/doc_viewmodel.dart';
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(docViewmodelProvider.notifier).getAllDocuments();
    });
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
                              child: const AnimatedTab(),
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
          child: Consumer(
            builder: (context, ref, child) {
              final docState = ref.watch(docViewmodelProvider);

              // Use a separate loading state to prevent premature updates
              return docState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (error, stack) => Center(
                  child: Text(
                    (error is ApiFailure) ? error.error : 'An error occurred',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                data: (documents) => _buildDocumentGrid(documents),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildDocumentGrid(List<DocumentModel> documents) {
    if (documents.isEmpty) {
      return const Center(child: Text('No documents found'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the number of columns based on available width
        const double itemWidth = 220; // Target width for each item
        int crossAxisCount;

        if (Responsive.isDesktop(context)) {
          crossAxisCount = max(2, constraints.maxWidth ~/ itemWidth);
        } else if (Responsive.isTablet(context)) {
          crossAxisCount = max(2, constraints.maxWidth ~/ itemWidth);
        } else {
          crossAxisCount = max(1, constraints.maxWidth ~/ itemWidth);
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            return _buildDocumentCard(context, document);
          },
        );
      },
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentModel document) {
    final formattedDate = DateFormat('MMM d, yyyy').format(document.createdAt);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          // Handle document selection/opening
          if (document.id != null) {
            context.goNamed(
              RoutesName.doc,
              pathParameters: {'id': document.id!},
              extra: document.title,
            );
          } else {
            // Handle the case where document.id is null
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.description, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Created: $formattedDate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${document.users.length} users',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  document.isPrivate
                      ? Icon(Icons.lock, size: 16, color: Colors.grey[600])
                      : Icon(Icons.public, size: 16, color: Colors.grey[600]),
                ],
              ),
            ],
          ),
        ),
      ),
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
