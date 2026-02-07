import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme_extensions.dart';
import 'universe_button_icon.dart';

class UniverseBackButton extends StatefulWidget {
  const UniverseBackButton({super.key});

  @override
  State<UniverseBackButton> createState() => _UniverseBackButtonState();
}

class _UniverseBackButtonState extends State<UniverseBackButton> {
  double _bottom = 70;
  double _right = 20;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      bottom: _bottom,
      right: _right,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _right -= details.delta.dx;
            _bottom -= details.delta.dy;
            _right = _right.clamp(0.0, screenWidth - size);
            _bottom = _bottom.clamp(0.0, screenHeight - size - MediaQuery.of(context).padding.top);
          });
        },
        onTap: () => context.go('/app'),
        child: SizedBox(
          width: size,
          height: size,
          child: const UniverseButtonIcon(size: size),
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
    final isDark = context.isDarkMode;
    
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
                color: isDark 
                    ? const Color(0xFF1A1A1F).withValues(alpha: 0.9)
                    : const Color(0xFFFAFAFA).withValues(alpha: 0.95),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                border: Border.all(
                  color: context.dividerColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.chevron_right,
                  color: context.hintColor,
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
