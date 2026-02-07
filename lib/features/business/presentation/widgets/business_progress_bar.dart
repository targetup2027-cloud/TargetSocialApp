import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../application/business_progress_provider.dart';

class BusinessProgressBar extends ConsumerWidget {
  final bool showLabel;
  final double height;

  const BusinessProgressBar({
    super.key,
    this.showLabel = true,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressState = ref.watch(businessProgressProvider);
    final percentage = progressState.percentage;
    final progress = percentage / 100;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutQuart,
      tween: Tween<double>(begin: 0, end: progress),
      builder: (context, value, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(value * 100).toInt()}% Completed',
                    style: TextStyle(
                      color: context.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: context.dividerColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(value),
                ),
                minHeight: height,
              ),
            ),
          ],
        );
      },
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.33) {
      return Color.lerp(
        const Color(0xFFEF4444),
        const Color(0xFFF59E0B),
        progress / 0.33,
      )!;
    } else if (progress < 0.66) {
      return Color.lerp(
        const Color(0xFFF59E0B),
        const Color(0xFF10B981),
        (progress - 0.33) / 0.33,
      )!;
    } else {
      return const Color(0xFF10B981);
    }
  }
}
