import 'package:animate_do/animate_do.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/router/constants.dart';
import '../../docs/model/document_model.dart';
import '../../docs/view-model/doc_viewmodel.dart';

class DocumentCardWidget extends StatelessWidget {
  const DocumentCardWidget({
    super.key,
    required this.context,
    required this.document,
  });

  final BuildContext context;
  final DocumentModel document;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(document.createdAt);

    return FadeIn(
      animate: true,
      delay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 1500),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            // Handle document selection/opening
            if (document.id != null) {
              context.goNamed(
                RoutesName.doc,
                pathParameters: {'id': document.id!},
                extra: document.title,
              );
            } else {
              // Handle the case where document.id is null
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.description, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        document.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    document.isPrivate ? Tooltip(message: 'Private Document', child: Icon(Icons.lock, size: 16, color: Colors.grey[600])) : Tooltip(message: 'Public Document', child: Icon(Icons.public, size: 16, color: Colors.grey[600])),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Created: $formattedDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${document.users.length} users',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            final docViewModel = ref.read(docViewmodelProvider.notifier);
                            return PullDownButton(
                              itemBuilder: (context) => [
                                PullDownMenuHeader(
                                  itemTheme: PullDownMenuItemTheme.maybeOf(context),
                                  leading: CachedNetworkImage(imageUrl: document.admin!.avatar ?? 'https://www.startpage.com/av/proxy-image?piurl=https%3A%2F%2Fimg.freepik.com%2Ffree-psd%2Fcontact-icon-illustration-isolated_23-2151903337.jpg&sp=1742530336Tccbf5d432c4bd56601aeefdb4b204fbaec7c563cddfe4e416727623caea3ec1b', width: 40, height: 40),
                                  title: document.admin!.userName ?? 'Profile',
                                  subtitle: document.admin!.email ?? 'Tap to open',
                                  onTap: () {},
                                  icon: CupertinoIcons.profile_circled,
                                ),
                                PullDownMenuActionsRow.medium(
                                  items: [
                                    PullDownMenuItem(
                                      onTap: () {},
                                      title: 'Add users',
                                      icon: CupertinoIcons.person_add,
                                    ),
                                    PullDownMenuItem(
                                      onTap: () {},
                                      title: 'Duplicate',
                                      icon: CupertinoIcons.doc_on_doc,
                                    ),
                                    PullDownMenuItem(
                                      onTap: () {},
                                      title: 'Favorite',
                                      icon: CupertinoIcons.bookmark,
                                    ),
                                  ],
                                ),
                                PullDownMenuDivider.large(),
                                PullDownMenuItem(
                                  title: 'Share',
                                  onTap: () {
                                    print('Share');
                                  },
                                  icon: CupertinoIcons.share,
                                ),
                                PullDownMenuItem(
                                  iconColor: Colors.red,
                                  onTap: () {
                                    // print('Delete document ${document.id}');
                                    docViewModel.deleteDocument(document.id!, context);
                                  },
                                  title: 'Delete',
                                  icon: CupertinoIcons.delete,
                                ),
                              ],
                              position: PullDownMenuPosition.automatic,
                              buttonBuilder: (context, showMenu) => IconButton(
                                onPressed: showMenu,
                                icon: Icon(CupertinoIcons.ellipsis),
                              ),
                            );
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
