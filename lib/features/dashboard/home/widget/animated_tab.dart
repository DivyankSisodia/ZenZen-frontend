import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../../config/constants/app_colors.dart';
import '../../../../config/constants/responsive.dart';
import '../../../../config/constants/size_config.dart';
import '../../../../data/failure.dart';
import '../../docs/model/document_model.dart';
import '../../docs/view-model/doc_viewmodel.dart';
import 'document_card.dart';

class AnimatedTab extends ConsumerStatefulWidget {
  const AnimatedTab({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnimatedTabState();
}

class _AnimatedTabState extends ConsumerState<AnimatedTab> {
  int _selectedIndex = 0;
  final List<String> _tabLabels = ['Recent', 'Favorites', 'Shared', 'External', 'Archived'];

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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    _tabLabels[i],
                    style: TextStyle(
                      color: _selectedIndex == i ? AppColors.primary : null,
                      fontWeight: _selectedIndex == i ? FontWeight.bold : FontWeight.normal,
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
                loading: () => const Center(child: CircularProgressIndicator.adaptive()),
                error: (error, stack) {
                  if (error is ApiFailure) {
                    print('ApiFailure details: ${error.error}');
                    // You can also print other properties if ApiFailure has them
                    // print('Status code: ${error.statusCode}');
                  }

                  return Center(
                    child: Text(
                      (error is ApiFailure) ? error.error : 'An error occurred',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                },
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
            return DocumentCardWidget(context: context, document: document);
          },
        );
      },
    );
  }
}

