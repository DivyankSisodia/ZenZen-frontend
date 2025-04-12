import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';
import 'package:zenzen/config/router/constants.dart';
import 'package:zenzen/features/auth/login/screen/register_screen.dart';
import 'package:zenzen/features/auth/login/screen/signup_screen.dart';
import 'package:zenzen/features/auth/splash/screen/intro_screen.dart';
import 'package:zenzen/features/auth/splash/screen/splash_screen.dart';
import 'package:zenzen/features/dashboard/docs/screen/document_screen.dart';
import 'package:zenzen/features/dashboard/file-transfer/screen/file_transfer_screen.dart';
import 'package:zenzen/features/dashboard/home/screen/home_screen.dart';
import 'package:zenzen/features/dashboard/projects/screen/project_list_screen.dart';

import '../../features/auth/login/screen/login_screen.dart';
import '../../features/auth/login/screen/verify_user_screen.dart';
import '../../features/dashboard/chat/screen/chat_dashboard_screen.dart';
import '../../features/dashboard/docs/screen/document_list_screen.dart';
import '../../utils/custom_transition.dart';

class RouteConfig {
  static GoRouter returnRouter() {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      errorPageBuilder: (context, state) {
        return MaterialPage(
          child: Scaffold(
            body: Center(
              child: Text('An error occurred: ${state.error}'),
            ),
          ),
        );
      },
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
        GoRoute(
          path: '/home',
          name: RoutesName.home,
          pageBuilder: (context, state) => customTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionType: PageTransitionType.rightToLeft,
          ),
        ),
        GoRoute(
          path: '/signup',
          name: RoutesName.signup,
          pageBuilder: (context, state) => customTransitionPage(
            key: state.pageKey,
            child: const SignupScreen(),
            transitionType: PageTransitionType.rightToLeft,
          ),
        ),
        GoRoute(
          path: '/register-info',
          name: RoutesName.registerInfo,
          pageBuilder: (context, state) => customTransitionPage(
            key: state.pageKey,
            child: const RegisterScreen(),
            transitionType: PageTransitionType.rightToLeft,
          ),
        ),
        GoRoute(
          path: '/verify-user',
          name: RoutesName.verifyUser,
          pageBuilder: (context, state) {
            final email = state.extra as String;
            return customTransitionPage(
              key: state.pageKey,
              child: VerifyUserScreen(email: email),
              transitionType: PageTransitionType.rightToLeft,
            );
          },
        ),
        GoRoute(
          path: '/docs/:id',
          pageBuilder: (context, state) {
            final docId = state.pathParameters['id'] ?? '';
            final docTitle = state.extra as String? ?? 'Untitled';
            return customTransitionPage(
              key: state.pageKey,
              child: NewDocumentScreen(id: docId, title: docTitle),
              transitionType: PageTransitionType.fade,
            );
          },
          name: RoutesName.doc,
        ),
        GoRoute(
          path: '/all-documents',
          name: RoutesName.allDocs,
          pageBuilder: (context, state) {
            return customTransitionPage(
              key: state.pageKey,
              child: const DocumentScreen(),
              transitionType: PageTransitionType.fade,
            );
          },
        ),
        GoRoute(
          path: '/all-projects',
          name: RoutesName.allProjects,
          pageBuilder: (context, state) {
            return customTransitionPage(
              key: state.pageKey,
              child: const ProjectListScreen(),
              transitionType: PageTransitionType.fade,
            );
          },
        ),
        GoRoute(
          path: '/file-transfer',
          name: RoutesName.fileTransfer,
          pageBuilder: (context, state) {
            return customTransitionPage(
              key: state.pageKey,
              child: const FileTransferScreen(),
              transitionType: PageTransitionType.rightToLeftWithFade,
            );
          },
        ),
        // GoRoute(
        //   path: '/contact-us',
        //   name: RoutesName.contactUs,
        //   pageBuilder: (context, state) {
        //     return const MaterialPage(child: ContactUsScreen());
        //   },
        // ),
        GoRoute(
          path: '/messaging-screen',
          name: RoutesName.messagingScreen,
          pageBuilder: (context, state) {
            return MaterialPage(child: ChatDashboardScreen());
          },
        )
      ],
    );
  }
}
