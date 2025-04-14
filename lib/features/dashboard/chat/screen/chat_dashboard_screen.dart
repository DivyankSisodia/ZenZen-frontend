import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/config/constants/responsive.dart';
import 'package:zenzen/config/constants/size_config.dart';
import 'package:zenzen/data/local/hive_models/local_user_model.dart';
import 'package:zenzen/data/sockets/socket_repo.dart';
import 'package:zenzen/features/auth/login/model/user_model.dart';
import 'package:zenzen/features/auth/user/view-model/user_view_model.dart';
import 'package:zenzen/features/dashboard/chat/model/chat_model.dart';
import 'package:zenzen/utils/theme.dart';
import '../../../../config/router/constants.dart';
import '../../../../data/local/provider/hive_provider.dart';
import '../../../../utils/common/custom_floating_button.dart';
import '../provider/dashboard_provider.dart';

class ChatDashboardScreen extends ConsumerStatefulWidget {
  const ChatDashboardScreen({super.key});

  @override
  ConsumerState<ChatDashboardScreen> createState() => _ChatDashboardScreenState();
}

class _ChatDashboardScreenState extends ConsumerState<ChatDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _mounted = true;
  SocketRepository _socketRepo = SocketRepository();

  LocalUser? currentUser;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mounted) {
        getCurrentUser();
        _socketRepo.getDashboardData(currentUser!.id!);
      }
    });
  }

  void getCurrentUser() async {
    final hiveService = ref.read(userDataProvider);
    final user = hiveService.userBox.get('currentUser');
    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  @override
  void dispose() {
    _mounted = false;
    _searchController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Responsive.isDesktop(context);
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: NestedScrollView(
        physics: BouncingScrollPhysics(),
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              forceElevated: false,
              forceMaterialTransparency: false,
              shadowColor: Colors.black,
              pinned: true,
              floating: false,
              backgroundColor: AppColors.getBackgroundColor(context),
              expandedHeight: 120,
              collapsedHeight: 70,
              elevation: 0,
              // Always visible title - pinned when scrolling
              title: Text(
                'Dashboard',
                style: AppTheme.textLarge(context),
              ),
              centerTitle: false,
              // This space collapses when scrolling
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 70),
                  child: Text(
                    'Messages',
                    style: AppTheme.textLarge(context),
                  ),
                ),
                collapseMode: CollapseMode.pin,
              ),
              // Bottom section always pinned - never disappears
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(70),
                child: Container(
                  color: AppColors.getBackgroundColor(context),
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 25, top: 10),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.getContainerColor(context),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        // if (!_mounted) return;
                        // if (value.isNotEmpty) {
                        //   ref.read(chatViewModelProvider.notifier).searchChats(value);
                        // } else {
                        //   ref.read(chatViewModelProvider.notifier).getChats();
                        // }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search messages...',
                        prefixIcon: Icon(
                          Icons.search,
                          color: AppColors.getIconsColor(context),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        // Main body content
        body: dashboardAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error: ${error.toString()}',
              style: AppTheme.textMedium(context),
            ),
          ),
          data: (chats) => ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _buildChatItem(context, chat);
            },
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
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

  Widget _buildChatItem(BuildContext context, ChatRoom chat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.getContainerColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.goNamed(
              RoutesName.chatListScreen,
              pathParameters: {'id': chat.roomId ?? 'chat'},
              queryParameters: {
                'chatName': chat.participants![0].userName,
                'chatImage': chat.participants![0].userAvatar,
              },
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withOpacity(0.1),
                  ),
                  child: Center(
                    child: chat.participants![0].userAvatar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.network(
                              chat.participants![0].userAvatar!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Text(
                            chat.participants![0].userName!.substring(0, 2).toUpperCase(),
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                // Chat Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            chat.participants![0].userName!,
                            style: AppTheme.textMedium(context),
                          ),
                          Text(
                            _formatTime(DateTime.now()),
                            style: AppTheme.tinyText(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        chat.lastMessage!.content!,
                        style: AppTheme.textSmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Unread Indicator
                if (chat.callStatus == true)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
