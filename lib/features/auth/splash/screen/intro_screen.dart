import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/desktop_intro.dart';
import '../widgets/mobile_intro.dart';

class IntroScreens extends ConsumerStatefulWidget {
  const IntroScreens({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _IntroScreensState();
}

class _IntroScreensState extends ConsumerState<IntroScreens> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (context, contraints) {
          if (contraints.maxWidth < 800) {
            return const MobileIntro();
          } else if (contraints.maxWidth < 1200) {
            return const DesktopIntro();
          } else {
            return const DesktopIntro();
          }
        },
      ),
    );
  }
}
