import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import '../../auth/application/auth_controller.dart';
import '../../auth/application/auth_guard.dart';
import '../../auth/data/session_store.dart';
import '../../../../app/theme/theme_extensions.dart';

class OnboardingOverlayScreen extends ConsumerStatefulWidget {
  const OnboardingOverlayScreen({super.key});

  @override
  ConsumerState<OnboardingOverlayScreen> createState() => _OnboardingOverlayScreenState();
}

class _OnboardingOverlayScreenState extends ConsumerState<OnboardingOverlayScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  
  late AnimationController _orbitController;
  late AnimationController _cursorController;
  late AnimationController _fadeController;
  
  late Animation<double> _fadeAnimation;

  final List<_OnboardingStep> _steps = [
    _OnboardingStep(
      title: 'This is you',
      description: 'Everything revolves around you.',
      activeColor: Color(0xFF6366F1),
    ),
    _OnboardingStep(
      title: 'Discover',
      description: 'Your digital universe. Explore trends and suggestions.',
      activeColor: Color(0xFF3B82F6),
    ),
    _OnboardingStep(
      title: 'Social',
      description: "See what's happening now. Live universe feed.",
      activeColor: Color(0xFFEC4899),
    ),
    _OnboardingStep(
      title: 'Messages',
      description: 'Connect instantly with your network.',
      activeColor: Color(0xFF10B981),
    ),
    _OnboardingStep(
      title: 'Business',
      description: 'Your economic layer.',
      activeColor: Color(0xFF8B5CF6),
    ),
    _OnboardingStep(
      title: 'AI Hub',
      description: 'Automates your work.',
      activeColor: Color(0xFF06B6D4),
    ),
  ];


  @override
  void initState() {
    super.initState();
    
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _cursorController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _fadeController.reverse().then((_) {
        _cursorController.forward(from: 0.0).then((_) {
          setState(() {
            _currentStep++;
          });
          _fadeController.forward();
        });
      });
    } else {
      _completeOnboarding();
    }
  }

  void _skip() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final sessionStore = ref.read(sessionStoreProvider);
    await sessionStore.saveSession('mock_google_user');
    
    ref.read(authControllerProvider.notifier).setAuthenticatedMock();
    ref.read(authGuardProvider.notifier).setAuthenticated();
    
    if (mounted) {
      context.go('/app');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStepData = _steps[_currentStep];
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final safePadding = mediaQuery.padding;
    final usableHeight = screenHeight - safePadding.top - safePadding.bottom - 350;
    final usableWidth = screenWidth - 120;
    final shortestUsable = math.min(usableWidth, usableHeight);
    final orbitRadius = math.min(shortestUsable * 0.38, 160.0);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: Stack(
        children: [
          Builder(
            builder: (context) {
              final centerY = (screenHeight - safePadding.bottom - 320) / 2 + safePadding.top;
              return Positioned.fill(
                child: AnimatedBuilder(
                  animation: _orbitController,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(screenWidth, screenHeight),
                      painter: _OrbitRingsPainter(
                        rotation: _orbitController.value * 2 * math.pi * 0.1,
                        orbitRadius: orbitRadius,
                        centerY: centerY,
                        ringColor: context.dividerColor,
                      ),
                    );
                  },
                ),
              );
            },
          ),

          Positioned.fill(
            child: Builder(
              builder: (context) {
                final centerY = (screenHeight - safePadding.bottom - 320) / 2 + safePadding.top;
                return Stack(
                  children: [
                    ..._buildOrbitPlanets(screenWidth, screenHeight, orbitRadius, centerY, context),
                    _buildCenterProfile(centerY, context),
                  ],
                );
              },
            ),
          ),

          AnimatedBuilder(
            animation: Listenable.merge([_cursorController, _orbitController]),
            builder: (context, child) {
              final usableHeight = screenHeight - safePadding.top - safePadding.bottom - 350;
              final usableWidth = screenWidth - 120;
              final shortestUsable = math.min(usableWidth, usableHeight);
              final orbitRadius = math.min(shortestUsable * 0.38, 160.0);
              final centerX = screenWidth / 2;
              final centerY = (screenHeight - safePadding.bottom - 320) / 2 + safePadding.top;
              
              Offset getCursorPosition(int step) {
                if (step == 0) {
                  return Offset(centerX, centerY);
                }
                final angles = [
                  -math.pi / 2,
                  -math.pi / 6,
                  math.pi / 3,
                  2 * math.pi / 3,
                  7 * math.pi / 6,
                ];
                final angle = angles[step - 1] + (_orbitController.value * 2 * math.pi * 0.05);
                return Offset(
                  centerX + (orbitRadius * math.cos(angle)),
                  centerY + (orbitRadius * math.sin(angle)),
                );
              }
              
              Offset cursorPos;
              if (_cursorController.isAnimating) {
                final startPos = getCursorPosition(_currentStep);
                final endPos = getCursorPosition(_currentStep + 1 < _steps.length ? _currentStep + 1 : _currentStep);
                cursorPos = Offset.lerp(startPos, endPos, _cursorController.value)!;
              } else {
                cursorPos = getCursorPosition(_currentStep);
              }
              
              return Positioned(
                left: cursorPos.dx,
                top: cursorPos.dy,
                child: _MouseCursor(),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                Spacer(),

                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, 16 * (1 - _fadeAnimation.value)),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: context.cardColor,
                            border: Border.all(
                              color: context.dividerColor,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 30,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentStepData.title,
                                style: TextStyle(
                                  color: context.onSurface,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                currentStepData.description,
                                style: TextStyle(
                                  color: context.onSurfaceVariant,
                                  fontSize: 15,
                                  height: 1.4,
                                ),
                              ),
                              SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF6366F1),
                                        Color(0xFFAB5CF6),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _nextStep,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Next',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Icon(
                                          Icons.chevron_right,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 16),

                TextButton(
                  onPressed: _skip,
                  child: Text(
                    'Skip tour',
                    style: TextStyle(
                      color: context.hintColor,
                      fontSize: 13,
                    ),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOrbitPlanets(double screenWidth, double screenHeight, double orbitRadius, double centerY, BuildContext context) {
    final sections = [
      _OrbitSection(
        name: 'Discover',
        icon: Icons.explore_outlined,
        color: Color(0xFF3B82F6),
        angle: -math.pi / 2,
      ),
      _OrbitSection(
        name: 'Social',
        icon: Icons.people_outline,
        color: Color(0xFFEC4899),
        angle: -math.pi / 6,
      ),
      _OrbitSection(
        name: 'Messages',
        icon: Icons.chat_bubble_outline,
        color: Color(0xFF10B981),
        angle: math.pi / 3,
      ),
      _OrbitSection(
        name: 'Business',
        icon: Icons.business_center_outlined,
        color: Color(0xFF8B5CF6),
        angle: 2 * math.pi / 3,
      ),
      _OrbitSection(
        name: 'AI Hub',
        icon: Icons.auto_awesome_outlined,
        color: Color(0xFF06B6D4),
        angle: 7 * math.pi / 6,
      ),
    ];

    return sections.map((section) {
      final angle = section.angle + (_orbitController.value * 2 * math.pi * 0.05);
      final x = (screenWidth / 2) + (orbitRadius * math.cos(angle)) - 24;
      final y = centerY + (orbitRadius * math.sin(angle)) - 35;

      return Positioned(
        left: x,
        top: y,
        child: _OrbitPlanet(section: section, context: context),
      );
    }).toList();
  }

  Widget _buildCenterProfile(double centerY, BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: centerY - 60,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF615FFF).withValues(alpha: 0.15),
                  blurRadius: 80,
                  spreadRadius: 20,
                ),
                BoxShadow(
                  color: Color(0xFF615FFF).withValues(alpha: 0.3),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.cardColor,
                border: Border.all(
                  color: context.dividerColor,
                  width: 1,
                ),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=faces',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
          Text(
            'My Profile',
            style: TextStyle(
              color: context.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final String description;
  final Color activeColor;

  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.activeColor,
  });
}

class _OrbitSection {
  final String name;
  final IconData icon;
  final Color color;
  final double angle;

  const _OrbitSection({
    required this.name,
    required this.icon,
    required this.color,
    required this.angle,
  });
}

class _OrbitPlanet extends StatelessWidget {
  final _OrbitSection section;
  final BuildContext context;

  const _OrbitPlanet({required this.section, required this.context});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: section.color,
            boxShadow: [
              BoxShadow(
                color: section.color.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Icon(
            section.icon,
            color: Colors.white,
            size: 22,
          ),
        ),
        SizedBox(height: 6),
        Text(
          section.name,
          style: TextStyle(
            color: this.context.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _OrbitRingsPainter extends CustomPainter {
  final double rotation;
  final double orbitRadius;
  final double centerY;
  final Color ringColor;

  _OrbitRingsPainter({
    required this.rotation,
    required this.orbitRadius,
    required this.centerY,
    required this.ringColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, centerY);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    paint.color = ringColor.withValues(alpha: 0.15);
    canvas.drawCircle(center, orbitRadius, paint);

    paint.color = ringColor.withValues(alpha: 0.1);
    canvas.drawCircle(center, orbitRadius * 0.7, paint);

    paint.color = ringColor.withValues(alpha: 0.05);
    canvas.drawCircle(center, orbitRadius * 1.3, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingsPainter oldDelegate) {
    return oldDelegate.rotation != rotation || oldDelegate.ringColor != ringColor;
  }
}

class _MouseCursor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(24, 24),
      painter: _MouseCursorPainter(),
    );
  }
}

class _MouseCursorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(0, 18)
      ..lineTo(5, 14)
      ..lineTo(8, 20)
      ..lineTo(10, 19)
      ..lineTo(7, 13)
      ..lineTo(13, 13)
      ..close();

    canvas.drawPath(path.shift(Offset(1, 1)), shadowPaint);
    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
