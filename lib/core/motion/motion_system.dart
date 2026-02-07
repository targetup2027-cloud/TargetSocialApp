import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

class OpenContainerWrapper extends StatelessWidget {
  final Widget closedBuilder;
  final Widget openBuilder;
  final VoidCallback? onClosed;
  final Color closedColor;
  final Color openColor;
  final double closedElevation;
  final double openElevation;
  final Duration transitionDuration;
  final ShapeBorder closedShape;
  final ShapeBorder openShape;
  final bool tappable;

  const OpenContainerWrapper({
    super.key,
    required this.closedBuilder,
    required this.openBuilder,
    this.onClosed,
    this.closedColor = Colors.transparent,
    this.openColor = Colors.transparent,
    this.closedElevation = 0,
    this.openElevation = 0,
    this.transitionDuration = const Duration(milliseconds: 400),
    this.closedShape = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
    this.openShape = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(0))),
    this.tappable = true,
  });

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedElevation: closedElevation,
      openElevation: openElevation,
      closedColor: closedColor,
      openColor: openColor,
      closedShape: closedShape,
      openShape: openShape,
      transitionDuration: transitionDuration,
      transitionType: ContainerTransitionType.fadeThrough,
      onClosed: onClosed != null ? (_) => onClosed!() : null,
      tappable: tappable,
      openBuilder: (context, action) => openBuilder,
      closedBuilder: (context, action) => closedBuilder,
    );
  }
}

abstract final class MotionTokens {
  static const Duration quick = Duration(milliseconds: 250);
  static const Duration purposeful = Duration(milliseconds: 400);
  static const Duration hover = Duration(milliseconds: 200);
  static const Duration tap = Duration(milliseconds: 150);
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration modalOpen = Duration(milliseconds: 300);
  static const Duration successIn = Duration(milliseconds: 300);
  static const Duration successOut = Duration(milliseconds: 200);

  static const Curve entrance = Cubic(0, 0, 0.2, 1);
  static const Curve exit = Cubic(0.4, 0, 1, 1);
  static const Curve transition = Cubic(0.4, 0, 0.2, 1);
  static const Curve loading = Curves.linear;
}

class TapScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const TapScaleButton({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.98,
  });

  @override
  State<TapScaleButton> createState() => _TapScaleButtonState();
}

class _TapScaleButtonState extends State<TapScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.tap,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressedScale).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.entrance),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

class HoverScaleCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverScale;

  const HoverScaleCard({
    super.key,
    required this.child,
    this.onTap,
    this.hoverScale = 1.02,
  });

  @override
  State<HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<HoverScaleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? widget.hoverScale : 1.0,
          duration: MotionTokens.hover,
          curve: MotionTokens.entrance,
          child: AnimatedContainer(
            duration: MotionTokens.hover,
            curve: MotionTokens.entrance,
            child: Transform.translate(
              offset: Offset(0.0, _isHovered ? -2.0 : 0.0),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

enum MotionTransitionType {
  fadeSlide,
  slideFromRight,
  scale,
  fadeThrough,
}

class MotionPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final MotionTransitionType transitionType;

  MotionPageRoute({
    required this.page,
    this.transitionType = MotionTransitionType.fadeSlide,
  }) : super(
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return _buildTransition(transitionType, animation, secondaryAnimation, child);
          },
        );

  static Widget _buildTransition(
    MotionTransitionType type,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    switch (type) {
      case MotionTransitionType.fadeSlide:
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.2, 0.0, 0.0, 1.0),
          reverseCurve: const Cubic(0.4, 0.0, 1.0, 1.0),
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
            ),
          ),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.03),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      case MotionTransitionType.slideFromRight:
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
      case MotionTransitionType.scale:
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
      case MotionTransitionType.fadeThrough:
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
}

class MotionModal extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const MotionModal({
    super.key,
    required this.child,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: MotionTokens.entrance,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.95, end: 1.0).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}

Future<T?> showMotionModal<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  FocusManager.instance.primaryFocus?.unfocus();
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: MotionTokens.modalOpen,
    pageBuilder: (context, animation, secondaryAnimation) {
      return MotionModal(
        animation: animation,
        child: builder(context),
      );
    },
  );
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFF1A1A1A),
    this.highlightColor = const Color(0xFF2A2A2A),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                0.0,
                _controller.value,
                1.0,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

enum FeedbackType { success, error }

class FeedbackToast extends StatefulWidget {
  final String message;
  final FeedbackType type;
  final VoidCallback onDismiss;
  final Duration displayDuration;

  const FeedbackToast({
    super.key,
    required this.message,
    required this.type,
    required this.onDismiss,
    this.displayDuration = const Duration(seconds: 3),
  });

  @override
  State<FeedbackToast> createState() => _FeedbackToastState();
}

class _FeedbackToastState extends State<FeedbackToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: MotionTokens.successIn,
      reverseDuration: MotionTokens.successOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.entrance),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: MotionTokens.entrance),
    );

    _controller.forward();

    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
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
    final color = widget.type == FeedbackType.success
        ? const Color(0xFF10B981)
        : const Color(0xFFEF4444);

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.type == FeedbackType.success
                    ? Icons.check_circle_outline
                    : Icons.error_outline,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.message,
                  style: TextStyle(color: color, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StaggeredFadeSlide extends StatelessWidget {
  final Animation<double> animation;
  final int index;
  final Widget child;
  final Duration staggerDelay;

  const StaggeredFadeSlide({
    super.key,
    required this.animation,
    required this.index,
    required this.child,
    this.staggerDelay = const Duration(milliseconds: 50),
  });

  @override
  Widget build(BuildContext context) {
    final delayedStart = (index * staggerDelay.inMilliseconds) / 
        (MotionTokens.pageTransition.inMilliseconds + (5 * staggerDelay.inMilliseconds));
    final delayedEnd = delayedStart + 
        (MotionTokens.pageTransition.inMilliseconds / 
        (MotionTokens.pageTransition.inMilliseconds + (5 * staggerDelay.inMilliseconds)));

    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Interval(
        delayedStart.clamp(0.0, 1.0),
        delayedEnd.clamp(0.0, 1.0),
        curve: MotionTokens.transition,
      ),
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}
