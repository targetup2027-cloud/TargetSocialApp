import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../app/theme/theme_extensions.dart';

class TappableUserAvatar extends StatelessWidget {
  final String userId;
  final String? avatarUrl;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool isVerified;
  final int? trustScore;
  final bool enableNavigation;

  const TappableUserAvatar({
    super.key,
    required this.userId,
    this.avatarUrl,
    this.size = 40,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2,
    this.isVerified = false,
    this.trustScore,
    this.enableNavigation = true,
  });

  Color _getTrustColor() {
    final score = trustScore ?? 0;
    if (score >= 90) return const Color(0xFFF59E0B);
    if (score >= 70) return const Color(0xFF10B981);
    if (score >= 40) return const Color(0xFF3B82F6);
    return const Color(0xFF6B7280);
  }

  void _navigateToProfile(BuildContext context) {
    if (!enableNavigation) return;
    context.push('/user/$userId');
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? _getTrustColor();
    
    return GestureDetector(
      onTap: () => _navigateToProfile(context),
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder
                  ? Border.all(color: effectiveBorderColor, width: borderWidth)
                  : null,
            ),
            padding: showBorder ? EdgeInsets.all(borderWidth) : EdgeInsets.zero,
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: avatarUrl!.startsWith('http')
                          ? avatarUrl!
                          : 'https://i.pravatar.cc/150?u=$userId',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildPlaceholder(context),
                      errorWidget: (context, url, error) => _buildPlaceholder(context),
                    )
                  : _buildPlaceholder(context),
            ),
          ),
          if (isVerified || (trustScore != null && trustScore! >= 70))
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.35,
                height: size * 0.35,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getTrustColor(),
                  border: Border.all(color: context.cardColor, width: 2),
                ),
                child: Icon(
                  (trustScore ?? 0) >= 90 ? Icons.star : Icons.check,
                  size: size * 0.2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: context.isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFEEEEEE),
      child: Icon(
        Icons.person,
        color: context.iconColor,
        size: size * 0.5,
      ),
    );
  }
}

class TappableUserName extends StatelessWidget {
  final String userId;
  final String displayName;
  final String? username;
  final bool isVerified;
  final int? trustScore;
  final double fontSize;
  final bool enableNavigation;

  const TappableUserName({
    super.key,
    required this.userId,
    required this.displayName,
    this.username,
    this.isVerified = false,
    this.trustScore,
    this.fontSize = 15,
    this.enableNavigation = true,
  });

  Color _getTrustColor() {
    final score = trustScore ?? 0;
    if (score >= 90) return const Color(0xFFF59E0B);
    if (score >= 70) return const Color(0xFF10B981);
    if (score >= 40) return const Color(0xFF3B82F6);
    return const Color(0xFF6B7280);
  }

  void _navigateToProfile(BuildContext context) {
    if (!enableNavigation) return;
    context.push('/user/$userId');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context),
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              displayName,
              style: TextStyle(
                color: context.onSurface,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isVerified || (trustScore != null && trustScore! >= 70)) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.verified,
              size: fontSize - 1,
              color: _getTrustColor(),
            ),
          ],
        ],
      ),
    );
  }
}

class TappableUserRow extends StatelessWidget {
  final String userId;
  final String displayName;
  final String? username;
  final String? avatarUrl;
  final bool isVerified;
  final int? trustScore;
  final double avatarSize;
  final String? subtitle;
  final Widget? trailing;
  final bool enableNavigation;

  const TappableUserRow({
    super.key,
    required this.userId,
    required this.displayName,
    this.username,
    this.avatarUrl,
    this.isVerified = false,
    this.trustScore,
    this.avatarSize = 40,
    this.subtitle,
    this.trailing,
    this.enableNavigation = true,
  });

  void _navigateToProfile(BuildContext context) {
    if (!enableNavigation) return;
    context.push('/user/$userId');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          TappableUserAvatar(
            userId: userId,
            avatarUrl: avatarUrl,
            size: avatarSize,
            isVerified: isVerified,
            trustScore: trustScore,
            enableNavigation: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TappableUserName(
                  userId: userId,
                  displayName: displayName,
                  username: username,
                  isVerified: isVerified,
                  trustScore: trustScore,
                  enableNavigation: false,
                ),
                if (subtitle != null || username != null)
                  Text(
                    subtitle ?? '@$username',
                    style: TextStyle(
                      color: context.hintColor,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
