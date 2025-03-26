import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/features/dashboard/docs/view-model/doc_viewmodel.dart';
import 'package:zenzen/utils/common/custom_appbar.dart';

import '../../../../config/constants/responsive.dart';
import '../../../../config/constants/size_config.dart';
import '../../../../utils/common/custom_divider.dart';
import '../../../../utils/common/custom_menu.dart';
import '../../../../utils/common/custom_searchbar.dart';
import '../../../../utils/theme.dart';
import '../../home/widget/document_card.dart';
import '../../home/widget/side_drawer_menu.dart';

import '../widget/document_list_widget.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  const DocumentScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();
  final TextEditingController searchController = TextEditingController();

  // is grid view or list view
  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(docViewmodelProvider.notifier).getAllDocuments();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final documentsAsync = ref.watch(docViewmodelProvider);
    return Scaffold(
      key: drawerKey,
      drawer: SizedBox(
        width: SizeConfig.screenWidth / 2,
        child: Responsive.isMobile(context) ? const SideDrawerMenu() : null,
      ),
      appBar: CustomAppBar(drawerKey: drawerKey),
      body: SafeArea(
        child: Row(
          children: [
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
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  VoiceSearchBar(
                    controller: searchController,
                    onSearch: (value) {
                      debugPrint('Search submitted: $value');
                      // Implement your search functionality here
                    },
                    onTap: () {
                      debugPrint('Search field tapped');
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            CustomDividerWithText(
                              title: 'Document',
                            ),
                            //
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isGridView = !isGridView;
                                  });
                                },
                                icon: isGridView ? Icon(Icons.list) : Icon(Icons.grid_view),
                              ),
                            ),
              
                            // show all the documents for the user
              
                             documentsAsync.when(
                              data: (documents) {
                                return isGridView
                                  ? GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: documents.length,
                                      itemBuilder: (context, index) {
                                        return DocumentCardWidget(
                                          context: context,
                                          document: documents[index],
                                        );
                                      },
                                    )
                                  : DocumentListWidget(documents: documents);
                              },
                              loading: () => SizedBox(
                                height: 500,
                                child: Skeletonizer(
                                  enabled: true,
                                  enableSwitchAnimation: true,
                                  child: ListView.builder(
                                    itemCount: 6,
                                    padding: const EdgeInsets.all(16),
                                    itemBuilder: (context, index) => Card(
                                      child: ListTile(
                                        title: Text('Item number $index as title'),
                                        subtitle: const Text('Subtitle here'),
                                        trailing: const Icon(
                                          Icons.ac_unit,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              error: (error, stack) => Center(
                                child: Text('Error: $error', style: AppTheme.textMedium(context)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CircularMenu(
        menuItems: const [
          Icons.home,
          Icons.search,
          Icons.settings,
          Icons.favorite,
          Icons.person,
        ],
        mainButtonColor: AppColors.primary,
        itemButtonColor: Colors.white,
        iconColor: AppColors.primary.withOpacity(0.7),
      ),
    );
  }
}
