
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart' show Gap;
import 'package:universal_html/html.dart' as html;
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/config/constants/app_images.dart';
import 'package:zenzen/config/constants/responsive.dart';
import 'package:zenzen/config/constants/size_config.dart';
import 'package:zenzen/data/local/hive_models/local_user_model.dart';
import 'package:zenzen/features/dashboard/docs/repo/socket_repo.dart';
import 'package:zenzen/features/dashboard/docs/widget/editor_widget.dart';
import 'package:zenzen/utils/theme.dart';

import '../../../../data/local/provider/hive_provider.dart';
import '../../../auth/user/view-model/user_view_model.dart';
import '../provider/editor_provider.dart';
import '../view-model/doc_viewmodel.dart';

class NewDocumentScreen extends ConsumerStatefulWidget {
  final String? title;
  final String id;
  const NewDocumentScreen({super.key, required this.id, this.title});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewDocumentScreenState();
}

class _NewDocumentScreenState extends ConsumerState<NewDocumentScreen> with WidgetsBindingObserver {
  final TextEditingController _titleController = TextEditingController();
  bool _isEmpty = false;
  String _documentContent = '';
  LocalUser? currentuser;

  SocketRepository repository = SocketRepository();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    getCurrentUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(docViewmodelProvider.notifier).getDocumentInfo(widget.id);
    });

    updatedTitle();

    joinDocument();

    handleBrowserClose();
  }

  void updatedTitle() {
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
  }

  void handleBrowserClose() {
    html.window.onBeforeUnload.listen((event) {
      // Perform cleanup before the tab is closed
      repository.leaveDocument({
        'documentId': widget.id,
        'userId': currentuser?.id ?? '',
      });
    });
  }

  void joinDocument() {
    if (currentuser == null) {
      getCurrentUser();
      return;
    }

    if (repository.socketClient.connected) {
      repository.joinDocument({
        'documentId': widget.id,
        'userId': currentuser!.id,
      });
    } else {
      repository.socketClient.connect();

      repository.socketClient.once('connect', (_) {
        if (currentuser != null) {
          repository.joinDocument({
            'documentId': widget.id,
            'userId': currentuser!.id,
          });
        }
      });
    }

    repository.onUsersCountUpdate((documentId, users, count) {
      ref.read(currentEditorUserProvider.notifier).update((state) => users.map((user) => user.toString()).toList());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Store reference to provider
    getCurrentUser();
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
  void didUpdateWidget(NewDocumentScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-establish connections if needed
    if (!repository.socketClient.connected && currentuser != null) {
      joinDocument();
    }
  }

  // i want to clear all the data which is present in currentEditorUserProvider when we close this screen

  @override
  void dispose() {
    _titleController.dispose();
    if (currentuser != null) {
      repository.leaveDocument({
        'documentId': widget.id,
        'userId': currentuser!.id,
      });
    }
    repository.disconnect();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (currentuser == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        joinDocument();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (currentuser != null) {
          repository.leaveDocument({
            'documentId': widget.id,
            'userId': currentuser!.id,
          });
        }
        break;
      default:
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final docState = ref.watch(docViewmodelProvider);

    SizeConfig().init(context);

    // Calculate content width based on device type
    final contentWidth = Responsive.isDesktop(context) ? SizeConfig.screenWidth * 0.7 : SizeConfig.screenWidth;
    final isDesktop = Responsive.isDesktop(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.getBackgroundColor(context),
      body: Row(
        children: [
          Container(
            color: AppColors.getBackgroundColor(context),
            height: SizeConfig.screenHeight,
            width: contentWidth,
            child: Column(
              mainAxisAlignment: isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
              crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
              children: [
                Material(
                  elevation: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    height: SizeConfig.blockSizeVertical * 10,
                    width: SizeConfig.screenWidth,
                    color: AppColors.getBackgroundColor(context),
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
                                Container(
                                  color: AppColors.getBackgroundColor(context),
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
                                      contentPadding: const EdgeInsets.only(left: 10),
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
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Text('Error: ${error.toString()}'),
                    data: (documents) {
                      if (documents.isNotEmpty) {
                        final doc = documents.first;
                        
                        if (doc.id != widget.id) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('Document ID mismatch'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(docViewmodelProvider.notifier).getDocumentInfo(widget.id);
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }

                        if (doc.document.isNotEmpty) {
                          _documentContent = doc.document[0] as String;
                        } else {
                          _documentContent = '';
                        }
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
          if (Responsive.isDesktop(context))
            Container(
              width: SizeConfig.screenWidth * 0.3,
              height: SizeConfig.screenHeight,
              color: AppColors.getBackgroundColor(context),
              child: Consumer(
                builder: (context, ref, child) {
                  final userList = ref.watch(currentEditorUserProvider);
                  final asyncUsers = ref.watch(userViewmodelProvider);
                  final userViewModel = ref.read(userViewmodelProvider.notifier);

                  // Trigger user fetch when user list changes
                  ref.listen(currentEditorUserProvider, (_, nextUserIds) {
                    if (nextUserIds.isNotEmpty) {
                      userViewModel.getMultipleUser(nextUserIds);
                    }
                  });

                  return Column(
                    children: [
                      const Text('Users currently editing this document:'),
                      if (userList.isEmpty) const Text('No users are currently editing this document.'),
                      if (userList.isNotEmpty)
                        asyncUsers.when(
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stackTrace) => Text('Error loading users: $error'),
                          data: (users) {
                            return ListView.builder(
                              itemCount: users.length,
                              shrinkWrap: true,
                              physics: BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final user = users[index];
                                return Container(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).brightness == Brightness.dark 
                                    ? Colors.grey.withOpacity(0.1) 
                                    : Colors.grey.withOpacity(0.05),
                                ),
                                child: Row(
                                  children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(50),
                                    onTap: (){},
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[300],
                                      backgroundImage: user.avatar != null && user.avatar!.isNotEmpty 
                                        ? NetworkImage(user.avatar!) 
                                        : null,
                                      child: user.avatar == null || user.avatar!.isEmpty
                                        ? Text(
                                          user.userName != null && user.userName!.isNotEmpty 
                                            ? user.userName![0].toUpperCase() 
                                            : '?',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        )
                                        : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                      user.userName ?? 'Unknown User',
                                      style: AppTheme.textSmall(context),
                                      ),
                                      Text(
                                      user.email ?? 'No email',
                                      style: AppTheme.tinyText(context),
                                      ),
                                    ],
                                    ),
                                  ),
                                  if (user.userStatus != null)
                                    Container(
                                    height: 10,
                                    width: 10,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      color: AppColors.success,
                                      size: 10,
                                    ),
                                    ),
                                  ],
                                ),
                                );
                              },
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
