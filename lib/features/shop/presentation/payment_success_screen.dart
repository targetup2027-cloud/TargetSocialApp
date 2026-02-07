import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../app/theme/theme_extensions.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderNumber = '#UAXIS-2024-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      drawer: UAxisDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Opacity(
                          opacity: _fadeAnimation.value,
                          child: Text(
                            'Payment Successful!',
                            style: TextStyle(
                              color: context.onSurface,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Opacity(
                          opacity: _fadeAnimation.value,
                          child: Text(
                            'Your order has been confirmed and will be shipped soon.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: context.onSurfaceVariant,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Opacity(
                          opacity: _fadeAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: context.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: context.dividerColor,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Order Number',
                                  style: TextStyle(
                                    color: context.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  orderNumber,
                                  style: const TextStyle(
                                    color: Color(0xFF8B5CF6),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Opacity(
                          opacity: _fadeAnimation.value,
                          child: GestureDetector(
                            onTap: () {},
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B5CF6),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'View Order Details',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Opacity(
                          opacity: _fadeAnimation.value,
                          child: GestureDetector(
                            onTap: () => context.go('/app'),
                            child: Text(
                              'Back to Home',
                              style: TextStyle(
                                color: context.hintColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Builder(
            builder: (context) => SideMenuToggle(
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const UniverseBackButton(),
        ],
      ),
    );
  }
}
