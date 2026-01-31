import 'package:flutter/material.dart';

abstract final class UAxisMotion {
  static const Duration quickResponse = Duration(milliseconds: 200);
  static const Duration quickResponseMax = Duration(milliseconds: 300);
  
  static const Duration purposeful = Duration(milliseconds: 300);
  static const Duration purposefulMax = Duration(milliseconds: 500);
  
  static const Duration pageTransition = Duration(milliseconds: 400);
  
  static const Duration modalOpen = Duration(milliseconds: 300);
  
  static const Duration clickFeedback = Duration(milliseconds: 150);
  
  static const Duration successFeedback = Duration(milliseconds: 300);
  static const Duration dismissSlideOut = Duration(milliseconds: 200);

  static const Curve quickCurve = Curves.easeOut;
  
  static const Curve purposefulCurve = Curves.easeInOut;
  
  static const Curve staggeredCurve = Curves.easeOutCubic;
  
  static const Curve bounceCurve = Curves.elasticOut;
}

abstract final class UAxisInteraction {
  static const double hoverScale = 1.02;
  
  static const double clickScale = 0.98;
  
  static const double modalInitialScale = 0.95;
  
  static const double hoverLiftY = -2.0;
}

abstract final class UAxisTypography {
  static const double bodyLineHeight = 1.5;
  static const double headingLineHeight = 1.2;
  
  static const double largeHeadingLetterSpacing = -0.02;
  static const double bodyLetterSpacing = 0.0;
  
  static const int paragraphMaxChars = 75;
  static const int paragraphMinChars = 65;
  
  static const double hierarchyRatio = 1.25;
  
  static const double contrastRatioBody = 4.5;
  static const double contrastRatioLarge = 3.0;
}

class InteractiveScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  const InteractiveScale({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<InteractiveScale> createState() => _InteractiveScaleState();
}

class _InteractiveScaleState extends State<InteractiveScale> {
  bool _isPressed = false;
  bool _isHovered = false;

  double get _scale {
    if (_isPressed) return UAxisInteraction.clickScale;
    if (_isHovered) return UAxisInteraction.hoverScale;
    return 1.0;
  }

  double get _translateY {
    if (_isHovered && !_isPressed) return UAxisInteraction.hoverLiftY;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: _isPressed 
              ? UAxisMotion.clickFeedback 
              : UAxisMotion.quickResponse,
          curve: UAxisMotion.quickCurve,
          transformAlignment: Alignment.center,
          child: Transform.translate(
            offset: Offset(0.0, _translateY),
            child: Transform.scale(
              scale: _scale,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

class FadeSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset beginOffset;

  const FadeSlideTransition({
    super.key,
    required this.animation,
    required this.child,
    this.beginOffset = const Offset(0.0, 0.05),
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: UAxisMotion.purposefulCurve,
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: UAxisMotion.staggeredCurve,
        )),
        child: child,
      ),
    );
  }
}

class ModalScaleTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const ModalScaleTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: UAxisMotion.purposefulCurve,
      ),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: UAxisInteraction.modalInitialScale,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: UAxisMotion.staggeredCurve,
        )),
        child: child,
      ),
    );
  }
}

class StaggeredListBuilder extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int, Animation<double>) itemBuilder;
  final Duration staggerDelay;
  final Duration itemDuration;

  const StaggeredListBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.staggerDelay = const Duration(milliseconds: 50),
    this.itemDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: itemDuration,
          curve: UAxisMotion.staggeredCurve,
          builder: (context, value, child) {
            return itemBuilder(
              context,
              index,
              AlwaysStoppedAnimation(value),
            );
          },
        );
      },
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
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
    final baseColor = widget.baseColor ?? Colors.white.withValues(alpha: 0.05);
    final highlightColor = widget.highlightColor ?? Colors.white.withValues(alpha: 0.15);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

class SuccessBounce extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final VoidCallback? onComplete;

  const SuccessBounce({
    super.key,
    required this.child,
    required this.trigger,
    this.onComplete,
  });

  @override
  State<SuccessBounce> createState() => _SuccessBounceState();
}

class _SuccessBounceState extends State<SuccessBounce>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: UAxisMotion.successFeedback,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.15),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.15, end: 0.95),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.95, end: 1.0),
        weight: 30,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: UAxisMotion.quickCurve,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(SuccessBounce oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: widget.child,
        );
      },
    );
  }
}

class AutoDismissSlideOut extends StatefulWidget {
  final Widget child;
  final Duration displayDuration;
  final VoidCallback? onDismissed;

  const AutoDismissSlideOut({
    super.key,
    required this.child,
    this.displayDuration = const Duration(seconds: 3),
    this.onDismissed,
  });

  @override
  State<AutoDismissSlideOut> createState() => _AutoDismissSlideOutState();
}

class _AutoDismissSlideOutState extends State<AutoDismissSlideOut>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: UAxisMotion.dismissSlideOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: UAxisMotion.quickCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: UAxisMotion.quickCurve,
    ));

    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.forward().then((_) {
          widget.onDismissed?.call();
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
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: widget.child,
      ),
    );
  }
}
