import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'universe_button_icon.dart';

class UniverseBackButton extends StatefulWidget {
  const UniverseBackButton({super.key});

  @override
  State<UniverseBackButton> createState() => _UniverseBackButtonState();
}

class _UniverseBackButtonState extends State<UniverseBackButton>
    with TickerProviderStateMixin {
  double _bottom = 70;
  double _right = 20;

  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
    _pulseController.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) context.go('/app');
    });
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: _bottom,
      right: _right,
      child: SizedBox(
        width: size + 40,
        height: size + 40,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: size * _pulseAnimation.value,
                  height: size * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(
                        alpha: (1.0 - (_pulseAnimation.value - 1.0) / 0.5).clamp(0.0, 0.5),
                      ),
                      width: 2,
                    ),
                  ),
                );
              },
            ),
            GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _right -= details.delta.dx;
                  _bottom -= details.delta.dy;
                  _right = _right.clamp(0.0, screenWidth - size);
                  _bottom = _bottom.clamp(0.0, screenHeight - size - MediaQuery.of(context).padding.top);
                });
              },
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: const UniverseButtonIcon(size: size),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



class SideMenuToggle extends StatefulWidget {
  final VoidCallback onTap;

  const SideMenuToggle({
    super.key,
    required this.onTap,
  });

  @override
  State<SideMenuToggle> createState() => _SideMenuToggleState();
}

class _SideMenuToggleState extends State<SideMenuToggle> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: widget.onTap,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            widget.onTap();
          }
        },
        child: Container(
          width: 28,
          color: Colors.transparent,
          child: Center(
            child: Container(
              width: 24,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1F).withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
