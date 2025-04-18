// ignore_for_file: unnecessary_null_comparison

import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../data/cache/api_cache.dart';
import '../../../../data/local/provider/hive_provider.dart';
import '../../../auth/login/model/user_model.dart';
import '../../../auth/user/view-model/user_view_model.dart';

class HeaderActionItems extends ConsumerStatefulWidget {
  const HeaderActionItems({super.key});

  @override
  ConsumerState<HeaderActionItems> createState() => _HeaderActionItemsState();
}

class _HeaderActionItemsState extends ConsumerState<HeaderActionItems> {
  static Timer? _hoverTimer;
  static bool _isHovered = false;
  OverlayEntry? _overlayEntry;
  bool _isMovingToCard = false;

  final ApiCache _cache = ApiCache();

  // Cancel hover and cleanup
  void cancelHover() {
    if (_isMovingToCard) return; // Don't cancel if moving to card
    
    _hoverTimer?.cancel();
    _isHovered = false;

    setState(() {
// Reset animation state
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
        left: position.dx - 250, // Adjust positioning relative to avatar
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
    if (overlay != null) {
      overlay.insert(_overlayEntry!);
    }
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
    final hiveService = ref.watch(userDataProvider);
    final currentUser = hiveService.userBox.get('currentUser');

    return Container(
      margin: const EdgeInsets.only(right: 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.nightlight, color: AppColors.getIconsColor(context)),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications, color: AppColors.getIconsColor(context)),
          ),
          const SizedBox(width: 10),
          MouseRegion(
            onEnter: (event) {
              _isHovered = true; // Set hover state when entering avatar
              startHoverTimer(
                context: context,
                userId: currentUser.id!,
                ref: ref,
                position: event.position,
              );
            },
            onExit: (event) {
              _isHovered = false; // Reset hover state
              // Only cancel if not moving to card
              Future.delayed(const Duration(milliseconds: 100), () {
                if (!_isMovingToCard) {
                  cancelHover();
                }
              });
            },
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {},
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[300],
                backgroundImage: currentUser!.avatar != null && currentUser.avatar.isNotEmpty ? CachedNetworkImageProvider(currentUser.avatar, errorListener: (p0) => debugPrint('error'),) : null,
                child: currentUser.avatar.isEmpty
                    ? Text(
                        currentUser.userName.isNotEmpty ? currentUser.userName[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
            ),
          )
        ],
      ),
    );
  }
}
