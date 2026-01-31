import 'package:flutter/material.dart';

import '../../core/motion/motion_system.dart';

class UAxisButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isLoading;
  final IconData? icon;

  const UAxisButton({
    super.key,
    required this.label,
    this.onTap,
    this.isPrimary = true,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TapScaleButton(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFAB5CF6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          color: isPrimary ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isPrimary
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isPrimary ? Colors.white : const Color(0xFF8B5CF6),
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class UAxisCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;

  const UAxisCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return HoverScaleCard(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFF1C1C2E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: child,
      ),
    );
  }
}

class UAxisSkeletonCard extends StatelessWidget {
  final double? width;
  final double height;

  const UAxisSkeletonCard({
    super.key,
    this.width,
    this.height = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ShimmerLoading(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: height * 0.6,
              decoration: const BoxDecoration(
                color: Color(0xFF252525),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12,
                    width: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252525),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UAxisToastOverlay extends StatefulWidget {
  final Widget child;

  const UAxisToastOverlay({super.key, required this.child});

  static UAxisToastOverlayState of(BuildContext context) {
    return context.findAncestorStateOfType<UAxisToastOverlayState>()!;
  }

  @override
  State<UAxisToastOverlay> createState() => UAxisToastOverlayState();
}

class UAxisToastOverlayState extends State<UAxisToastOverlay> {
  OverlayEntry? _currentToast;

  void showSuccess(String message) {
    _showToast(message, FeedbackType.success);
  }

  void showError(String message) {
    _showToast(message, FeedbackType.error);
  }

  void _showToast(String message, FeedbackType type) {
    _currentToast?.remove();

    _currentToast = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: FeedbackToast(
              message: message,
              type: type,
              onDismiss: () {
                _currentToast?.remove();
                _currentToast = null;
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentToast!);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
