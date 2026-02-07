import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../../core/motion/motion_system.dart';
import '../domain/entities/message.dart';
import '../application/messages_controller.dart';
import 'chat_detail_screen.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({super.key});

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value.trim();
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  void _showNewConversationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.hintColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'New Conversation',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: context.isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: TextField(
                    style: TextStyle(color: context.onSurface, fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Search contacts...',
                      hintStyle: TextStyle(
                        color: context.isDarkMode ? const Color(0xFF888888) : const Color(0xFF9CA3AF),
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: context.isDarkMode ? const Color(0xFF888888) : const Color(0xFF9CA3AF),
                        size: 22,
                      ),
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=$index'),
                    ),
                    title: Text(
                      'Contact ${index + 1}',
                      style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '@user_${index + 1}',
                      style: TextStyle(color: context.onSurfaceVariant),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MotionPageRoute(
                          page: ChatDetailScreen(
                            userName: 'Contact ${index + 1}',
                            userAvatar: 'https://i.pravatar.cc/150?u=$index',
                            conversationId: 'new_$index',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConversationMenu(BuildContext context, Conversation conversation) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.hintColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                conversation.unreadCount > 0 ? Icons.mark_email_read : Icons.mark_email_unread,
                color: context.iconColor,
              ),
              title: Text(
                conversation.unreadCount > 0 ? 'Mark as read' : 'Mark as unread',
                style: TextStyle(color: context.onSurface),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                if (conversation.unreadCount > 0) {
                  ref.read(conversationsControllerProvider.notifier).markAsRead(conversation.id);
                } else {
                  ref.read(conversationsControllerProvider.notifier).markAsUnread(conversation.id);
                }
              },
            ),
            ListTile(
              leading: Icon(
                conversation.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                color: context.iconColor,
              ),
              title: Text(
                conversation.isPinned ? 'Unpin' : 'Pin conversation',
                style: TextStyle(color: context.onSurface),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                ref.read(conversationsControllerProvider.notifier).togglePin(conversation.id);
              },
            ),
            ListTile(
              leading: Icon(
                conversation.isMuted ? Icons.notifications_active : Icons.notifications_off,
                color: context.iconColor,
              ),
              title: Text(
                conversation.isMuted ? 'Unmute' : 'Mute notifications',
                style: TextStyle(color: context.onSurface),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                ref.read(conversationsControllerProvider.notifier).toggleMute(conversation.id);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red.withValues(alpha: 0.8)),
              title: Text(
                'Delete conversation',
                style: TextStyle(color: Colors.red.withValues(alpha: 0.8)),
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                showDialog(
                  context: context,
                  builder: (dialogContext) => AlertDialog(
                    backgroundColor: context.cardColor,
                    title: Text('Delete conversation?', style: TextStyle(color: context.onSurface)),
                    content: Text(
                      'This will delete the conversation from your inbox.',
                      style: TextStyle(color: context.onSurfaceVariant),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text('Cancel', style: TextStyle(color: context.hintColor)),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          ref.read(conversationsControllerProvider.notifier).deleteConversation(conversation.id);
                        },
                        child: Text('Delete', style: TextStyle(color: Colors.red.withValues(alpha: 0.8))),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = _searchQuery.isEmpty
        ? ref.watch(conversationsControllerProvider)
        : ref.watch(searchConversationsProvider(_searchQuery));

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      drawer: const UAxisDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Text(
                    'Messages',
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: context.isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: context.onSurface, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Search messages...',
                          hintStyle: TextStyle(
                            color: context.isDarkMode ? const Color(0xFF888888) : const Color(0xFF9CA3AF),
                            fontSize: 16,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: context.isDarkMode ? const Color(0xFF888888) : const Color(0xFF9CA3AF),
                            size: 22,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: context.isDarkMode ? const Color(0xFF888888) : const Color(0xFF9CA3AF),
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: conversationsAsync.when(
                    data: (conversations) {
                      if (conversations.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: context.hintColor.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  color: context.onSurfaceVariant,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Start a conversation!',
                                style: TextStyle(
                                  color: context.hintColor,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => _showNewConversationSheet(context),
                                icon: const Icon(Icons.add, size: 20),
                                label: const Text('Start a new message'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      final pinnedConversations = conversations.where((c) => c.isPinned).toList();
                      
                      return RefreshIndicator(
                        onRefresh: () async {
                          await ref.read(conversationsControllerProvider.notifier).refresh();
                        },
                        color: const Color(0xFF8B5CF6),
                        backgroundColor: context.cardColor,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: conversations.length + (pinnedConversations.isNotEmpty ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (pinnedConversations.isNotEmpty && index == 0) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                                child: Text(
                                  'PINNED',
                                  style: TextStyle(
                                    color: context.hintColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              );
                            }
                            
                            final adjustedIndex = pinnedConversations.isNotEmpty ? index - 1 : index;
                            final conversation = conversations[adjustedIndex];
                            
                            return _ConversationItem(
                              conversation: conversation,
                              timeAgo: conversation.lastMessage != null
                                  ? _getTimeAgo(conversation.lastMessage!.createdAt)
                                  : '',
                              onTap: () {
                                final otherParticipant = conversation.participants.isNotEmpty
                                    ? conversation.participants.first
                                    : null;
                                Navigator.push(
                                  context,
                                  MotionPageRoute(
                                    page: ChatDetailScreen(
                                      userName: conversation.isGroup
                                          ? (conversation.groupName ?? 'Group')
                                          : (otherParticipant?.displayName ?? 'User'),
                                      userAvatar: conversation.isGroup
                                          ? (conversation.groupImageUrl ?? 'https://i.pravatar.cc/150?u=group')
                                          : (otherParticipant?.avatarUrl ?? 'https://i.pravatar.cc/150?u=default'),
                                      conversationId: conversation.id,
                                      peerUserId: conversation.isGroup ? null : otherParticipant?.id,
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () => _showConversationMenu(context, conversation),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 8,
                      itemBuilder: (context, index) => const ConversationShimmer(),
                    ),
                    error: (error, stack) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading messages',
                              style: TextStyle(
                                color: context.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Something went wrong',
                              style: TextStyle(
                                color: context.hintColor,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => ref.read(conversationsControllerProvider.notifier).refresh(),
                              icon: const Icon(Icons.refresh, size: 20),
                              label: const Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8B5CF6),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) => SideMenuToggle(
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: () => _showNewConversationSheet(context),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF34D399)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationItem extends ConsumerWidget {
  final Conversation conversation;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _ConversationItem({
    required this.conversation,
    required this.timeAgo,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherParticipant = conversation.participants.isNotEmpty
        ? conversation.participants.first
        : null;
    final name = conversation.isGroup
        ? (conversation.groupName ?? 'Group')
        : (otherParticipant?.displayName ?? 'User');
    final avatar = conversation.isGroup
        ? (conversation.groupImageUrl ?? 'https://i.pravatar.cc/150?u=group')
        : (otherParticipant?.avatarUrl ?? 'https://i.pravatar.cc/150?u=default');
    final isOnline = !conversation.isGroup && (otherParticipant?.isOnline ?? false);
    
    final lastMessage = conversation.lastMessage;
    final isOwnMessage = lastMessage?.senderId == 'currentUser';
    
    String getMessagePreview(Message? msg) {
      if (msg == null) return 'No messages yet';
      final content = msg.content ?? '';
      if (content.startsWith('[Image_Path:')) return '📷 Photo';
      if (content.startsWith('[Video_Path:')) return '🎥 Video';
      if (content.startsWith('[File_Path:')) return '📎 File';
      if (content.startsWith('[Voice:') || content.startsWith('[Audio_Path:')) return '🎵 Voice message';
      return content;
    }
    
    final preview = getMessagePreview(lastMessage);
    final messagePreview = lastMessage != null
        ? (isOwnMessage ? 'You: $preview' : preview)
        : 'No messages yet';
    
    final unreadCount = conversation.unreadCount;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.cardColor,
                    image: DecorationImage(
                      image: NetworkImage(avatar),
                      fit: BoxFit.cover,
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                      width: 1,
                    ),
                  ),
                ),
                if (isOnline)
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        shape: BoxShape.circle,
                        border: Border.all(color: context.scaffoldBg, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.4),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (conversation.isPinned)
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: context.scaffoldBg, width: 2),
                      ),
                      child: const Icon(Icons.push_pin, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: context.onSurface,
                                  fontSize: 16,
                                  fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (conversation.isMuted) ...[
                              const SizedBox(width: 4),
                              Icon(
                                Icons.notifications_off_outlined,
                                size: 14,
                                color: context.hintColor,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          color: unreadCount > 0 ? const Color(0xFF10B981) : const Color(0xFF888888),
                          fontSize: 12,
                          fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          messagePreview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: unreadCount > 0
                                ? context.onSurface
                                : const Color(0xFF888888),
                            fontSize: 14.5,
                            fontWeight: unreadCount > 0
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF34D399)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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
