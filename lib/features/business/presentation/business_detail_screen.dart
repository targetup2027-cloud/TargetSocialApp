import 'package:flutter/material.dart';
import '../../../core/widgets/universe_back_button.dart';

class BusinessDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String name;
  final bool isPremium;
  final int trustScore;
  final String revenue;

  const BusinessDetailScreen({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.isPremium,
    required this.trustScore,
    required this.revenue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Business OS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your businesses',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _BackButton(onTap: () => Navigator.of(context).pop()),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                            blurRadius: 24,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$trustScore% Trust Score',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '  •  ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          isPremium ? 'Premium Plan' : 'Free Plan',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Promotion Banner',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _MediaGrid(isPremium: isPremium),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Performance',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _PerformanceCard(
                            label: 'Revenue',
                            value: revenue,
                            subtitle: '+18% vs last month',
                            icon: Icons.trending_up_rounded,
                            iconColor: const Color(0xFF10B981),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PerformanceCard(
                            label: 'Trust Score',
                            value: '$trustScore%',
                            subtitle: 'Verified Business',
                            icon: Icons.verified_rounded,
                            iconColor: const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          const UniverseBackButton(),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaGrid extends StatelessWidget {
  final bool isPremium;

  const _MediaGrid({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    const double gap = 10;
    const double largeHeight = 96; // أكبر وواضح زي الصورة
    const double smallSize = 54; // مربعات الصور أكبر

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row (2 large slots)
        Row(
          children: const [
            Expanded(
              child: _MediaSlot(
                label: 'Vertical Video',
                sublabel: '1 min max',
                isLarge: true,
                height: largeHeight,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _MediaSlot(
                label: 'Horizontal Video',
                sublabel: '1 min max',
                isLarge: true,
                height: largeHeight,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Bottom row (5 small slots)
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: const [
            _MediaSlot(isLarge: false, width: smallSize, height: smallSize),
            _MediaSlot(isLarge: false, width: smallSize, height: smallSize),
            _MediaSlot(isLarge: false, width: smallSize, height: smallSize),
            _MediaSlot(isLarge: false, width: smallSize, height: smallSize),
            _MediaSlot(isLarge: false, width: smallSize, height: smallSize),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Text(
              isPremium ? 'Premium Plan: Unlimited' : 'Free Plan: 2 videos + 5 images',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4),
                fontSize: 12,
              ),
            ),
            if (!isPremium) ...[
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Upgrade for more',
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _MediaSlot extends StatelessWidget {
  final String? label;
  final String? sublabel;
  final bool isLarge;
  final double? width;
  final double height;

  const _MediaSlot({
    this.label,
    this.sublabel,
    required this.isLarge,
    this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double w = width ?? double.infinity;
    final double radius = isLarge ? 14 : 12;

    return SizedBox(
      width: w == double.infinity ? null : w,
      height: height,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: Colors.white.withValues(alpha: 0.18),
          strokeWidth: 1.2,
          dashWidth: isLarge ? 6 : 5,
          dashSpace: isLarge ? 4 : 4,
          radius: radius,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D10),
            borderRadius: BorderRadius.circular(radius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isLarge ? 12 : 0,
            vertical: isLarge ? 10 : 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: isLarge ? 34 : 26,
                height: isLarge ? 34 : 26,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(isLarge ? 10 : 8),
                ),
                child: Icon(
                  isLarge ? Icons.videocam_outlined : Icons.image_outlined,
                  size: isLarge ? 25 : 20,
                  color: Colors.white.withValues(alpha: 0.38),
                ),
              ),
              if (label != null) ...[
                const SizedBox(height: 8),
                Text(
                  label!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (sublabel != null) ...[
                const SizedBox(height: 4),
                Text(
                  sublabel!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.28),
                    fontSize: 11,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double radius;

  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    final dashPath = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PerformanceCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const _PerformanceCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 14,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
