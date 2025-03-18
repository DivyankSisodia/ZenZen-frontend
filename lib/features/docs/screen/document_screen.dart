import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:zenzen/config/app_colors.dart';
import 'package:zenzen/config/app_images.dart';
import 'package:zenzen/config/responsive.dart';
import 'package:zenzen/config/size_config.dart';
import 'package:zenzen/data/local/hive_models/local_user_model.dart';
import 'package:zenzen/features/docs/repo/socket_repo.dart';
import 'package:zenzen/features/docs/widget/editor_widget.dart';
import 'package:zenzen/utils/theme.dart';

import '../../auth/login/viewmodel/auth_viewmodel.dart';
import '../view-model/doc_viewmodel.dart';

class NewDocumentScreen extends ConsumerStatefulWidget {
  final String? title;
  final String id;
  const NewDocumentScreen({super.key, required this.id, this.title});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewDocumentScreenState();
}

class _NewDocumentScreenState extends ConsumerState<NewDocumentScreen> {
  final TextEditingController _titleController = TextEditingController();
  bool _isEmpty = false;
  String _documentContent = '';
  User? currentuser;

  SocketRepository repository = SocketRepository();

  @override
  void initState() {
    super.initState();

    getCurrentUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(docViewmodelProvider.notifier).getDocumentInfo(widget.id);
    });

    widget.title != null ? _titleController.text = widget.title! : null;

    _titleController.addListener(() {
      if (_titleController.text.isEmpty) {
        setState(() {
          _isEmpty = true;
        });
      } else {
        setState(() {
          _isEmpty = false;
        });
      }
    });

    // join document room
    repository.joinDocument({
      'documentId': widget.id,
      'userId': currentuser!.id,
    });
  }

  void getCurrentUser() async {
    final hiveService = ref.read(userDataProvider);
    final user = hiveService.userBox.get('currentUser');
    if (mounted) {
      setState(() {
        currentuser = user;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose();
    repository.leaveDocument({
      'documentId': widget.id,
      'userId': currentuser!.id,
    });
    repository.disconnect();
  }

  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(docViewmodelProvider);

    SizeConfig().init(context);

    // Calculate content width based on device type
    final contentWidth = Responsive.isDesktop(context)
        ? SizeConfig.screenWidth * 0.7
        : SizeConfig.screenWidth;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: SizedBox(
          height: SizeConfig.screenHeight,
          width: contentWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Material(
                elevation: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  height: SizeConfig.blockSizeVertical * 10,
                  width: SizeConfig.screenWidth,
                  color: AppColors.lightGrey,
                  child: Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Responsive.isMobile(context)
                                  ? Image.asset(
                                      AppImages.projectSmall,
                                    )
                                  : Image.asset(
                                      AppImages.projectLarge,
                                    ),
                              const Gap(20),
                              SizedBox(
                                width: Responsive.isMobile(context) ? 180 : 220,
                                child: TextField(
                                  style: AppTheme.textSmall(context),
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    enabledBorder: _isEmpty
                                        ? const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                        : InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.only(left: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: const EdgeInsets.all(20),
                            height: 80,
                            width: 120,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock,
                                  color: AppColors.white,
                                ),
                                const Gap(10),
                                AutoSizeText(
                                  'Share',
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: docState.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Text('Error: ${error.toString()}'),
                  data: (documents) {
                    if (documents.isNotEmpty) {
                      final doc = documents.first;
                      if (doc.document.isNotEmpty) {
                        _documentContent =
                            doc.document[0] as String; // Ensure it's not null
                      } else {
                        _documentContent =
                            ''; // Default content if document is empty
                      }
                      // Update content only once
                      return DocumentEditor(
                        repository: repository,
                        user: currentuser, 
                        documentId: widget.id, 
                        initialContent: _documentContent.isNotEmpty ? _documentContent : '',
                        key: ValueKey(_documentContent),
                      );
                    }
                    return const Center(child: Text('No document found'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
