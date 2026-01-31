import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RippleConfig {
  final int rippleCount;
  final Duration totalDuration;
  final double rippleStrokeWidth;
  final Color rippleColor;
  final double maxRippleRadius;
  final double staggerFraction;

  const RippleConfig({
    this.rippleCount = 4,
    this.totalDuration = const Duration(milliseconds: 3000),
    this.rippleStrokeWidth = 1.5,
    this.rippleColor = Colors.white,
    this.maxRippleRadius = 200.0,
    this.staggerFraction = 0.25,
  });
}

class SplashScreen extends StatefulWidget {
  final Widget? centerWidget;
  final RippleConfig config;
  final VoidCallback? onAnimationComplete;

  const SplashScreen({
    super.key,
    this.centerWidget,
    this.config = const RippleConfig(),
    this.onAnimationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rippleController;
  late final AnimationController _logoController;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      vsync: this,
      duration: widget.config.totalDuration,
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _logoController.forward();
    _rippleController.repeat();

    Future.delayed(widget.config.totalDuration + const Duration(milliseconds: 500), () {
      if (mounted) {
        widget.onAnimationComplete?.call();
        context.go('/auth');
      }
    });
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(
                    widget.config.maxRippleRadius * 2.5,
                    widget.config.maxRippleRadius * 2.5,
                  ),
                  painter: _RipplePainter(
                    progress: _rippleController.value,
                    config: widget.config,
                  ),
                );
              },
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFadeAnimation.value,
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: widget.centerWidget ?? _buildDefaultLogo(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLogo() {
    return const Text(
      'U-AXIS',
      style: TextStyle(
        color: Colors.white,
        fontSize: 42,
        fontWeight: FontWeight.w300,
        letterSpacing: 16,
      ),
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final RippleConfig config;

  _RipplePainter({
    required this.progress,
    required this.config,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < config.rippleCount; i++) {
      final staggerOffset = i * config.staggerFraction / config.rippleCount;
      final rippleProgress = (progress + staggerOffset) % 1.0;

      final curvedProgress = Curves.easeOutCirc.transform(rippleProgress);

      final radius = curvedProgress * config.maxRippleRadius;

      final opacity = (1.0 - curvedProgress).clamp(0.0, 1.0) * 0.6;

      if (opacity > 0 && radius > 0) {
        final paint = Paint()
          ..color = config.rippleColor.withValues(alpha: opacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = config.rippleStrokeWidth * (1.0 - curvedProgress * 0.5);

        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
