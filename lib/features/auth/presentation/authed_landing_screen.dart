import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

import '../../../app/theme/uaxis_theme.dart';

class AuthedLandingScreen extends ConsumerStatefulWidget {
  const AuthedLandingScreen({super.key});

  @override
  ConsumerState<AuthedLandingScreen> createState() => _AuthedLandingScreenState();
}

class _AuthedLandingScreenState extends ConsumerState<AuthedLandingScreen>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _entranceController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<_OrbitSection> _sections = [
    _OrbitSection(
      name: 'Discover',
      icon: Icons.explore_outlined,
      color: Color(0xFF3B82F6),
      angle: -math.pi / 2,
      entranceDelay: 0.15,
      route: '/discover',
    ),
    _OrbitSection(
      name: 'Social',
      icon: Icons.people_outline,
      color: Color(0xFFEC4899),
      angle: -math.pi / 6,
      entranceDelay: 0.25,
      route: '/social',
    ),
    _OrbitSection(
      name: 'Messages',
      icon: Icons.chat_bubble_outline,
      color: Color(0xFF10B981),
      angle: math.pi / 3,
      entranceDelay: 0.35,
      route: '/messages',
    ),
    _OrbitSection(
      name: 'Business',
      icon: Icons.business_center_outlined,
      color: Color(0xFF8B5CF6),
      angle: 2 * math.pi / 3,
      entranceDelay: 0.45,
      route: '/business',
    ),
    _OrbitSection(
      name: 'AI Hub',
      icon: Icons.auto_awesome_outlined,
      color: Color(0xFF06B6D4),
      angle: 7 * math.pi / 6,
      entranceDelay: 0.55,
      route: '/ai-hub',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
  }

  void _playEntranceAnimation() {
    _entranceController.reset();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _entranceController.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _playEntranceAnimation();
      });
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final safePadding = mediaQuery.padding;
    final usableHeight = screenHeight - safePadding.top - safePadding.bottom - 160;
    final usableWidth = screenWidth - 120;
    final shortestUsable = math.min(usableWidth, usableHeight);
    final orbitRadius = math.min(shortestUsable * 0.4, 180.0);
    final centerY = (screenHeight - safePadding.bottom - 80) / 2 + safePadding.top;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      drawer: _AppDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _orbitController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(screenWidth, screenHeight),
                  painter: _OrbitRingsPainter(
                    rotation: _orbitController.value * 2 * math.pi * 0.1,
                    orbitRadius: orbitRadius,
                    centerY: centerY,
                  ),
                );
              },
            ),
          ),

          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_orbitController, _entranceController]),
              builder: (context, child) {
                final profileScaleCurve = CurvedAnimation(
                  parent: _entranceController,
                  curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
                );
                
                final orbitExpansionCurve = CurvedAnimation(
                  parent: _entranceController,
                  curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
                );

                final currentOrbitRadius = orbitRadius * (0.4 + (0.6 * orbitExpansionCurve.value));
                final baseRotation = _orbitController.value * 2 * math.pi * 0.1;
                final spiralRotation = (1.0 - orbitExpansionCurve.value) * math.pi * 0.5;

                return Stack(
                  children: [
                    ..._sections.asMap().entries.map((entry) {
                      final index = entry.key;
                      final section = entry.value;

                      final itemStart = 0.3 + (index * 0.1);
                      final itemEnd = (itemStart + 0.4).clamp(0.0, 1.0);
                      final itemCurve = CurvedAnimation(
                        parent: _entranceController,
                        curve: Interval(itemStart, itemEnd, curve: Curves.easeOutBack),
                      );

                      final angle = section.angle + baseRotation + spiralRotation;
                      final x = (screenWidth / 2) + (currentOrbitRadius * math.cos(angle)) - 24;
                      final y = centerY + (currentOrbitRadius * math.sin(angle)) - 35;

                      return Positioned(
                        left: x,
                        top: y,
                        child: Transform.scale(
                          scale: itemCurve.value,
                          child: Opacity(
                            opacity: itemCurve.value.clamp(0.0, 1.0),
                            child: _OrbitPlanet(section: section),
                          ),
                        ),
                      );
                    }),

                    Positioned(
                      left: 0,
                      right: 0,
                      top: centerY - 60,
                      child: Transform.scale(
                        scale: profileScaleCurve.value,
                        child: Opacity(
                          opacity: profileScaleCurve.value.clamp(0.0, 1.0),
                          child: _buildCenterProfile(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
                child: Container(
                  width: 32,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _entranceController,
              builder: (context, child) {
                final progress = ((_entranceController.value - 0.7) / 0.3).clamp(0.0, 1.0);
                return Opacity(
                  opacity: progress,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - progress)),
                    child: Center(
                      child: Text(
                        'Tap to explore your universe',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterProfile() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: UAxisColors.businessAi.withValues(alpha: 0.15),
                    blurRadius: 80,
                    spreadRadius: 20,
                  ),
                  BoxShadow(
                    color: const Color(0xFF615FFF).withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
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
            const SizedBox(height: 12),
            Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ],
        );
  }
}

class _OrbitSection {
  final String name;
  final IconData icon;
  final Color color;
  final double angle;
  final double entranceDelay;
  final String route;

  const _OrbitSection({
    required this.name,
    required this.icon,
    required this.color,
    required this.angle,
    required this.entranceDelay,
    required this.route,
  });
}

class _OrbitPlanet extends StatelessWidget {
  final _OrbitSection section;

  const _OrbitPlanet({required this.section});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(section.route),
      child: Column(
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
          const SizedBox(height: 6),
          Text(
            section.name,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrbitRingsPainter extends CustomPainter {
  final double rotation;
  final double orbitRadius;
  final double centerY;

  _OrbitRingsPainter({
    required this.rotation,
    required this.orbitRadius,
    required this.centerY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, centerY);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    paint.color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(center, orbitRadius, paint);

    paint.color = Colors.white.withValues(alpha: 0.03);
    canvas.drawCircle(center, orbitRadius * 0.7, paint);

    paint.color = Colors.white.withValues(alpha: 0.02);
    canvas.drawCircle(center, orbitRadius * 1.3, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitRingsPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
           oldDelegate.orbitRadius != orbitRadius ||
           oldDelegate.centerY != centerY;
  }
}



class _AppDrawer extends StatelessWidget {
  final List<_DrawerItem> _items = [
    _DrawerItem(icon: Icons.home_outlined, label: 'Home', route: '/app'),
    _DrawerItem(icon: Icons.explore_outlined, label: 'Discover', route: '/discover'),
    _DrawerItem(icon: Icons.people_outline, label: 'Social', route: '/social'),
    _DrawerItem(icon: Icons.business_center_outlined, label: 'Businesses', route: '/business'),
    _DrawerItem(icon: Icons.auto_awesome_outlined, label: 'AI Hub', route: '/ai-hub'),
    _DrawerItem(icon: Icons.chat_bubble_outline, label: 'Messages', route: '/messages', badge: 3),
    _DrawerItem(icon: Icons.shopping_bag_outlined, label: 'Shop', route: '/shop'),
    _DrawerItem(icon: Icons.psychology_outlined, label: 'AI Tools', route: '/ai-tools'),
    _DrawerItem(icon: Icons.person_outline, label: 'Profile', route: '/profile'),
    _DrawerItem(icon: Icons.settings_outlined, label: 'Settings', route: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0D0D0D),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'U-ΛXIS',
                        style: TextStyle(
                          color: const Color(0xFFF0F0F0),
                          fontSize: 24,
                          fontWeight: FontWeight.w200,
                          letterSpacing: 4,
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.15),
                              blurRadius: 10,
                              offset: Offset.zero,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'REDEFINING EXCELLENCE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _DrawerListItem(item: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final IconData icon;
  final String label;
  final String route;
  final int? badge;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    this.badge,
  });
}

class _DrawerListItem extends StatelessWidget {
  final _DrawerItem item;

  const _DrawerListItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (item.route == '/app') {
          context.go('/app');
        } else {
          context.push(item.route);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Icon(
              item.icon,
              color: Colors.white.withValues(alpha: 0.7),
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 15,
                ),
              ),
            ),
            if (item.badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.badge}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

