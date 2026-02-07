import 'package:flutter/material.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationTile extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: notification.isRead
              ? context.cardColor
              : const Color(0xFF6366F1).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? context.dividerColor
                : const Color(0xFF6366F1).withValues(alpha: 0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(context),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.actorDisplayName,
                            style: TextStyle(
                              color: context.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getRelativeTime(notification.createdAt),
                          style: TextStyle(
                            color: context.hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getActionText(),
                      style: TextStyle(
                        color: notification.isRead
                            ? context.onSurfaceVariant
                            : context.onSurface,
                        fontSize: 14,
                        fontWeight:
                            notification.isRead ? FontWeight.normal : FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildTypeIcon(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.cardColor,
            border: Border.all(color: context.dividerColor),
            image: notification.actorAvatarUrl != null
                ? DecorationImage(
                    image: NetworkImage(notification.actorAvatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: notification.actorAvatarUrl == null
              ? Icon(
                  Icons.person,
                  color: context.hintColor,
                  size: 24,
                )
              : null,
        ),
        if (!notification.isRead)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.scaffoldBg,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTypeIcon(BuildContext context) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (notification.type) {
      case NotificationType.followed:
        icon = Icons.person_add_outlined;
        color = const Color(0xFFEC4899);
        bgColor = color.withValues(alpha: 0.1);
        break;
      case NotificationType.unfollowed:
        icon = Icons.person_remove_outlined;
        color = const Color(0xFF6B7280);
        bgColor = color.withValues(alpha: 0.1);
        break;
      case NotificationType.messageReceived:
        icon = Icons.chat_bubble_outline;
        color = const Color(0xFF10B981);
        bgColor = color.withValues(alpha: 0.1);
        break;
      case NotificationType.postLiked:
        icon = Icons.favorite_outline;
        color = const Color(0xFFF43F5E);
        bgColor = color.withValues(alpha: 0.1);
        break;
      case NotificationType.commentAdded:
        icon = Icons.mode_comment_outlined;
        color = const Color(0xFF3B82F6);
        bgColor = color.withValues(alpha: 0.1);
        break;
      case NotificationType.mentionedInPost:
      case NotificationType.mentionedInComment:
        icon = Icons.alternate_email;
        color = const Color(0xFF8B5CF6);
        bgColor = color.withValues(alpha: 0.1);
        break;
    }

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  String _getActionText() {
    switch (notification.type) {
      case NotificationType.followed:
        return 'started following you';
      case NotificationType.unfollowed:
        return 'unfollowed you';
      case NotificationType.messageReceived:
        return 'sent you a message';
      case NotificationType.postLiked:
        return 'liked your post';
      case NotificationType.commentAdded:
        return 'commented on your post';
      case NotificationType.mentionedInPost:
        return 'mentioned you in a post';
      case NotificationType.mentionedInComment:
        return 'mentioned you in a comment';
    }
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
