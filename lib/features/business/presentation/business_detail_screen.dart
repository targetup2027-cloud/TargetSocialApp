import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../domain/entities/business.dart';
import '../application/business_controller.dart';
import 'dart:io';

class BusinessDetailScreen extends ConsumerWidget {
  final Business business;

  const BusinessDetailScreen({
    super.key,
    required this.business,
  });

  // Getters removed to use watched business instance in build
  // String get imageUrl => business.logoUrl ?? 'https://via.placeholder.com/150';
  // String get name => business.name;
  // bool get isPremium => business.isVerified;
  // int get trustScore => business.profileCompletionPercentage;
  // String get revenue => '\$${(business.followersCount * 12.5).toStringAsFixed(0)}/mo';

  Future<void> _deleteBusiness(BuildContext context, WidgetRef ref, String businessId, String businessName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Business',
          style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to delete "$businessName"? This action cannot be undone.',
          style: TextStyle(color: context.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: context.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(userBusinessesProvider.notifier).deleteBusiness(businessId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Business deleted successfully'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/business');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesState = ref.watch(userBusinessesProvider);
    final currentBusiness = businessesState.maybeWhen(
      data: (businesses) => businesses.firstWhere(
        (b) => b.id == business.id,
        orElse: () => business,
      ),
      orElse: () => business,
    );
    
    final imageUrl = currentBusiness.logoUrl ?? 'https://via.placeholder.com/150';
    final name = currentBusiness.name;
    final isPremium = currentBusiness.isVerified;
    final trustScore = currentBusiness.profileCompletionPercentage;
    final revenue = '\$${(currentBusiness.followersCount * 12.5).toStringAsFixed(0)}/mo';

    return Scaffold(
      backgroundColor: context.scaffoldBg,
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
                        Text(
                          'Business OS',
                          style: TextStyle(
                            color: context.onSurface,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your businesses',
                          style: TextStyle(
                            color: context.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _BackButton(onTap: () => Navigator.of(context).pop()),
                        Row(
                          children: [
                            _EditButton(onTap: () => context.push('/edit-business', extra: currentBusiness)),
                            const SizedBox(width: 8),
                            _DeleteButton(onTap: () => _deleteBusiness(context, ref, currentBusiness.id, name)),
                          ],
                        ),
                      ],
                    ),
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
                      style: TextStyle(
                        color: context.onSurface,
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
                            color: context.onSurfaceVariant,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          isPremium ? 'Premium Plan' : 'Free Plan',
                          style: TextStyle(
                            color: context.onSurfaceVariant,
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
                        color: context.onSurface.withValues(alpha: 0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _MediaGrid(business: currentBusiness),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Performance',
                      style: TextStyle(
                        color: context.onSurface.withValues(alpha: 0.9),
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
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: context.dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: context.onSurface.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 6),
            Text(
              'Back',
              style: TextStyle(
                color: context.onSurface.withValues(alpha: 0.8),
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

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.edit_rounded,
              size: 14,
              color: Color(0xFF8B5CF6),
            ),
            const SizedBox(width: 6),
            const Text(
              'Edit',
              style: TextStyle(
                color: Color(0xFF8B5CF6),
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

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.delete_outline_rounded,
              size: 14,
              color: Colors.red,
            ),
            SizedBox(width: 6),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.red,
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
  final Business business;

  const _MediaGrid({required this.business});

  @override
  Widget build(BuildContext context) {
    final isPremium = business.isVerified; // Or use strict plan check if available
    const double gap = 10;
    const double largeHeight = 96;
    const double smallSize = 54;

    // Gallery images filling logic
    final images = business.galleryImageUrls; // List<String>
    // We want to show exactly 5 slots for consistency with the design "5 images"
    // Populated slots first, then empty placeholders.
    final List<Widget> imageSlots = [];
    
    // We generate exactly 5 slots to match the "Free Plan: ... + 5 images" design
    // For premium/unlimited, this UI might need to scroll or show "more", 
    // but preserving the original requested 5-slot look for now.
    for (int i = 0; i < 5; i++) {
      if (i < images.length) {
        imageSlots.add(_MediaSlot(
          isLarge: false, 
          width: smallSize, 
          height: smallSize, 
          imageUrl: images[i],
          isVideo: false,
        ));
      } else {
        imageSlots.add(const _MediaSlot(isLarge: false, width: smallSize, height: smallSize));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row (2 large slots: Vertical & Horizontal Video)
        Row(
          children: [
            Expanded(
              child: _MediaSlot(
                label: business.videoUrl != null ? null : 'Vertical Video',
                sublabel: business.videoUrl != null ? null : '1 min max',
                isLarge: true,
                height: largeHeight,
                // Assuming videoUrl is a video file path/URL. 
                // For a thumbnail, we'd validly need a thumbnail URL or generate it.
                // If we don't have a thumbnail URL, we might just show a "Video" placeholder styled as filled.
                // However, without a thumbnail generator here, let's assume we stick to valid image availability or 
                // generic "Filled" state if we can't render the video frame.
                // Ideally, we'd have a thumbnail. For now, let's use a flag isFilled to show a generic video placeholder if no image.
                imageUrl: null, // We generally can't just put video URL in NetworkImage
                // But we can mark it as having content
                hasContent: business.videoUrl != null,
                contentType: 'Vertical Video',
                isVideo: true,
              ),
            ),
            const SizedBox(width: gap),
            Expanded(
              child: _MediaSlot(
                label: business.horizontalVideoUrl != null ? null : 'Horizontal Video',
                sublabel: business.horizontalVideoUrl != null ? null : '1 min max',
                isLarge: true,
                height: largeHeight,
                hasContent: business.horizontalVideoUrl != null,
                contentType: 'Horizontal Video',
                isVideo: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Bottom row (5 small slots)
        Wrap(
          spacing: gap,
          runSpacing: gap,
          children: imageSlots,
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Text(
              isPremium ? 'Premium Plan: Unlimited' : 'Free Plan: 2 videos + 5 images',
              style: TextStyle(
                color: context.hintColor,
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
  final String? imageUrl;
  final bool hasContent;
  final String? contentType;
  final bool isVideo;

  const _MediaSlot({
    this.label,
    this.sublabel,
    required this.isLarge,
    this.width,
    required this.height,
    this.imageUrl,
    this.hasContent = false,
    this.contentType,
    this.isVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    final double w = width ?? double.infinity;
    final double radius = isLarge ? 14 : 12;
    
    // Determine if we are showing content (image or filled video placeholder)
    final bool showContent = imageUrl != null || hasContent;

    ImageProvider? imageProvider;
    if (imageUrl != null) {
      if (imageUrl!.startsWith('http')) {
        imageProvider = NetworkImage(imageUrl!);
      } else {
        imageProvider = FileImage(File(imageUrl!));
      }
    }

    return SizedBox(
      width: w == double.infinity ? null : w,
      height: height,
      child: showContent 
        ? Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(radius),
              image: imageProvider != null 
                ? DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                    onError: (exception, stackTrace) {
                      // Fallback or log error
                    },
                  )
                : null,
                // For video without thumbnail, we use a gradient or solid color
              gradient: imageProvider == null && hasContent
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.primaryColor.withValues(alpha: 0.1),
                       context.primaryColor.withValues(alpha: 0.2),
                    ],
                  )
                : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isVideo)
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                  ),
                if (imageUrl == null && hasContent && contentType != null)
                   Positioned(
                     bottom: 8,
                     child: Text(
                       contentType!,
                       style: TextStyle(
                         color: context.primaryColor,
                         fontSize: 10,
                         fontWeight: FontWeight.w600
                       ),
                     ),
                   )
              ],
            ),
          )
        : CustomPaint(
            painter: _DashedBorderPainter(
              color: context.dividerColor,
              strokeWidth: 1.2,
              dashWidth: isLarge ? 6 : 5,
              dashSpace: isLarge ? 4 : 4,
              radius: radius,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: context.cardColor,
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
                      color: context.iconColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(isLarge ? 10 : 8),
                    ),
                    child: Icon(
                      isLarge ? Icons.videocam_outlined : Icons.image_outlined,
                      size: isLarge ? 25 : 20,
                      color: context.iconColor.withValues(alpha: 0.38),
                    ),
                  ),
                  if (label != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      label!,
                      style: TextStyle(
                        color: context.onSurface.withValues(alpha: 0.55),
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
                        color: context.onSurfaceVariant.withValues(alpha: 0.5),
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.dividerColor,
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
                  color: context.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: context.onSurface,
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: context.onSurface.withValues(alpha: 0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
