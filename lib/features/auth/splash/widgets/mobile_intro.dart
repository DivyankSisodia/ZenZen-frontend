import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:zenzen/config/constants/app_colors.dart';

import '../../../../config/router/constants.dart';
import '../../../../utils/theme.dart';

class MobileIntro extends ConsumerStatefulWidget {
  const MobileIntro({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MobileIntroState();
}

class _MobileIntroState extends ConsumerState<MobileIntro> {
  final titles = [
    'Online Text Editor',
    'Seamless Collaboration',
    'Real-time Preview & Chat',
  ];

  final description = [
    'Create, edit, and collaborate on text documents with ease.',
    'Work together with your team in real-time on the same document.',
    'Preview your document in real-time and chat with your team.',
  ];

  final PageController _controller = PageController();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.page != null) {
        setState(() {
          currentPage = _controller.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _controller,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          color: Colors.white,
          child: Column(
            children: [
              Image.asset(
                height: 400,
                'assets/images/doodle_pen.png',
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text(
                titles[index],
                style: AppTheme.introPageTitleStyle(context),
              ),
              const SizedBox(height: 10),
              Text(
                description[index],
                style: AppTheme.descriptionTextStyle(context),
              ),
              const Gap(20),
              SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  activeDotColor: Theme.of(context).primaryColor,
                  dotColor: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
              const Gap(30),
              ElevatedButton(
                onPressed: () {
                  if (currentPage == 2) {
                    // If on last page, go back to first page
                    context.goNamed(RoutesName.login);
                  } else {
                    // Otherwise, go to next page
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getIconsColor(context),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: Text(
                  currentPage == 2 ? 'Start Over' : 'Next',
                  style: AppTheme.buttonText(context),
                ),
              ),
              const Gap(10),
              TextButton(
                onPressed: () {
                  _controller.animateToPage(
                    2,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeIn,
                  );
                },
                child: Text(
                  'Skip',
                  style: AppTheme.textSmall(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
