import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class LogoAssemblyScreen extends StatefulWidget {
  const LogoAssemblyScreen({super.key});

  @override
  State<LogoAssemblyScreen> createState() => _LogoAssemblyScreenState();
}

class _LogoAssemblyScreenState extends State<LogoAssemblyScreen>
    with TickerProviderStateMixin {
  late AnimationController _assemblyController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  final String _logoText = 'U-ΛXIS';
  final List<_LetterData> _letterData = [];

  @override
  void initState() {
    super.initState();

    _assemblyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: const Cubic(0.4, 0, 0.2, 1),
      ),
    );

    final random = math.Random(42);
    for (int i = 0; i < _logoText.length; i++) {
      _letterData.add(_LetterData(
        char: _logoText[i],
        startOffsetX: (random.nextDouble() - 0.5) * 300,
        startOffsetY: (random.nextDouble() - 0.5) * 400,
        startRotation: (random.nextDouble() - 0.5) * math.pi,
        delay: i * 0.08,
      ));
    }

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      _assemblyController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 1400));

    if (mounted) {
      _glowController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 2500));

    if (mounted) {
      context.go('/onboarding');
    }
  }

  @override
  void dispose() {
    _assemblyController.dispose();
    _glowController.dispose();
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
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF615FFF).withValues(alpha: 0.15 * _glowAnimation.value),
                        blurRadius: 80 * _glowAnimation.value,
                        spreadRadius: 20 * _glowAnimation.value,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(180, 180),
                  painter: _CircleRingPainter(
                    progress: _glowAnimation.value,
                    color: const Color(0xFF615FFF),
                  ),
                );
              },
            ),
          ),

          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_letterData.length, (index) {
                final data = _letterData[index];
                return _AnimatedLetter(
                  animation: _assemblyController,
                  data: data,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _LetterData {
  final String char;
  final double startOffsetX;
  final double startOffsetY;
  final double startRotation;
  final double delay;

  _LetterData({
    required this.char,
    required this.startOffsetX,
    required this.startOffsetY,
    required this.startRotation,
    required this.delay,
  });
}

class _AnimatedLetter extends StatelessWidget {
  final Animation<double> animation;
  final _LetterData data;

  const _AnimatedLetter({
    required this.animation,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final start = data.delay;
        final end = (start + 0.6).clamp(0.0, 1.0);
        
        final progress = ((animation.value - start) / (end - start)).clamp(0.0, 1.0);
        final curvedProgress = Curves.easeOutCubic.transform(progress);

        final offsetX = data.startOffsetX * (1 - curvedProgress);
        final offsetY = data.startOffsetY * (1 - curvedProgress);
        final rotation = data.startRotation * (1 - curvedProgress);
        final opacity = curvedProgress;
        final scale = 0.5 + (0.5 * curvedProgress);

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: Transform.rotate(
            angle: rotation,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: Text(
                  data.char,
                  style: TextStyle(
                    color: const Color(0xFFF0F0F0),
                    fontSize: 42,
                    fontWeight: FontWeight.w200,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.2 * opacity),
                        blurRadius: 10,
                        offset: Offset.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CircleRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircleRingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = color.withValues(alpha: 0.3 * progress);

    canvas.drawCircle(center, radius * progress, paint);
  }

  @override
  bool shouldRepaint(covariant _CircleRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
