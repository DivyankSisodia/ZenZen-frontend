import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zenzen/features/dashboard/projects/view-model/project_viewmodel.dart';
import 'package:zenzen/utils/common/custom_searchbar.dart';

import '../../../../config/constants/responsive.dart';
import '../../../../config/constants/size_config.dart';
import '../../../../utils/common/custom_appbar.dart';
import '../../../../utils/common/custom_divider.dart';
import '../../home/widget/side_drawer_menu.dart';
import '../widgets/project_list_widget.dart';

class ProjectListScreen extends ConsumerStatefulWidget {
  const ProjectListScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends ConsumerState<ProjectListScreen> {
  final GlobalKey<ScaffoldState> drawerKey = GlobalKey();
  final TextEditingController searchController = TextEditingController();

  bool isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(projectViewModelProvider.notifier).getProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      key: drawerKey,
      drawer: SizedBox(
        width: SizeConfig.screenWidth / 2,
        child: Responsive.isMobile(context) ? const SideDrawerMenu() : null,
      ),
      appBar: CustomAppBar(drawerKey: drawerKey),
      body: SafeArea(
        child: Column(
          children: [
            VoiceSearchBar(
              key: const Key('project_search_bar'),
              controller: searchController,
              onTap: () {
                debugPrint('Search tapped');
              },
              onSearch: (value) {
                debugPrint('Search submitted: $value');
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
                        title: 'Projects',
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

                      isGridView
                          ? Center(
                              child: Text('GridView'),
                            )
                          : ProjectListWidget()
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
