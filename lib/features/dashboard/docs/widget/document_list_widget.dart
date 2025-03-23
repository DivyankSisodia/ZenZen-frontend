import 'package:animate_do/animate_do.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:zenzen/config/router/constants.dart';
import 'package:zenzen/features/dashboard/docs/model/document_model.dart';
import 'package:zenzen/utils/common/custom_dialogs.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../utils/theme.dart';
import '../../../auth/login/model/user_model.dart';
import '../view-model/doc_viewmodel.dart';

class DocumentListWidget extends ConsumerStatefulWidget {
  final List<DocumentModel> documents;
  const DocumentListWidget({
    super.key,
    required this.documents,
  });

  @override
  ConsumerState<DocumentListWidget> createState() => _DocumentListWidgetState();
}

class _DocumentListWidgetState extends ConsumerState<DocumentListWidget> {
  final List<Color> colors = [
    AppColors.warning,
    AppColors.info,
    AppColors.success,
    AppColors.error,
  ];

  @override
  Widget build(BuildContext context) {
    print('pehle se hai');
    return FadeIn(
      animate: true,
      delay: const Duration(milliseconds: 100),
      duration: const Duration(milliseconds: 1500),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.documents.length,
        itemBuilder: (context, index) => DocumentItem(
          document: widget.documents[index],
          colors: colors,
          onHoverStart: () => CustomDialogs.startHoverTimer(
            context: context,
            title: widget.documents[index].title,
            creationDate: widget.documents[index].createdAt,
            users: widget.documents[index].users,
            description: widget.documents[index].isPrivate ? 'Private' : 'Public',
            id: widget.documents[index].id,
            onOpenProject: () {
              print('TODO');
            },
          ),
          onHoverEnd: CustomDialogs.cancelHover,
        ),
      ),
    );
  
    return Consumer(
      builder: (context, ref, child) {
        print('naya data hai');
        final documents = ref.watch(docViewmodelProvider);
        return documents.when(
          data: (data) => FadeIn(
            animate: true,
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 1500),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, index) => DocumentItem(
                document: data[index],
                colors: colors,
                onHoverStart: () => CustomDialogs.startHoverTimer(
                  context: context,
                  title: data[index].title,
                  creationDate: data[index].createdAt,
                  users: data[index].users,
                  description: data[index].isPrivate ? 'Private' : 'Public',
                  id: data[index].id,
                  onOpenProject: () {
                    print('TODO');
                  },
                ),
                onHoverEnd: CustomDialogs.cancelHover,
              ),
            ),
          ),
          error: (error, stackTrace) => Center(
            child: Text(
              'Error: $error',
              style: AppTheme.textMedium(context),
            ),
          ),
          loading: () => const DocumentListSkeleton(),
        );
      },
    );
  }
}

class DocumentItem extends StatelessWidget {
  final DocumentModel document;
  final List<Color> colors;
  final VoidCallback onHoverStart;
  final VoidCallback onHoverEnd;

  const DocumentItem({
    super.key,
    required this.document,
    required this.colors,
    required this.onHoverStart,
    required this.onHoverEnd,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHoverStart(),
      onExit: (_) => onHoverEnd(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.1),
              blurRadius: 2,
              spreadRadius: 1,
            ),
          ],
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.file_copy,
              size: 30,
              shadows: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
              color: AppColors.primary,
            ),
            const Gap(10),
            Expanded(
              child: InkWell(
                onTap: () {
                  context.goNamed(
                    RoutesName.doc,
                    pathParameters: {'id': document.id!},
                    extra: document.title,
                  );
                },
                child: DocumentDetails(document: document),
              ),
            ),
            Expanded(
              child: DocumentUsers(
                users: document.users,
                colors: colors,
                creationDate: document.createdAt,
              ),
            ),
            const Gap(20),
            DocumentActions(),
          ],
        ),
      ),
    );
  }
}

class DocumentDetails extends StatelessWidget {
  final DocumentModel document;

  const DocumentDetails({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: document.title,
            style: AppTheme.textMedium(context),
          ),
        ),
        const Gap(5),
        Row(
          children: [
            Text(
              document.isPrivate ? 'Private' : 'Public',
              style: AppTheme.textSmall(context).copyWith(
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),
            const Gap(5),
            if (document.isPrivate)
              Icon(
                Icons.lock,
                size: 15,
                color: AppColors.primary.withOpacity(0.7),
              ),
          ],
        ),
      ],
    );
  }
}

class DocumentUsers extends StatelessWidget {
  final List<UserModel> users;
  final List<Color> colors;
  final DateTime creationDate;

  const DocumentUsers({
    super.key,
    required this.users,
    required this.colors,
    required this.creationDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          height: 30,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < users.length; i++)
                Positioned(
                  right: i * 20.0,
                  child: Tooltip(
                    message: users[i].userName!,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: colors[i % colors.length],
                      child: Text(
                        users[i].userName!.substring(0, 1).toUpperCase(),
                        style: AppTheme.textSmall(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Text(
          DateFormat.yMMMd().format(creationDate),
          style: AppTheme.textSmall(context).copyWith(
            color: AppColors.primary.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class DocumentActions extends StatelessWidget {
  const DocumentActions({super.key});

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          title: 'Edit',
          onTap: () => print('Edit'),
          icon: CupertinoIcons.pencil,
        ),
        PullDownMenuItem(
          title: 'Delete',
          onTap: () => print('Delete'),
          isDestructive: true,
          icon: CupertinoIcons.delete,
        ),
        PullDownMenuItem(
          title: 'Share',
          onTap: () => print('Share'),
          icon: CupertinoIcons.share,
        ),
      ],
      position: PullDownMenuPosition.automatic,
      buttonBuilder: (context, showMenu) => IconButton(
        onPressed: showMenu,
        icon: const Icon(CupertinoIcons.ellipsis),
      ),
    );
  }
}

class DocumentListSkeleton extends StatelessWidget {
  const DocumentListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Skeletonizer(
        enabled: true,
        enableSwitchAnimation: true,
        child: ListView.builder(
          itemCount: 6,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) => Card(
            child: ListTile(
              title: Text('Item number $index as title'),
              subtitle: const Text('Subtitle here'),
              trailing: const Icon(
                Icons.ac_unit,
                size: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
