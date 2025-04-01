import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zenzen/utils/theme.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/router/constants.dart';
import '../../docs/model/document_model.dart';
import '../../docs/widget/document_list_widget.dart';

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
        color: AppColors.getContainerColor(context),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.getNegativeBackgroundColor(context).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          splashColor: AppColors.getContainerColor(context),
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
                    Icon(Icons.description, color: AppColors.getIconsColor(context)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        document.title,
                        style: AppTheme.buttonTheme(context),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    document.isPrivate ? Tooltip(message: 'Private Document', child: Icon(Icons.lock, size: 16, color: AppColors.getIconsColor(context))) : Tooltip(message: 'Public Document', child: Icon(Icons.public, size: 16, color: AppColors.getIconsColor(context))),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Created: $formattedDate',
                        style: AppTheme.tinyText(context)
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
                      style: AppTheme.tinyText(context),
                    ),
                    Row(
                      children: [
                        DocumentActions(
                          isProjectIdAvailable: document.projectId != null,
                          document: document,
                        )
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
