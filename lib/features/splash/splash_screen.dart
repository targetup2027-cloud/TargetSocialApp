import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/application/auth_controller.dart';
import '../../data/seed/auth_seed.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _authInitialized = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    if (_authInitialized) return;
    _authInitialized = true;

    try {
      await ref.read(authSeedProvider.future);
    } catch (_) {}

    if (mounted) {
      await ref.read(authControllerProvider.notifier).initialize();
    }

    await Future.delayed(const Duration(milliseconds: 3000));

    if (mounted && !_navigated) {
      _navigated = true;
      final authState = ref.read(authControllerProvider);
      if (authState.status == AuthStatus.authenticated) {
        context.go('/app');
      } else {
        context.go('/welcome-onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ShatteredLogoReveal(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'U-ΛXIS',
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 42,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 6,
                  shadows: [
                    Shadow(
                      color: Color(0xFFFFFFFF),
                      blurRadius: 30,
                      offset: Offset.zero,
                    ),
                    Shadow(
                      color: Color(0x99FFFFFF),
                      blurRadius: 60,
                      offset: Offset.zero,
                    ),
                    Shadow(
                      color: Color(0x66FFFFFF),
                      blurRadius: 90,
                      offset: Offset.zero,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'BUSINESS INTELLIGENCE PLATFORM',
                style: TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Color(0x66FFFFFF),
                      blurRadius: 10,
                      offset: Offset.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShatteredLogoReveal extends StatefulWidget {
  final Widget child;

  const ShatteredLogoReveal({
    super.key,
    required this.child,
  });

  @override
  State<ShatteredLogoReveal> createState() => _ShatteredLogoRevealState();
}

class _ShatteredLogoRevealState extends State<ShatteredLogoReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _particleFade;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  final List<_Particle> _particles = [];
  final _random = math.Random();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 40; i++) {
      _particles.add(_Particle(
        x: (_random.nextDouble() - 0.5) * 300,
        y: (_random.nextDouble() - 0.5) * 300,
        size: _random.nextDouble() * 8 + 4,
        rotation: _random.nextDouble() * math.pi * 2,
        velocity: _random.nextDouble() * 2 + 1,
        angle: _random.nextDouble() * math.pi * 2,
      ));
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _particleFade = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 10,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
    ]).animate(_controller);

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
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
        return Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              painter: _ParticlePainter(
                particles: _particles,
                progress: _controller.value,
                opacity: _particleFade.value,
              ),
              size: const Size(400, 400),
            ),
            Opacity(
              opacity: _logoFade.value,
              child: Transform.scale(
                scale: _logoScale.value,
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double rotation;
  final double velocity;
  final double angle;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.velocity,
    required this.angle,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final double opacity;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (final particle in particles) {
      final distance = (1.0 - progress) * particle.velocity * 150;
      final currentX = centerX + particle.x + math.cos(particle.angle) * distance;
      final currentY = centerY + particle.y + math.sin(particle.angle) * distance;

      paint.color = Color(0xFFFFFFFF).withValues(alpha: opacity * 0.7);

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(particle.rotation + progress * math.pi * 2);

      final path = Path();
      path.moveTo(0, -particle.size);
      path.lineTo(particle.size * 0.3, 0);
      path.lineTo(0, particle.size);
      path.lineTo(-particle.size * 0.3, 0);
      path.close();

      canvas.drawPath(path, paint);

      paint.color = Color(0xFFFFFFFF).withValues(alpha: opacity * 0.3);
      canvas.drawCircle(Offset.zero, particle.size * 0.4, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.opacity != opacity;
  }
}
