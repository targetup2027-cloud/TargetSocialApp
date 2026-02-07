import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../motion/motion_system.dart';

abstract final class NavigationTransitions {
  static CustomTransitionPage<T> fade<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: MotionTokens.pageTransition,
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<T> fadeSlideUp<T>({
    required LocalKey key,
    required Widget child,
    double slideOffset = 0.03,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: MotionTokens.pageTransition,
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(0.0, slideOffset),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> sharedAxis<T>({
    required LocalKey key,
    required Widget child,
    SharedAxisDirection direction = SharedAxisDirection.horizontal,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.2, 0.0, 0.0, 1.0),
          reverseCurve: const Cubic(0.4, 0.0, 1.0, 1.0),
        );

        final offset = switch (direction) {
          SharedAxisDirection.horizontal => Tween<Offset>(
              begin: const Offset(0.3, 0.0),
              end: Offset.zero,
            ),
          SharedAxisDirection.vertical => Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ),
        };

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
            ),
          ),
          child: SlideTransition(
            position: offset.animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> containerTransform<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.05, 0.7, 0.1, 1.0),
          reverseCurve: const Cubic(0.3, 0.0, 0.8, 0.15),
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            ),
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnimation),
            alignment: Alignment.center,
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> fadeThrough<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  static CustomTransitionPage<T> slideFromRight<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.2, 0.0, 0.0, 1.0),
          reverseCurve: const Cubic(0.4, 0.0, 1.0, 1.0),
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }

  static CustomTransitionPage<T> slideFromBottom<T>({
    required LocalKey key,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.2, 0.0, 0.0, 1.0),
          reverseCurve: const Cubic(0.4, 0.0, 1.0, 1.0),
        );

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.15),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

enum SharedAxisDirection {
  horizontal,
  vertical,
}

class _FadeThroughTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _FadeThroughTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: animation,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
        ),
      ),
      child: FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: secondaryAnimation,
            curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
          ),
        ),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Cubic(0.2, 0.0, 0.0, 1.0),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;

  SmoothPageRoute({
    required this.page,
    this.transitionType = TransitionType.fadeSlideUp,
  }) : super(
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(transitionType, animation, secondaryAnimation, child);
          },
        );

  static Widget _buildTransition(
    TransitionType type,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      case TransitionType.fadeSlideUp:
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.03),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      case TransitionType.slideFromRight:
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.2, 0.0, 0.0, 1.0),
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5),
              ),
            ),
            child: child,
          ),
        );
      case TransitionType.scale:
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.05, 0.7, 0.1, 1.0),
        );
        return FadeTransition(
          opacity: curvedAnimation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnimation),
            child: child,
          ),
        );
    }
  }
}

enum TransitionType {
  fade,
  fadeSlideUp,
  slideFromRight,
  scale,
}
