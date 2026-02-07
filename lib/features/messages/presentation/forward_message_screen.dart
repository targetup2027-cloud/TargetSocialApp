import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/message.dart';
import '../application/messages_controller.dart';
import '../../../app/theme/theme_extensions.dart';

class ForwardMessageScreen extends ConsumerStatefulWidget {
  final Message messageToForward;

  const ForwardMessageScreen({
    super.key,
    required this.messageToForward,
  });

  @override
  ConsumerState<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends ConsumerState<ForwardMessageScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedConversationIds = {};
  Timer? _debounceTimer;
  String _searchQuery = '';
  bool _isSending = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() => _searchQuery = value.toLowerCase().trim());
    });
  }

  void _toggleSelection(String conversationId) {
    setState(() {
      if (_selectedConversationIds.contains(conversationId)) {
        _selectedConversationIds.remove(conversationId);
      } else {
        _selectedConversationIds.add(conversationId);
      }
    });
  }

  Future<void> _forwardMessage() async {
    if (_selectedConversationIds.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      for (final conversationId in _selectedConversationIds) {
        final chatController = ref.read(chatControllerProvider(conversationId).notifier);
        await chatController.sendForwardedMessage(
          content: widget.messageToForward.content ?? '',
          type: widget.messageToForward.type,
          forwardedFromMessageId: widget.messageToForward.id,
          mediaUrls: widget.messageToForward.mediaUrls.isNotEmpty 
              ? widget.messageToForward.mediaUrls 
              : null,
        );
      }
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to forward message')),
        );
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(conversationsControllerProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.iconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Forward to...',
          style: TextStyle(color: context.onSurface),
        ),
        actions: [
          if (_selectedConversationIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: _isSending ? null : _forwardMessage,
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'Forward (${_selectedConversationIds.length})',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: context.cardColor,
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(color: context.onSurface),
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                hintStyle: TextStyle(color: context.hintColor),
                prefixIcon: Icon(Icons.search, color: context.hintColor),
                filled: true,
                fillColor: context.scaffoldBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: conversationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error loading conversations', style: TextStyle(color: context.onSurface)),
              ),
              data: (conversations) {
                final filtered = _searchQuery.isEmpty
                    ? conversations
                    : conversations.where((c) {
                        final name = c.isGroup
                            ? (c.groupName ?? 'Group')
                            : (c.participants.isNotEmpty 
                                ? c.participants.first.displayName 
                                : 'User');
                        return name.toLowerCase().contains(_searchQuery);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No conversations found',
                      style: TextStyle(color: context.hintColor),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final conversation = filtered[index];
                    final isSelected = _selectedConversationIds.contains(conversation.id);
                    final participant = conversation.participants.isNotEmpty
                        ? conversation.participants.first
                        : null;
                    final name = conversation.isGroup
                        ? (conversation.groupName ?? 'Group')
                        : (participant?.displayName ?? 'User');
                    final avatar = conversation.isGroup
                        ? (conversation.groupImageUrl ?? 'https://i.pravatar.cc/150?u=group')
                        : (participant?.avatarUrl ?? 'https://i.pravatar.cc/150?u=default');

                    return ListTile(
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: NetworkImage(avatar),
                            backgroundColor: context.dividerColor,
                          ),
                          if (isSelected)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: context.cardColor, width: 2),
                                ),
                                child: const Icon(Icons.check, size: 12, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          color: context.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: conversation.lastMessage != null
                          ? Text(
                              conversation.lastMessage!.content ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: context.hintColor, fontSize: 13),
                            )
                          : null,
                      trailing: isSelected
                          ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
                          : Icon(Icons.circle_outlined, color: context.hintColor),
                      onTap: () => _toggleSelection(conversation.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
