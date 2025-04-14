import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

CustomTransitionPage customTransitionPage({
  required Widget child,
  required LocalKey key,
  required PageTransitionType transitionType,
}) {
  return CustomTransitionPage(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return PageTransition(
        type: transitionType,
        child: child,
        duration: const Duration(milliseconds: 300),
      ).buildTransitions(
        context,
        animation,
        secondaryAnimation,
        child,
      );
    },
  );
}
