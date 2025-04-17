import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/config/constants/responsive.dart';
import 'package:zenzen/config/constants/size_config.dart';
import 'package:zenzen/data/local/hive_models/local_user_model.dart';
import 'package:zenzen/features/dashboard/chat/model/chat_model.dart';
import 'package:zenzen/utils/theme.dart';
import '../../../../config/router/constants.dart';
import '../../../../data/local/provider/hive_provider.dart';
import '../../../../data/sockets/socket_repo.dart';
import '../../../../utils/common/custom_floating_button.dart';
import '../provider/dashboard_provider.dart';
import '../view-model/dashboard_viewmodel.dart';

class ChatDashboardScreen extends ConsumerStatefulWidget {
  const ChatDashboardScreen({super.key});

  @override
  ConsumerState<ChatDashboardScreen> createState() => _ChatDashboardScreenState();
}

class _ChatDashboardScreenState extends ConsumerState<ChatDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late bool shallDispose;

  LocalUser? currentUser;

  SocketRepository socketRepo = SocketRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentUser();
      // Fetch chat data when the screen loads
      ref.read(chatDashboardProvider.notifier).getChats();
      socketRepo.socketClient.connect();
    });

    Future.microtask(() {
      ref.read(diconnectSocketHelperProvider.notifier).state = true;
      shallDispose = ref.read(diconnectSocketHelperProvider);
    });
  }

  // Update getCurrentUser to return user immediately
  LocalUser? getCurrentUser() {
    final hiveService = ref.read(userDataProvider);
    final user = hiveService.userBox.get('currentUser');
    if (mounted) {
      setState(() => currentUser = user);
    }
    return user;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    // Check if the socket should be disconnected
    if (shallDispose) {
      socketRepo.socketClient.disconnect();
      socketRepo.socketClient.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    Responsive.isDesktop(context);

    // Get the data from the provider - no need to call getChats here
    final dashboardAsync = ref.watch(chatDashboardProvider);

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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Error: ${error.toString()}',
                  style: AppTheme.textMedium(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retry fetching data
                    ref.read(chatDashboardProvider.notifier).getChats();
                  },
                  child: Text('Retry'),
                ),
              ],
            ),
          ),
          data: (chats) => chats.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No chat messages yet',
                      style: AppTheme.textMedium(context),
                    ),
                  ],
                ))
              : ListView.builder(
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
    // Safely access chat data with null checks
    final unreadCount = chat.unreadCount ?? 0;
    final participants = chat.participants;
    final lastMessage = chat.lastMessage;

    // Handle empty participants or null data
    if (participants == null || participants.isEmpty || lastMessage == null) {
      return Container(); // Return empty container for invalid data
    }

    final participant = participants[0];
    final participantName = participant.userName ?? 'Unknown';
    final participantAvatar = participant.userAvatar;
    final messageContent = lastMessage.content ?? 'No message';
    final messageTimestamp = lastMessage.timestamp ?? DateTime.now();

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
            ref.read(diconnectSocketHelperProvider.notifier).state = false;
            shallDispose = ref.read(diconnectSocketHelperProvider);
            context.goNamed(
              RoutesName.chatListScreen,
              extra: chat.id,
              pathParameters: {'id': chat.roomId ?? 'chat'},
              queryParameters: {
                'chatName': participantName,
                'chatImage': participantAvatar,
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
                    child: participantAvatar != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Image.network(
                              participantAvatar,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Text(
                                participantName.substring(0, min(2, participantName.length)).toUpperCase(),
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            participantName.substring(0, min(2, participantName.length)).toUpperCase(),
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
                            participantName,
                            style: AppTheme.textMedium(context),
                          ),
                          Column(
                            children: [
                              Text(
                                _formatTime(messageTimestamp),
                                style: AppTheme.tinyText(context),
                              ),
                              if (unreadCount > 0)
                                Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    unreadCount.toString(),
                                    style: AppTheme.tinyText(context).copyWith(
                                      color: AppColors.black,
                                    ),
                                  ),
                                ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        messageContent,
                        style: AppTheme.textSmall(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Unread Indicator
                if (chat.callStatus == false)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success,
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

  // Helper function to prevent substring errors
  int min(int a, int b) {
    return a < b ? a : b;
  }
}
