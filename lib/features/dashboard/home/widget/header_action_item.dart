import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore_for_file: unrelated_type_equality_checks

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:zenzen/config/constants/app_colors.dart';
import 'package:zenzen/config/constants/responsive.dart';
import 'package:zenzen/utils/theme.dart';

import '../../../auth/login/viewmodel/auth_viewmodel.dart';

class HeaderActionItems extends ConsumerStatefulWidget {
  const HeaderActionItems({super.key});

  @override
  ConsumerState<HeaderActionItems> createState() => _HeaderActionItemsState();
}

class _HeaderActionItemsState extends ConsumerState<HeaderActionItems> {
  late FocusNode focusNode;
  late TextEditingController controller;
  late String hint;

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
            icon: Icon(
              Icons.nightlight,
              color: AppColors.getIconsColor(context),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications,
              color: AppColors.getIconsColor(context),
            ),
          ),
          const Gap(10),
          if (Responsive.isMobile(context))
            InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  height: 40,
                  width: 40,
                  imageUrl: currentUser!.avatar,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          if (Responsive.isTablet(context))
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    height: 40,
                    width: 40,
                    imageUrl: currentUser!.avatar,
                    placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const Gap(10),
                Text(
                  currentUser.userName,
                  style: AppTheme.lightTheme(context).textTheme.bodyMedium,
                ),
              ],
            )
        ],
      ),
    );
  }
}
