import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zenzen/config/constants.dart';
import 'package:zenzen/features/auth/splash/screen/intro_screen.dart';
import 'package:zenzen/features/auth/splash/screen/splash_screen.dart';

import '../features/auth/login/screen/login_screen.dart';
import '../utils/custom_transition.dart';

class RouteConfig {
  static GoRouter returnRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: RoutesName.initial,
          pageBuilder: (context, state) => const MaterialPage(
            child: SplashScreen(),
          ),
        ),
        GoRoute(
          path: '/intro',
          name: RoutesName.intro,
          pageBuilder: (context, state) => customTransitionPage(
            key: state.pageKey,
            child: const IntroScreens(),
            transitionType: PageTransitionType.bottomToTop,
          ),
        ),
        GoRoute(
          path: '/login',
          name: RoutesName.login,
          pageBuilder: (context, state) => customTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionType: PageTransitionType.leftToRight,
          ),
        ),
      ],
    );
  }
}
