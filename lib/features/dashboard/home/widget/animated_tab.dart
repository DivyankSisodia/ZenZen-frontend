import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../config/app_colors.dart';
import '../../../../config/constants.dart';
import '../../../../config/responsive.dart';
import '../../../../config/size_config.dart';
import '../../../../data/failure.dart';
import '../../docs/model/document_model.dart';
import '../../docs/view-model/doc_viewmodel.dart';

class AnimatedTab extends ConsumerStatefulWidget {
  const AnimatedTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnimatedTabState();
}

class _AnimatedTabState extends ConsumerState<AnimatedTab> {
  int _selectedIndex = 0;
  final List<String> _tabLabels = [
    'Recent',
    'Favorites',
    'Shared',
    'External',
    'Archived'
  ];

  @override
  void initState() {
    super.initState();
    // Fetch initial data when the tab is created - just once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDocumentsForTab(_selectedIndex);
    });
  }
  
  // Method to fetch documents based on tab index
  void _fetchDocumentsForTab(int tabIndex) {
    final docViewModel = ref.read(docViewmodelProvider.notifier);
    
    switch (tabIndex) {
      case 0: // Recent
        docViewModel.getAllDocuments();
        break;
      case 1: // Favorites
        docViewModel.getAllDocuments(); // Replace with getFavoriteDocuments() when available
        break;
      case 2: // Shared
        docViewModel.getAllDocuments(); // Replace with getSharedDocuments() when available
        break;
      case 3: // External
        docViewModel.getAllDocuments(); // Replace with getExternalDocuments() when available
        break;
      case 4: // Archived
        docViewModel.getAllDocuments(); // Replace with getArchivedDocuments() when available
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: Responsive.isMobile(context)
              ? SizeConfig.screenWidth
              : Responsive.isTablet(context)
                  ? SizeConfig.screenWidth / 1.5
                  : SizeConfig.screenWidth / 2.5,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _selectedIndex,
            children: {
              for (int i = 0; i < _tabLabels.length; i++)
                i: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    _tabLabels[i],
                    style: TextStyle(
                      color: _selectedIndex == i ? AppColors.primary : null,
                      fontWeight: _selectedIndex == i
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
            },
            onValueChanged: (int? value) {
              if (value != null && value != _selectedIndex) {
                setState(() {
                  _selectedIndex = value;
                });
                
                // Fetch data when tab changes
                _fetchDocumentsForTab(value);
              }
            },
            thumbColor: AppColors.white,
            backgroundColor: AppColors.surface,
          ),
        ),
        const Gap(12),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              final docState = ref.watch(docViewmodelProvider);
              
              // Use the state without triggering API calls in the build method
              return docState.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (error, stack) => Center(
                  child: Text(
                    (error is ApiFailure) ? error.error : 'An error occurred',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                data: (documents) => _buildDocumentGrid(documents),
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildDocumentGrid(List<DocumentModel> documents) {
    if (documents.isEmpty) {
      return const Center(child: Text('No documents found'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate the number of columns based on available width
        const double itemWidth = 220; // Target width for each item
        int crossAxisCount;

        if (Responsive.isDesktop(context)) {
          crossAxisCount = max(2, constraints.maxWidth ~/ itemWidth);
        } else if (Responsive.isTablet(context)) {
          crossAxisCount = max(2, constraints.maxWidth ~/ itemWidth);
        } else {
          crossAxisCount = max(1, constraints.maxWidth ~/ itemWidth);
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            return _buildDocumentCard(context, document);
          },
        );
      },
    );
  }

  Widget _buildDocumentCard(BuildContext context, DocumentModel document) {
    final formattedDate = DateFormat('MMM d, yyyy').format(document.createdAt);

    return Card(
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
                  document.isPrivate
                      ? Icon(Icons.lock, size: 16, color: Colors.grey[600])
                      : Icon(Icons.public, size: 16, color: Colors.grey[600]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
