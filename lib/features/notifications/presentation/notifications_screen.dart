import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../core/motion/motion_system.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../application/notifications_controller.dart';
import '../domain/entities/notification_entity.dart';
import '../../social/application/current_user_provider.dart';
import 'widgets/notification_tile.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final notificationsAsync =
        ref.watch(notificationsControllerProvider(userId));
    final controller =
        ref.read(notificationsControllerProvider(userId).notifier);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, controller, notificationsAsync),
            Expanded(
              child: notificationsAsync.when(
                data: (notifications) =>
                    _buildNotificationsList(context, notifications, controller),
                loading: () => _buildLoadingState(context),
                error: (error, stack) =>
                    _buildErrorState(context, error, controller),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    NotificationsController controller,
    AsyncValue<List<NotificationEntity>> notificationsAsync,
  ) {
    final hasUnread = notificationsAsync.valueOrNull?.any((n) => !n.isRead) ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.dividerColor),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: context.iconColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                color: context.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
          ),
          if (hasUnread)
            GestureDetector(
              onTap: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                await controller.markAllAsRead();
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: const Text('All notifications marked as read'),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Mark all read',
                  style: TextStyle(
                    color: const Color(0xFF6366F1),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF6366F1)),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: TextStyle(color: context.hintColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    Object error,
    NotificationsController controller,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: context.hintColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load notifications',
            style: TextStyle(color: context.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => controller.refresh(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF6366F1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    List<NotificationEntity> notifications,
    NotificationsController controller,
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyState(context);
    }

    final groupedNotifications = _groupNotifications(notifications);
    final sections = <Widget>[];

    for (final entry in groupedNotifications.entries) {
      final timeHeader = entry.key;
      final groupedByCategory = _groupByCategory(entry.value);

      sections.add(_buildTimeHeader(context, timeHeader));

      for (final catEntry in groupedByCategory.entries) {
        if (catEntry.value.isNotEmpty) {
          sections.add(_buildCategoryHeader(context, catEntry.key));
          for (final notification in catEntry.value) {
            sections.add(
              AnimatedListItem(
                index: sections.length,
                child: NotificationTile(
                  notification: notification,
                  onTap: () => _handleNotificationTap(notification, controller),
                ),
              ),
            );
          }
        }
      }
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      color: const Color(0xFF6366F1),
      backgroundColor: context.cardColor,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: sections,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: context.hintColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: TextStyle(
              color: context.onSurfaceVariant,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you get notifications, they\'ll show up here',
            style: TextStyle(color: context.hintColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => context.push('/discover'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Find People',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeHeader(BuildContext context, String header) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        header,
        style: TextStyle(
          color: context.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(BuildContext context, String category) {
    IconData icon;
    Color color;

    switch (category) {
      case 'Social':
        icon = Icons.people_outline;
        color = const Color(0xFFEC4899);
        break;
      case 'Messages':
        icon = Icons.chat_bubble_outline;
        color = const Color(0xFF10B981);
        break;
      case 'Engagement':
        icon = Icons.favorite_outline;
        color = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.notifications_outlined;
        color = const Color(0xFF6366F1);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            category,
            style: TextStyle(
              color: context.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<NotificationEntity>> _groupNotifications(
      List<NotificationEntity> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));

    final grouped = <String, List<NotificationEntity>>{
      'Today': [],
      'Yesterday': [],
      'This Week': [],
      'Earlier': [],
    };

    for (final notification in notifications) {
      final notifDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (notifDate.isAtSameMomentAs(today) || notifDate.isAfter(today)) {
        grouped['Today']!.add(notification);
      } else if (notifDate.isAtSameMomentAs(yesterday)) {
        grouped['Yesterday']!.add(notification);
      } else if (notifDate.isAfter(thisWeekStart)) {
        grouped['This Week']!.add(notification);
      } else {
        grouped['Earlier']!.add(notification);
      }
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  Map<String, List<NotificationEntity>> _groupByCategory(
      List<NotificationEntity> notifications) {
    final grouped = <String, List<NotificationEntity>>{
      'Social': [],
      'Messages': [],
      'Engagement': [],
    };

    for (final notification in notifications) {
      final category = notification.categoryGroup;
      grouped[category]?.add(notification);
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  void _handleNotificationTap(
    NotificationEntity notification,
    NotificationsController controller,
  ) {
    controller.markAsRead(notification.id);

    final deepLink = notification.deepLink;

    if (deepLink.pathParameters.isNotEmpty) {
      final path = '/${deepLink.routeName.replaceAll('-', '/')}';
      final params = deepLink.pathParameters;

      if (deepLink.routeName == 'visitor-profile') {
        context.push('/user/${params['userId']}');
      } else {
        context.push(path, extra: deepLink.extra);
      }
    } else {
      context.push('/${deepLink.routeName}', extra: deepLink.extra);
    }
  }
}
