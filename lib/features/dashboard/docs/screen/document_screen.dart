import 'dart:async';

import 'package:animate_do/animate_do.dart';
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

import '../../../../data/cache/api_cache.dart';
import '../../../../data/local/provider/hive_provider.dart';
import '../../../auth/login/model/user_model.dart';
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

  static Timer? _hoverTimer;
  static bool _isHovered = false;
  OverlayEntry? _overlayEntry;
  bool _isMovingToCard = false;
  bool _showAnimation = false;

  final ApiCache _cache = ApiCache();

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
      // Try to get user first
      getCurrentUser();
      // If still null, wait for user to be set
      return;
    }

    if (repository.socketClient.connected) {
      repository.joinDocument({
        'documentId': widget.id,
        'userId': currentuser!.id,
      });
    } else {
      // Reconnect socket if needed
      repository.socketClient.connect();

      // Wait for connection before joining
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
      print('Document ID: $documentId');
      print('user count wala Users: $users');
      print('Count: $count');

      // Update provider state with user IDs
      ref.read(currentEditorUserProvider.notifier).update((state) => users.map((user) => user.toString()).toList());

      // Log updated state
      print('User List in provider: ${ref.read(currentEditorUserProvider)}');
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

  // Cancel hover and cleanup
  void cancelHover() {
    if (_isMovingToCard) return; // Don't cancel if moving to card

    _hoverTimer?.cancel();
    _isHovered = false;

    setState(() {
      _showAnimation = true; // Reset animation state
    });
    // Remove overlay and reset reference
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Start hover timer
  void startHoverTimer({
    required BuildContext context,
    required String userId,
    required WidgetRef ref,
    required Offset position,
  }) {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(milliseconds: 500), () async {
      if (!mounted) return; // Critical: Check if widget is still alive
      _isHovered = true;

      // Check cache first
      final cachedUser = _cache.get('user_$userId');
      if (cachedUser != null) {
        showHoverCard(context: context, user: cachedUser, position: position);
        return;
      }

      // Fetch user data from ViewModel
      final userViewModel = ref.read(userViewmodelProvider.notifier);
      final userResult = await userViewModel.getUser(userId);

      userResult.fold(
        (user) => showHoverCard(context: context, user: user, position: position),
        (error) => debugPrint('Error fetching user data: $error'),
      );
    });
  }

  // Show hover card
  void showHoverCard({
    required BuildContext context,
    required UserModel user,
    required Offset position,
  }) {
    if (!_isHovered || !mounted) return;

    // Remove existing overlay entry if present
    _overlayEntry?.remove();
    _overlayEntry = null;

    // Create new overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 100, // Adjust positioning relative to avatar
        top: position.dy + 10,
        child: MouseRegion(
          onEnter: (_) {
            print('Mouse entered card');
            _isMovingToCard = true; // Set flag when mouse enters card
            _isHovered = true;
          },
          onExit: (_) {
            print('Mouse exited card');
            _isMovingToCard = false; // Reset flag when mouse exits card
            print('Mouse exited card, removing overlay');
            _isHovered = false;
            // Delay removal to allow for card interaction
            print(_isMovingToCard);
            print(_isHovered);
            Future.delayed(const Duration(milliseconds: 400), () {
              if (!_isMovingToCard && !_isHovered) {
                _overlayEntry?.remove();
                _overlayEntry = null;
                cancelHover();
              }
            });
          },
          child: FadeIn(
            curve: Curves.easeIn,
            animate: true,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: FadeIn(
                duration: const Duration(milliseconds: 800),
                animate: true,
                delay: const Duration(milliseconds: 100),
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2C2C) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with avatar and name
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF444444) : const Color(0xFFF5F5F5),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[300],
                              backgroundImage: user.avatar != null && user.avatar!.isNotEmpty ? NetworkImage(user.avatar!) : null,
                              child: user.avatar == null || user.avatar!.isEmpty
                                  ? Text(
                                      user.userName != null && user.userName!.isNotEmpty ? user.userName![0].toUpperCase() : '?',
                                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.userName ?? "Unknown User",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: user.userStatus == "Active" ? Colors.green[100] : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      user.userStatus ?? "Offline",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: user.userStatus == "Active" ? Colors.green[800] : Colors.grey[700],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // User details section and action buttons remain unchanged
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              context,
                              Icons.email_outlined,
                              "Email",
                              user.email ?? "N/A",
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              Icons.phone_outlined,
                              "Phone",
                              user.mobile ?? "N/A",
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              context,
                              Icons.verified_outlined,
                              "Verified",
                              user.isVerified == true ? "Yes" : "No",
                            ),
                          ],
                        ),
                      ),

                      // Action buttons
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildActionButton(context, Icons.chat_outlined, "Chat"),
                            const SizedBox(width: 12),
                            _buildActionButton(context, Icons.call_outlined, "Call"),
                            const SizedBox(width: 12),
                            _buildActionButton(context, Icons.videocam_outlined, "Video"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final overlay = Overlay.of(context);
    overlay.insert(_overlayEntry!);
    }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black54;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: textColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label) {
    final primaryColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF6264A7) // Teams dark mode purple
        : const Color(0xFF6264A7); // Teams light mode purple

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: primaryColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 13, color: primaryColor),
            ),
          ],
        ),
      ),
    );
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
                    error: (error, _) {
                      print(error);
                      return Text('Error: ${error.toString()}');
                    },
                    data: (documents) {
                      if (documents.isNotEmpty) {
                        final doc = documents.first;
                        if (doc.document.isNotEmpty) {
                          _documentContent = doc.document[0] as String; // Ensure it's not null
                        } else {
                          _documentContent = ''; // Default content if document is empty
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
