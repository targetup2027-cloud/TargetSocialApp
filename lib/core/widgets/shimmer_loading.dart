import 'package:flutter/material.dart';

/// Provides a shared animation for all shimmer widgets within its scope.
/// Wrap shimmer lists with this to share a single AnimationController
/// instead of creating one per ShimmerLoading widget.
class ShimmerScope extends StatefulWidget {
  final Widget child;
  
  const ShimmerScope({super.key, required this.child});
  
  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();
  
  static Animation<double>? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ShimmerInheritedWidget>()?.animation;
  }
}

class _ShimmerScopeState extends State<ShimmerScope> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return _ShimmerInheritedWidget(
      animation: _animation,
      child: widget.child,
    );
  }
}

class _ShimmerInheritedWidget extends InheritedWidget {
  final Animation<double> animation;
  
  const _ShimmerInheritedWidget({
    required this.animation,
    required super.child,
  });
  
  @override
  bool updateShouldNotify(_ShimmerInheritedWidget oldWidget) => false;
}

class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final sharedAnimation = ShimmerScope.of(context);
    
    if (sharedAnimation != null) {
      // Use shared animation from ShimmerScope
      _animation = sharedAnimation;
      // Dispose local controller if we had one
      _controller?.dispose();
      _controller = null;
    } else if (_controller == null) {
      // Create local animation controller
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      )..repeat();
      _animation = Tween<double>(begin: -2, end: 2).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.easeInOutSine),
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animation = _animation;
    if (animation == null) return SizedBox(width: widget.width, height: widget.height);
    
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final highlightColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ShimmerPainter(
            animationValue: animation.value,
            baseColor: baseColor,
            highlightColor: highlightColor,
            borderRadius: widget.isCircle ? null : widget.borderRadius,
            isCircle: widget.isCircle,
          ),
          child: SizedBox(
            width: widget.width,
            height: widget.height,
          ),
        );
      },
    );
  }
}

class _ShimmerPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;
  final Color highlightColor;
  final double? borderRadius;
  final bool isCircle;

  _ShimmerPainter({
    required this.animationValue,
    required this.baseColor,
    required this.highlightColor,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment(animationValue - 1, 0),
      end: Alignment(animationValue + 1, 0),
      colors: [baseColor, highlightColor, baseColor],
    );
    
    final paint = Paint()..shader = gradient.createShader(rect);
    
    if (isCircle) {
      canvas.drawOval(rect, paint);
    } else if (borderRadius != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius!)),
        paint,
      );
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class PostCardShimmer extends StatelessWidget {
  const PostCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerLoading(width: 48, height: 48, isCircle: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      ShimmerLoading(width: 120, height: 14),
                      SizedBox(height: 8),
                      ShimmerLoading(width: 80, height: 12),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const ShimmerLoading(height: 14),
            const SizedBox(height: 8),
            const ShimmerLoading(height: 14),
            const SizedBox(height: 8),
            const ShimmerLoading(width: 200, height: 14),
            const SizedBox(height: 16),
            const ShimmerLoading(height: 180, borderRadius: 12),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                ShimmerLoading(width: 60, height: 24, borderRadius: 12),
                ShimmerLoading(width: 60, height: 24, borderRadius: 12),
                ShimmerLoading(width: 60, height: 24, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ConversationShimmer extends StatelessWidget {
  const ConversationShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const ShimmerLoading(width: 52, height: 52, isCircle: true),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      ShimmerLoading(width: 120, height: 14),
                      ShimmerLoading(width: 40, height: 12),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const ShimmerLoading(width: 200, height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserCardShimmer extends StatelessWidget {
  const UserCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerScope(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const ShimmerLoading(width: 48, height: 48, isCircle: true),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ShimmerLoading(width: 100, height: 14),
                  SizedBox(height: 6),
                  ShimmerLoading(width: 80, height: 12),
                ],
              ),
            ),
            const ShimmerLoading(width: 80, height: 32, borderRadius: 16),
          ],
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final Widget shimmerItem;
  
  const ShimmerList({
    super.key,
    this.itemCount = 5,
    required this.shimmerItem,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => shimmerItem,
    );
  }
}
