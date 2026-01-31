import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class UAxisSidebar extends StatefulWidget {
  final String activeItem;
  final Function(String) onItemSelected;

  const UAxisSidebar({
    super.key,
    required this.activeItem,
    required this.onItemSelected,
  });

  @override
  State<UAxisSidebar> createState() => _UAxisSidebarState();
}

class _UAxisSidebarState extends State<UAxisSidebar> with TickerProviderStateMixin {
  late List<AnimationController> _itemControllers;
  final List<Map<String, dynamic>> menuItems = [
    {'id': 'Home', 'icon': Icons.home_outlined, 'label': 'Home', 'route': '/app'},
    {'id': 'Discover', 'icon': Icons.explore_outlined, 'label': 'Discover', 'route': '/discover'},
    {'id': 'Social', 'icon': Icons.people_outline, 'label': 'Social', 'route': '/social'},
    {'id': 'Businesses', 'icon': Icons.business_center_outlined, 'label': 'Businesses', 'route': '/business'},
    {'id': 'AI Hub', 'icon': Icons.auto_awesome_outlined, 'label': 'AI Hub', 'route': '/ai-hub'},
    {'id': 'Messages', 'icon': Icons.chat_bubble_outline, 'label': 'Messages', 'badge': 3, 'route': '/messages'},
    {'id': 'Shop', 'icon': Icons.storefront_outlined, 'label': 'Shop', 'route': '/shop'},
    {'id': 'AI Tools', 'icon': Icons.psychology_outlined, 'label': 'AI Tools', 'route': '/ai-tools'},
    {'id': 'Profile', 'icon': Icons.person_outline, 'label': 'Profile', 'route': '/profile'},
    {'id': 'Settings', 'icon': Icons.settings_outlined, 'label': 'Settings', 'route': '/settings'},
  ];

  @override
  void initState() {
    super.initState();
    _itemControllers = List.generate(
      menuItems.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _playEntranceAnimation();
  }

  void _playEntranceAnimation() async {
    for (int i = 0; i < _itemControllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 40));
      if (mounted) {
        _itemControllers[i].forward();
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 260,
          decoration: BoxDecoration(
            color: const Color(0xFF0B0B0E).withValues(alpha: 0.85),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'U-ΛXIS',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF7F56D9), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(
                            'Digital OS v2.0',
                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return AnimatedBuilder(
                        animation: _itemControllers[index],
                        builder: (context, child) {
                          final animation = CurvedAnimation(
                            parent: _itemControllers[index],
                            curve: Curves.easeOutBack,
                          );
                          return Transform.translate(
                            offset: Offset(-30 * (1 - animation.value), 0),
                            child: Opacity(
                              opacity: animation.value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: _SidebarItem(
                          icon: item['icon'],
                          label: item['label'],
                          isActive: widget.activeItem == item['id'],
                          badgeCount: item['badge'] ?? 0,
                          index: index,
                          onTap: () {
                            widget.onItemSelected(item['id']);
                            if (item['route'] != null) {
                              if (item['route'] == '/app') {
                                context.go('/app');
                              } else {
                                context.push(item['route']);
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF7F56D9), Color(0xFF3B82F6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7F56D9).withValues(alpha: 0.3),
                              blurRadius: 12,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'User Account',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Pro Plan',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[600],
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int badgeCount;
  final int index;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.badgeCount = 0,
    required this.index,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> with SingleTickerProviderStateMixin {
  late AnimationController _rippleController;
  late Animation<double> _rippleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _rippleAnimation = CurvedAnimation(
      parent: _rippleController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _rippleController.forward(from: 0);
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF7F56D9);

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          height: widget.isActive ? 32 : 0,
          width: 4,
          decoration: BoxDecoration(
            color: activeColor,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.6),
                      blurRadius: 15,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _rippleAnimation,
              builder: (context, child) {
                return AnimatedScale(
                  scale: _isPressed ? 0.97 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: widget.isActive
                                ? activeColor.withValues(alpha: 0.15)
                                : (_isPressed ? Colors.white.withValues(alpha: 0.03) : Colors.transparent),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: widget.isActive
                                  ? activeColor.withValues(alpha: 0.3)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Transform.scale(
                                scale: _isPressed ? 0.9 : 1.0,
                                child: Icon(
                                  widget.icon,
                                  size: 22,
                                  color: widget.isActive ? Colors.white : Colors.grey[500],
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  widget.label,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w500,
                                    color: widget.isActive ? Colors.white : Colors.grey[500],
                                  ),
                                ),
                              ),
                              if (widget.badgeCount > 0)
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.8, end: 1.0),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.elasticOut,
                                  builder: (context, value, child) {
                                    return Transform.scale(
                                      scale: value,
                                      child: child,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: activeColor,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: activeColor.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          spreadRadius: 0,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      widget.badgeCount.toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (_rippleController.isAnimating || _rippleController.value > 0)
                          Positioned.fill(
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _RipplePainter(
                                  progress: _rippleAnimation.value,
                                  color: activeColor.withValues(alpha: 0.15),
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
        ),
      ],
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double progress;
  final Color color;

  _RipplePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width * 0.1, size.height / 2);
    final maxRadius = size.width * 1.2;
    final currentRadius = maxRadius * progress;
    final opacity = (1 - progress).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color.withValues(alpha: opacity * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class UAxisDrawer extends StatelessWidget {
  const UAxisDrawer({super.key});

  String _getCurrentRoute(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/discover':
        return 'Discover';
      case '/social':
        return 'Social';
      case '/messages':
        return 'Messages';
      case '/business':
        return 'Businesses';
      case '/ai-hub':
        return 'AI Hub';
      case '/ai-tools':
        return 'AI Tools';
      case '/shop':
        return 'Shop';
      case '/profile':
        return 'Profile';
      case '/settings':
        return 'Settings';
      default:
        return 'Home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF0B0B0E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: UAxisSidebar(
        activeItem: _getCurrentRoute(context),
        onItemSelected: (item) {
          Navigator.pop(context);
        },
      ),
    );
  }
}
