import 'package:flutter/widgets.dart';

const double kTabletBreakpoint = 840.0;
const double kMaxContentWidth = 780.0;
const double kTabletBubbleMaxWidthFactor = 0.60;

bool isTablet(BuildContext context) {
  return MediaQuery.sizeOf(context).width >= kTabletBreakpoint;
}

double getContentHorizontalPadding(BuildContext context) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  if (screenWidth < kTabletBreakpoint) return 0.0;
  final excess = screenWidth - kMaxContentWidth;
  return (excess / 2).clamp(16.0, 64.0);
}

class CenteredContentColumn extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const CenteredContentColumn({
    super.key,
    required this.child,
    this.maxWidth = kMaxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (!isTablet(context)) return child;
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
