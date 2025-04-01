import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/cache/api_cache.dart';
import '../../features/auth/login/model/user_model.dart';
import '../../features/auth/user/view-model/user_view_model.dart';

class CustomHovercard {
  static Timer? _hoverTimer;
  static bool _isHovered = false;
  OverlayEntry? _overlayEntry;
  bool _isMovingToCard = false;
  bool _showAnimation = false;

  final ApiCache _cache = ApiCache();
  void startHoverTimer({
    required BuildContext context,
    required String userId,
    required WidgetRef ref,
    required Offset position,
  }) {
    _hoverTimer?.cancel();
    _hoverTimer = Timer(const Duration(milliseconds: 500), () async {
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

  void cancelHover() {
    if (_isMovingToCard) return; // Don't cancel if moving to card

    _hoverTimer?.cancel();
    _isHovered = false;

    _showAnimation = true; // Reset animation state
    
    // Remove overlay and reset reference
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void showHoverCard({
    required BuildContext context,
    required UserModel user,
    required Offset position,
  }) {
    if (!_isHovered ) return;

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
                            InfoRowWidget(
                              context: context,
                              icon: Icons.email_outlined,
                              label: "Email",
                              value: user.email ?? "N/A",
                            ),
                            const SizedBox(height: 12),
                            InfoRowWidget(
                              context: context,
                              icon: Icons.phone_outlined,
                              label: "Phone",
                              value: user.mobile ?? "N/A",
                            ),
                            const SizedBox(height: 12),
                            InfoRowWidget(
                              context: context,
                              icon: Icons.verified,
                              label: "Verified",
                              value: user.isVerified == true ? "Yes" : "No",
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
                            ActionButtonWidget(
                              context: context,
                              icon:  Icons.chat_outlined,
                              label:  "Chat",
                            ),
                            const SizedBox(width: 12),
                            ActionButtonWidget(
                              context: context,
                              icon: Icons.call_outlined,
                              label: "Call",
                            ),
                            const SizedBox(width: 12),
                            ActionButtonWidget(
                              context: context,
                              icon: Icons.video_call_outlined,
                              label: "Video",
                            ),
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
}

class InfoRowWidget extends StatelessWidget {
  const InfoRowWidget({
    super.key,
    required this.context,
    required this.icon,
    required this.label,
    required this.value,
  });

  final BuildContext context;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
}

class ActionButtonWidget extends StatelessWidget {
  const ActionButtonWidget({
    super.key,
    required this.context,
    required this.icon,
    required this.label,
  });

  final BuildContext context;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
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
}
