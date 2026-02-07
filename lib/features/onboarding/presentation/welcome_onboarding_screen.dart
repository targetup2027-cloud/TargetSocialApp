import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/motion/motion_system.dart';
import '../../../../app/theme/uaxis_theme.dart';
import '../../../../app/theme/theme_extensions.dart';

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  State<WelcomeOnboardingScreen> createState() => _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: MotionTokens.entrance),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: MotionTokens.entrance),
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
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
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 32.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: _buildProgress(true)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildProgress(false)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildProgress(false)),
                            ],
                          ),
                        ),
                        
                        const Spacer(),
                        
                        SlideTransition(
                          position: _slideAnimation,
                          child: AnimatedBuilder(
                            animation: _glowAnimation,
                            builder: (context, child) {
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 140 * _glowAnimation.value,
                                    height: 140 * _glowAnimation.value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: UAxisColors.businessAi.withValues(alpha: 0.15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: UAxisColors.businessAi.withValues(alpha: 0.2),
                                          blurRadius: 60,
                                          spreadRadius: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: context.cardColor,
                                      gradient: null,
                                      border: Border.all(
                                        color: context.dividerColor,
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome,
                                      color: context.onSurface,
                                      size: 40,
                                    ),
                                  ),
                                  Positioned(
                                    top: 24,
                                    right: 28,
                                    child: Icon(
                                      Icons.star,
                                      color: context.onSurface.withValues(alpha: 0.8),
                                      size: 16,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Column(
                              children: [
                                Text(
                                  'Welcome to U-ΛXIS',
                                  style: TextStyle(
                                    color: context.onSurface,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Your all-in-one business intelligence platform. Manage products, engage with AI agents, and grow your business.',
                                  style: TextStyle(
                                    color: context.onSurfaceVariant,
                                    fontSize: 16,
                                    height: 1.5,
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const Spacer(),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                          child: Row(
                            children: [
                              TapScaleButton(
                                onTap: () => context.go('/login'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(color: context.dividerColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Skip',
                                    style: TextStyle(
                                      color: context.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TapScaleButton(
                                  onTap: () => context.go('/orbital-home-onboarding'),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: context.onSurface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Next',
                                          style: TextStyle(
                                            color: context.scaffoldBg,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(Icons.chevron_right, color: context.scaffoldBg, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(bool isActive) {
    return AnimatedContainer(
      duration: MotionTokens.purposeful,
      height: 4,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF8B5CF6) : const Color(0xFF8B5CF6).withValues(alpha: 0.2), // Use primary color
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
