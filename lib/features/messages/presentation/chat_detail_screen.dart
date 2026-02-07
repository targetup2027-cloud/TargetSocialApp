import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/utils/responsive_utils.dart';
import '../domain/entities/message.dart';
import '../application/messages_controller.dart';
import '../../../app/theme/theme_extensions.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'call_screen.dart';
import 'forward_message_screen.dart';
import '../../profile/application/profile_controller.dart';

class ChatDetailScreen extends ConsumerStatefulWidget {
  final String userName;
  final String userAvatar;
  final String conversationId;
  final String? peerUserId;

  const ChatDetailScreen({
    super.key,
    required this.userName,
    required this.userAvatar,
    required this.conversationId,
    this.peerUserId,
  });

  @override
  ConsumerState<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends ConsumerState<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isSending = false;
  bool _isRecording = false;
  bool _isRecordingPaused = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _recordingPath;
  Message? _replyMessage;
  bool _isSelectionMode = false;
  final Set<String> _selectedMessageIds = {};
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsControllerProvider.notifier).markAsRead(widget.conversationId);
    });
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _unfocusInput() {
    if (_inputFocusNode.hasFocus) {
      _inputFocusNode.unfocus();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels <= 0) {
      ref.read(chatControllerProvider(widget.conversationId).notifier).loadMore();
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  void _scrollToMessage(String messageId, List<Message> messages) {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Original message not found')),
      );
      return;
    }
    final reversedIndex = messages.length - 1 - index;
    final estimatedOffset = reversedIndex * 80.0;
    _scrollController.animateTo(
      estimatedOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String _getReplyPreviewSnippet(Message msg) {
    final content = msg.content ?? '';
    if (content.startsWith('[Image_Path:')) return '📷 Photo';
    if (content.startsWith('[Video_Path:')) return '🎥 Video';
    if (content.startsWith('[Voice:') || content.startsWith('[Audio_Path:')) return '🎵 Voice message';
    if (content.startsWith('[File_Path:')) return '📎 File';
    return content.isNotEmpty ? content : 'Attachment';
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) return;

    final content = _messageController.text.trim();
    _messageController.clear();

    setState(() => _isSending = true);

    try {
      await ref.read(chatControllerProvider(widget.conversationId).notifier).sendMessage(
        content,
        replyToMessageId: _replyMessage?.id,
        replyToMessage: _replyMessage,
      );
      if (mounted) setState(() => _replyMessage = null);
    } catch (e) {
      debugPrint('Error sending message: $e');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatControllerProvider(widget.conversationId));

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      resizeToAvoidBottomInset: true,
      appBar: _isSelectionMode ? _buildSelectionAppBar(context) : _buildNormalAppBar(context),
      body: GestureDetector(
        onTap: _unfocusInput,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Column(
            children: [
              Expanded(
                child: CenteredContentColumn(
                  child: messagesAsync.when(
                    data: (messages) {
                      if (messages.isEmpty) {
                        final peerProfile = widget.peerUserId != null
                            ? ref.watch(userProfileProvider(widget.peerUserId!))
                            : null;
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: _openPeerProfile,
                                          child: Container(
                                            width: 96,
                                            height: 96,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: const Color(0xFF10B981),
                                                width: 3,
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                imageUrl: widget.userAvatar,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => Container(
                                                  color: context.dividerColor,
                                                  child: Icon(Icons.person, size: 48, color: context.hintColor),
                                                ),
                                                errorWidget: (context, url, error) => Container(
                                                  color: context.dividerColor,
                                                  child: Icon(Icons.person, size: 48, color: context.hintColor),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        GestureDetector(
                                          onTap: _openPeerProfile,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  widget.userName,
                                                  style: TextStyle(
                                                    color: context.onSurface,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (peerProfile?.valueOrNull?.isVerified == true) ...[
                                                const SizedBox(width: 4),
                                                const Icon(
                                                  Icons.verified,
                                                  size: 18,
                                                  color: Color(0xFF10B981),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        peerProfile?.when(
                                          data: (profile) => Column(
                                            children: [
                                              if (profile.bio?.isNotEmpty == true) ...[
                                                const SizedBox(height: 8),
                                                Text(
                                                  profile.bio!,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: context.hintColor,
                                                    fontSize: 14,
                                                    height: 1.4,
                                                  ),
                                                ),
                                              ],
                                              const SizedBox(height: 8),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (profile.location?.isNotEmpty == true) ...[
                                                    Icon(Icons.location_on_outlined, size: 14, color: context.hintColor),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      profile.location!,
                                                      style: TextStyle(color: context.hintColor, fontSize: 12),
                                                    ),
                                                    const SizedBox(width: 12),
                                                  ],
                                                  Icon(Icons.people_outline, size: 14, color: context.hintColor),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${profile.followersCount} followers',
                                                    style: TextStyle(color: context.hintColor, fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          loading: () => const SizedBox(height: 40),
                                          error: (_, __) => const SizedBox.shrink(),
                                        ) ?? const SizedBox.shrink(),
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Say something to start chatting',
                                            style: TextStyle(
                                              color: context.hintColor,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          alignment: WrapAlignment.center,
                                          children: [
                                            _QuickActionChip(
                                              label: '👋 Say hi',
                                              onTap: () {
                                                _messageController.text = 'Hey! 👋';
                                                _inputFocusNode.requestFocus();
                                              },
                                            ),
                                            _QuickActionChip(
                                              label: 'How are you?',
                                              onTap: () {
                                                _messageController.text = 'How are you?';
                                                _inputFocusNode.requestFocus();
                                              },
                                            ),
                                            _QuickActionChip(
                                              label: 'Send a photo',
                                              icon: Icons.camera_alt_outlined,
                                              onTap: _showAttachmentOptions,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(20),
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[messages.length - 1 - index];
                          final isMe = message.senderId == 'currentUser';
                          final isSelected = _selectedMessageIds.contains(message.id);
                          return Dismissible(
                            key: ValueKey('swipe_${message.id}'),
                            direction: DismissDirection.startToEnd,
                            confirmDismiss: (direction) async {
                              HapticFeedback.lightImpact();
                              setState(() => _replyMessage = message);
                              return false;
                            },
                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.reply,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                              ),
                            ),
                            child: GestureDetector(
                              onLongPress: () => _onMessageLongPress(message, isMe),
                              onTap: _isSelectionMode ? () => _toggleMessageSelection(message.id) : null,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.15) : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _MessageBubble(
                                  key: ValueKey(message.id),
                                  message: message,
                                  isMe: isMe,
                                  timeLabel: _formatTime(message.createdAt),
                                  otherAvatar: widget.userAvatar,
                                  isSelected: isSelected,
                                  isSelectionMode: _isSelectionMode,
                                  peerName: widget.userName,
                                  onQuotedTap: (replyId) => _scrollToMessage(replyId, messages),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF10B981)),
                    ),
                    error: (e, s) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: context.hintColor),
                          const SizedBox(height: 16),
                          Text('Failed to load messages', style: TextStyle(color: context.hintColor)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              CenteredContentColumn(
                child: _isRecording ? _buildRecordingUI() : _buildInputArea(),
              ),
            ],
          ),
            const UniverseBackButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.scaffoldBg,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: context.iconColor),
        onPressed: _exitSelectionMode,
      ),
      title: Text(
        '${_selectedMessageIds.length} selected',
        style: TextStyle(
          color: context.onSurface,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        if (_selectedMessageIds.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
            onPressed: _showDeleteSelectedConfirmation,
          ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: context.dividerColor, height: 1),
      ),
    );
  }

  PreferredSizeWidget _buildNormalAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppBar(
      backgroundColor: context.scaffoldBg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 0,
      shape: Border(
        bottom: BorderSide(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
          width: 0.5,
        ),
      ),
      leadingWidth: 40,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, size: 24, color: context.iconColor),
        onPressed: () => Navigator.pop(context),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 20,
      ),
      title: GestureDetector(
        onTap: _openPeerProfile,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: widget.userAvatar,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: context.dividerColor,
                        child: Icon(Icons.person, size: 20, color: context.hintColor),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: context.dividerColor,
                        child: Icon(Icons.person, size: 20, color: context.hintColor),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: context.scaffoldBg,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.userName,
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Online',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => CallScreen(
                  userName: widget.userName,
                  userAvatar: widget.userAvatar,
                  isVideoCall: true,
                ),
              ),
            );
          },
          icon: Icon(Icons.videocam_rounded, color: context.iconColor, size: 24),
          tooltip: 'Video Call',
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => CallScreen(
                  userName: widget.userName,
                  userAvatar: widget.userAvatar,
                  isVideoCall: false,
                ),
              ),
            );
          },
          icon: Icon(Icons.call_rounded, color: context.iconColor, size: 22),
          tooltip: 'Voice Call',
        ),
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert_rounded, color: context.iconColor, size: 24),
          color: context.cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (value) {
            if (value == 'profile') {
              _openPeerProfile();
            } else if (value == 'mute') {
              ref.read(conversationsControllerProvider.notifier).toggleMute(widget.conversationId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Notifications muted'),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            } else if (value == 'clear') {
              _showClearChatConfirmation();
            } else if (value == 'delete') {
              _showDeleteConversationDialog();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'profile',
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: context.iconColor, size: 20),
                  const SizedBox(width: 12),
                  Text('View Profile', style: TextStyle(color: context.onSurface)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(Icons.volume_off, color: context.iconColor, size: 20),
                  const SizedBox(width: 12),
                  Text('Mute', style: TextStyle(color: context.onSurface)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.cleaning_services_outlined, color: context.iconColor, size: 20),
                  const SizedBox(width: 12),
                  Text('Clear Chat', style: TextStyle(color: context.onSurface)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  SizedBox(width: 12),
                  Text('Delete Conversation', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _openPeerProfile() {
    final peerUserId = widget.peerUserId;
    if (peerUserId == null || peerUserId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile unavailable'),
          backgroundColor: context.hintColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    context.pushNamed('visitor-profile', pathParameters: {'userId': peerUserId});
  }

  void _toggleMessageSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
        if (_selectedMessageIds.isEmpty) {
          _isSelectionMode = false;
        }
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedMessageIds.clear();
    });
  }

  void _onMessageLongPress(Message message, bool isMe) {
    HapticFeedback.mediumImpact();
    if (_isSelectionMode) {
      _toggleMessageSelection(message.id);
    } else {
      _showMessageOptionsSheet(message, isMe);
    }
  }

  void _showMessageOptionsSheet(Message message, bool isMe) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
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
              if (message.type == MessageType.text)
                ListTile(
                  leading: Icon(Icons.copy, color: context.iconColor),
                  title: Text('Copy Text', style: TextStyle(color: context.onSurface)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _copyMessageText(message.content ?? '');
                  },
                ),
              ListTile(
                leading: Icon(Icons.reply, color: context.iconColor),
                title: Text('Reply', style: TextStyle(color: context.onSurface)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _replyMessage = message);
                },
              ),
              ListTile(
                leading: Icon(Icons.forward, color: context.iconColor),
                title: Text('Forward', style: TextStyle(color: context.onSurface)),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ForwardMessageScreen(messageToForward: message),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.select_all, color: Color(0xFF10B981)),
                title: Text('Select Multiple', style: TextStyle(color: context.onSurface)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _isSelectionMode = true;
                    _selectedMessageIds.add(message.id);
                  });
                },
              ),
              if (isMe && message.type == MessageType.text && !(message.content ?? '').startsWith('['))
                ListTile(
                  leading: Icon(Icons.edit, color: context.iconColor),
                  title: Text('Edit', style: TextStyle(color: context.onSurface)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showEditMessageDialog(message);
                  },
                ),
              if (isMe)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Color(0xFFEF4444)),
                  title: const Text('Delete for Everyone', style: TextStyle(color: Color(0xFFEF4444))),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showDeleteSingleMessageConfirmation(message.id, forEveryone: true);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                title: const Text('Delete for Me', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                  Navigator.pop(ctx);
                  _showDeleteSingleMessageConfirmation(message.id, forEveryone: false);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteSelectedConfirmation() {
    final count = _selectedMessageIds.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('Delete $count message${count > 1 ? 's' : ''}?', style: TextStyle(color: context.onSurface)),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: context.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.hintColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(chatControllerProvider(widget.conversationId).notifier)
                  .deleteMultipleMessages(_selectedMessageIds.toList());
              _exitSelectionMode();
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _showClearChatConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('Clear Chat?', style: TextStyle(color: context.onSurface)),
        content: Text(
          'All messages in this conversation will be removed for you. This action cannot be undone.',
          style: TextStyle(color: context.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.hintColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(chatControllerProvider(widget.conversationId).notifier).clearChat();
            },
            child: const Text('Clear', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _showDeleteSingleMessageConfirmation(String messageId, {required bool forEveryone}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text(
          forEveryone ? 'Delete for Everyone?' : 'Delete for Me?',
          style: TextStyle(color: context.onSurface),
        ),
        content: Text(
          forEveryone
              ? 'This message will be deleted for all participants.'
              : 'This message will be deleted only for you.',
          style: TextStyle(color: context.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.hintColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(chatControllerProvider(widget.conversationId).notifier).deleteMessage(messageId);
              _exitSelectionMode();
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _showEditMessageDialog(Message message) {
    final controller = TextEditingController(text: message.content);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('Edit Message', style: TextStyle(color: context.onSurface)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 5,
          minLines: 1,
          style: TextStyle(color: context.onSurface),
          decoration: InputDecoration(
            hintText: 'Message',
            hintStyle: TextStyle(color: context.hintColor),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.hintColor)),
          ),
          TextButton(
            onPressed: () {
              final newContent = controller.text.trim();
              if (newContent.isNotEmpty && newContent != message.content) {
                ref.read(chatControllerProvider(widget.conversationId).notifier)
                    .editMessage(message.id, newContent);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: Color(0xFF10B981))),
          ),
        ],
      ),
    );
  }

  void _copyMessageText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteConversationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('Delete Conversation?', style: TextStyle(color: context.onSurface)),
        content: Text(
          'This conversation will be permanently deleted. This action cannot be undone.',
          style: TextStyle(color: context.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.hintColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(conversationsControllerProvider.notifier).deleteConversation(widget.conversationId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _sendMediaMessage(String mediaPath, String fileName, {bool isVideo = false, bool isDocument = false}) async {
    if (_isSending) return;
    setState(() => _isSending = true);
    try {
      final String tag;
      if (isDocument) {
        tag = 'File_Path';
      } else if (isVideo) {
        tag = 'Video_Path';
      } else {
        tag = 'Image_Path';
      }
      await ref.read(chatControllerProvider(widget.conversationId).notifier)
          .sendMessage('[$tag: $mediaPath|$fileName]');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sent: $fileName'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error sending media: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to send media'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<String?> _cropImage(String imagePath) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Photo',
          toolbarColor: const Color(0xFF10B981),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF10B981),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Edit Photo',
          doneButtonTitle: 'Send',
          cancelButtonTitle: 'Cancel',
        ),
      ],
    );
    return croppedFile?.path;
  }

  Future<void> _pickAndSendImage(ImageSource source) async {
    final image = await _imagePicker.pickImage(source: source, imageQuality: 85);
    if (image == null || !mounted) return;
    
    final croppedPath = await _cropImage(image.path);
    if (croppedPath != null && mounted) {
      await _sendMediaMessage(croppedPath, image.name);
    }
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'],
    );
    if (result != null && result.files.single.path != null && mounted) {
      await _sendMediaMessage(
        result.files.single.path!,
        result.files.single.name,
        isDocument: true,
      );
    }
  }

  void _showAttachmentOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Share',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildAttachmentOption(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: const Color(0xFF8B5CF6),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickAndSendImage(ImageSource.gallery);
                    },
                    isDark: isDark,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: const Color(0xFF10B981),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickAndSendImage(ImageSource.camera);
                    },
                    isDark: isDark,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.videocam_rounded,
                    label: 'Video',
                    color: const Color(0xFFF59E0B),
                    onTap: () async {
                      Navigator.pop(ctx);
                      final video = await _imagePicker.pickVideo(source: ImageSource.gallery);
                      if (video != null && mounted) {
                        final appDir = await getApplicationDocumentsDirectory();
                        final videosDir = Directory('${appDir.path}/chat_videos');
                        if (!videosDir.existsSync()) {
                          videosDir.createSync(recursive: true);
                        }
                        final timestamp = DateTime.now().millisecondsSinceEpoch;
                        final newPath = '${videosDir.path}/${timestamp}_${video.name}';
                        await File(video.path).copy(newPath);
                        await _sendMediaMessage(newPath, video.name, isVideo: true);
                      }
                    },
                    isDark: isDark,
                  ),
                  _buildAttachmentOption(
                    icon: Icons.insert_drive_file_rounded,
                    label: 'Document',
                    color: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickDocument();
                    },
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: context.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showEmojiPicker() {
    final emojis = ['😀', '😂', '❤️', '👍', '🔥', '🎉', '😊', '🙏', '💪', '✨', '😎', '🥳'];
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Quick Emojis',
                style: TextStyle(color: context.onSurface, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: emojis.map((emoji) => GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _messageController.text += emoji;
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: context.scaffoldBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRecordingTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _startRecording() async {
    HapticFeedback.mediumImpact();
    
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Microphone permission required'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    try {
      final dir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _recordingPath = '${dir.path}/voice_$timestamp.m4a';
      
      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _recordingPath!,
      );
      
      setState(() {
        _isRecording = true;
        _isRecordingPaused = false;
        _recordingSeconds = 0;
      });
      
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isRecordingPaused && mounted) {
          setState(() {
            _recordingSeconds++;
          });
        }
      });
    } catch (e) {
      debugPrint('Error starting recording: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to start recording'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _togglePauseRecording() async {
    HapticFeedback.lightImpact();
    try {
      if (_isRecordingPaused) {
        await _audioRecorder.resume();
      } else {
        await _audioRecorder.pause();
      }
      setState(() {
        _isRecordingPaused = !_isRecordingPaused;
      });
    } catch (e) {
      debugPrint('Error toggling pause: $e');
    }
  }

  Future<void> _cancelRecording() async {
    HapticFeedback.mediumImpact();
    _recordingTimer?.cancel();
    
    try {
      await _audioRecorder.stop();
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      debugPrint('Error cancelling recording: $e');
    }
    
    setState(() {
      _isRecording = false;
      _isRecordingPaused = false;
      _recordingSeconds = 0;
      _recordingPath = null;
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cancel, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Recording cancelled'),
          ],
        ),
        backgroundColor: const Color(0xFF6B7280),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _sendVoiceMessage() async {
    HapticFeedback.mediumImpact();
    _recordingTimer?.cancel();
    final duration = _recordingSeconds;
    
    String? audioPath;
    try {
      audioPath = await _audioRecorder.stop();
    } catch (e) {
      debugPrint('Error stopping recording: $e');
    }
    
    setState(() {
      _isRecording = false;
      _isRecordingPaused = false;
      _recordingSeconds = 0;
    });
    
    final pathToSend = audioPath ?? _recordingPath;
    if (pathToSend == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Recording failed'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    _recordingPath = null;
    
    try {
      await ref.read(chatControllerProvider(widget.conversationId).notifier)
          .sendMessage('[Audio_Path: $pathToSend|${_formatRecordingTime(duration)}]', type: MessageType.audio);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Flexible(child: Text('Voice message sent!')),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error sending voice message: $e');
    }
  }

  Widget _buildRecordingUI() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        border: Border(
          top: BorderSide(
            color: isDark
                ? context.dividerColor.withValues(alpha: 0.3)
                : const Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Delete / Cancel Button
            GestureDetector(
              onTap: _cancelRecording,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Color(0xFFEF4444),
                  size: 24,
                ),
              ),
            ),
            
            // Timer and Status Indicator
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatRecordingTime(_recordingSeconds),
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isRecordingPaused ? const Color(0xFFF59E0B) : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isRecordingPaused ? 'Paused' : 'Recording',
                        style: TextStyle(
                          color: context.hintColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Controls: Pause/Play and Send
            Row(
              children: [
                GestureDetector(
                  onTap: _togglePauseRecording,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark 
                          ? context.iconColor.withValues(alpha: 0.1) 
                          : const Color(0xFFF3F4F6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRecordingPaused ? Icons.play_arrow : Icons.pause,
                      color: context.onSurface,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _sendVoiceMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBgColor = isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF3F4F6);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_replyMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: inputBgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    left: BorderSide(color: const Color(0xFF10B981), width: 4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply, size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replying to ${_replyMessage!.senderId == 'currentUser' ? 'You' : widget.userName}',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getReplyPreviewSnippet(_replyMessage!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.onSurface.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _replyMessage = null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attachment Button in Circle
                Container(
                  margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: inputBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _showAttachmentOptions,
                    icon: Transform.rotate(
                      angle: -0.785,
                      child: Icon(
                        Icons.attach_file_rounded,
                        color: context.iconColor.withValues(alpha: 0.7),
                        size: 24,
                      ),
                    ),
                    splashRadius: 24,
                    constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Input Field Pill with Emoji on Right
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: inputBgColor,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 120),
                            child: TextField(
                              controller: _messageController,
                              focusNode: _inputFocusNode,
                              style: TextStyle(
                                color: context.onSurface, 
                                fontSize: 16,
                                height: 1.35,
                              ),
                              maxLines: null,
                              minLines: 1,
                              textCapitalization: TextCapitalization.sentences,
                              cursorColor: const Color(0xFF10B981),
                              decoration: InputDecoration(
                                hintText: 'Message...',
                                hintStyle: TextStyle(
                                  color: context.hintColor.withValues(alpha: 0.6),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                filled: false,
                                contentPadding: const EdgeInsets.only(left: 16, right: 0, top: 12, bottom: 12),
                              ),
                            ),
                          ),
                        ),
                        
                        // Emoji Icon on the RIGHT
                        IconButton(
                           onPressed: _showEmojiPicker,
                           icon: Icon(
                             Icons.emoji_emotions_outlined,
                             color: context.hintColor.withValues(alpha: 0.7),
                             size: 24,
                           ),
                           splashRadius: 20,
                           padding: const EdgeInsets.only(left: 4, right: 12, top: 10, bottom: 10),
                           constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),

                // Mic / Send Button
                GestureDetector(
                  onTap: _hasText ? (_isSending ? null : _sendMessage) : _startRecording,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isSending 
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          _hasText ? Icons.send_rounded : (_isRecording ? Icons.stop : Icons.mic_rounded),
                          color: Colors.white,
                          size: 24,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;
  final String timeLabel;
  final String otherAvatar;
  final bool isSelected;
  final bool isSelectionMode;
  final String peerName;
  final void Function(String messageId)? onQuotedTap;

  const _MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.timeLabel,
    required this.otherAvatar,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.peerName = '',
    this.onQuotedTap,
  });

  @override
  Widget build(BuildContext context) {
    final isImageMessage = (message.content ?? '').startsWith('[Image_Path: ');
    final isVideoMessage = (message.content ?? '').startsWith('[Video_Path: ');
    final isMediaMessage = isImageMessage || isVideoMessage;
    final tablet = isTablet(context);
    final bubbleMaxWidth = tablet
        ? MediaQuery.sizeOf(context).width * kTabletBubbleMaxWidthFactor
        : double.infinity;

    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: isMe ? 48 : 0,
        right: isMe ? 0 : 48,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: context.dividerColor,
              backgroundImage: message.senderAvatarUrl != null
                  ? NetworkImage(message.senderAvatarUrl!)
                  : NetworkImage(otherAvatar),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: bubbleMaxWidth),
              child: isMediaMessage
                  ? _buildMediaBubble(context, isImageMessage)
                  : _buildTextBubble(context),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMediaBubble(BuildContext context, bool isImage) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (message.isForwarded)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: context.cardColor.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.forward, size: 12, color: context.hintColor),
                const SizedBox(width: 4),
                Text(
                  'Forwarded',
                  style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: context.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          child: Stack(
            children: [
              if (isImage)
                _ImageMessageContent(
                  content: message.content!,
                  isMe: isMe,
                )
              else
                _VideoMessageContent(
                  content: message.content!,
                  isMe: isMe,
                ),
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.status == MessageStatus.read
                              ? Icons.done_all
                              : message.status == MessageStatus.delivered
                                  ? Icons.done_all
                                  : Icons.done,
                          size: 14,
                          color: message.status == MessageStatus.read
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextBubble(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isMe 
            ? null 
            : (Theme.of(context).brightness == Brightness.dark 
                ? const Color(0xFF1C1C2E) 
                : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18),
        ),
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (message.isForwarded)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.forward,
                    size: 12,
                    color: isMe 
                        ? Colors.white.withValues(alpha: 0.7) 
                        : context.hintColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Forwarded',
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isMe 
                          ? Colors.white.withValues(alpha: 0.7) 
                          : context.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          if (message.replyToMessage != null || message.replyToMessageId != null)
            GestureDetector(
              onTap: message.replyToMessageId != null && onQuotedTap != null
                  ? () => onQuotedTap!(message.replyToMessageId!)
                  : null,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isMe 
                      ? Colors.white.withValues(alpha: 0.15)
                      : (Theme.of(context).brightness == Brightness.dark 
                          ? const Color(0xFF2A2A3E)
                          : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                  border: Border(
                    left: BorderSide(
                      color: isMe ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF10B981), 
                      width: 3,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.replyToMessage?.senderId == 'currentUser' 
                          ? 'You' 
                          : (message.replyToMessage?.senderName ?? peerName),
                      style: TextStyle(
                        color: isMe ? Colors.white : const Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getReplyPreview(message.replyToMessage),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isMe 
                            ? Colors.white.withValues(alpha: 0.8) 
                            : context.onSurface.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if ((message.content ?? '').startsWith('[File_Path: '))
            _FileMessageContent(
              content: message.content!,
              isMe: isMe,
            )
          else if (message.type == MessageType.audio || (message.content ?? '').startsWith('[Voice:') || (message.content ?? '').startsWith('[Audio_Path:'))
            _AudioMessageContent(
              message: message,
              isMe: isMe,
            )
          else
            Text(
              message.content ?? '',
              style: TextStyle(
                color: isMe ? Colors.white : context.onSurface,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isEdited) ...[
                Text(
                  'edited',
                  style: TextStyle(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.5)
                        : context.hintColor.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                timeLabel,
                style: TextStyle(
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.7)
                      : context.hintColor,
                  fontSize: 10,
                ),
              ),
              if (isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  message.status == MessageStatus.read
                      ? Icons.done_all
                      : message.status == MessageStatus.delivered
                          ? Icons.done_all
                          : Icons.done,
                  size: 14,
                  color: message.status == MessageStatus.read
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _getReplyPreview(Message? replyMsg) {
    if (replyMsg == null) return 'Original message unavailable';
    final content = replyMsg.content ?? '';
    if (content.startsWith('[Image_Path:')) return '📷 Photo';
    if (content.startsWith('[Video_Path:')) return '🎥 Video';
    if (content.startsWith('[Voice:') || content.startsWith('[Audio_Path:')) return '🎵 Voice message';
    if (content.startsWith('[File_Path:')) return '📎 File';
    return content;
  }
}

class _AudioMessageContent extends StatefulWidget {
  final Message message;
  final bool isMe;

  const _AudioMessageContent({
    required this.message,
    required this.isMe,
  });

  @override
  State<_AudioMessageContent> createState() => _AudioMessageContentState();
}

class _AudioMessageContentState extends State<_AudioMessageContent> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  double _progress = 0.0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          if (_totalDuration.inMilliseconds > 0) {
            _progress = position.inMilliseconds / _totalDuration.inMilliseconds;
          }
        });
      }
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _progress = 0.0;
          _currentPosition = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  (String?, String) _parseContent() {
    final content = widget.message.content ?? '';
    
    final audioPathMatch = RegExp(r'\[Audio_Path:\s*(.+?)\|(.+?)\]').firstMatch(content);
    if (audioPathMatch != null) {
      return (audioPathMatch.group(1), audioPathMatch.group(2) ?? '0:00');
    }
    
    final voiceMatch = RegExp(r'\[Voice:\s*(\d{1,2}:\d{2})\]').firstMatch(content);
    if (voiceMatch != null) {
      return (null, voiceMatch.group(1) ?? '0:00');
    }
    
    return (null, '0:00');
  }

  String _formatDuration(Duration duration) {
    final mins = duration.inMinutes.toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  Future<void> _togglePlayPause() async {
    final (audioPath, _) = _parseContent();
    
    if (audioPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Audio file not available'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(DeviceFileSource(audioPath));
      }
    } catch (e) {
      debugPrint('Error playing audio: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to play audio'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final (_, durationStr) = _parseContent();
    final displayDuration = _isPlaying || _currentPosition.inMilliseconds > 0
        ? _formatDuration(_currentPosition)
        : durationStr;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: _togglePlayPause,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: widget.isMe 
                  ? Colors.white.withValues(alpha: 0.2) 
                  : const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: widget.isMe ? Colors.white : const Color(0xFF10B981),
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 120,
                child: Row(
                  children: List.generate(20, (index) {
                    final height = 4.0 + (index % 5) * 3.0 + (index % 3) * 2.0;
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0.5),
                        height: height,
                        decoration: BoxDecoration(
                          color: index / 20 <= _progress
                              ? (widget.isMe ? Colors.white : const Color(0xFF10B981))
                              : (widget.isMe 
                                  ? Colors.white.withValues(alpha: 0.4) 
                                  : context.hintColor.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayDuration,
                style: TextStyle(
                  color: widget.isMe 
                      ? Colors.white.withValues(alpha: 0.8) 
                      : context.hintColor,
                  fontSize: 11,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FileMessageContent extends StatelessWidget {
  final String content;
  final bool isMe;

  const _FileMessageContent({
    required this.content,
    required this.isMe,
  });

  (String, String) _parseContent() {
    final inner = content.substring(12, content.length - 1);
    final parts = inner.split('|');
    final path = parts.isNotEmpty ? parts[0] : '';
    final name = parts.length > 1 ? parts[1] : path.split('/').last.split('\\').last;
    return (path, name);
  }

  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.grid_on;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.article;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return const Color(0xFFE53935);
      case 'doc':
      case 'docx':
        return const Color(0xFF1976D2);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF43A047);
      case 'ppt':
      case 'pptx':
        return const Color(0xFFFF7043);
      case 'txt':
        return const Color(0xFF757575);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (filePath, fileName) = _parseContent();
    final iconColor = _getFileColor(fileName);
    
    return GestureDetector(
      onTap: () async {
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open file: ${result.message}'),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMe 
                  ? Colors.white.withValues(alpha: 0.2) 
                  : iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(fileName),
              color: isMe ? Colors.white : iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    color: isMe ? Colors.white : context.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  fileName.split('.').last.toUpperCase(),
                  style: TextStyle(
                    color: isMe 
                        ? Colors.white.withValues(alpha: 0.7) 
                        : context.hintColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageMessageContent extends StatelessWidget {
  final String content;
  final bool isMe;

  const _ImageMessageContent({
    required this.content,
    required this.isMe,
  });

  String _parseImagePath() {
    final inner = content.substring(13, content.length - 1);
    final parts = inner.split('|');
    return parts.isNotEmpty ? parts[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = _parseImagePath();
    final file = File(imagePath);
    final fileExists = imagePath.isNotEmpty && file.existsSync();

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black87,
          builder: (ctx) => _FullScreenImageViewer(imagePath: imagePath),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: fileExists
            ? Image.file(
                file,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: frame != null
                        ? child
                        : Container(
                            height: 200,
                            width: 200,
                            color: isMe
                                ? Colors.white.withValues(alpha: 0.2)
                                : context.hintColor.withValues(alpha: 0.2),
                            child: const Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  width: 200,
                  color: isMe
                      ? Colors.white.withValues(alpha: 0.2)
                      : context.hintColor.withValues(alpha: 0.2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 40,
                        color: isMe ? Colors.white70 : context.hintColor,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to view',
                        style: TextStyle(
                          fontSize: 11,
                          color: isMe ? Colors.white70 : context.hintColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Container(
                height: 200,
                width: 200,
                color: isMe
                    ? Colors.white.withValues(alpha: 0.2)
                    : context.hintColor.withValues(alpha: 0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported,
                      size: 40,
                      color: isMe ? Colors.white70 : context.hintColor,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to view',
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe ? Colors.white70 : context.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatelessWidget {
  final String imagePath;

  const _FullScreenImageViewer({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final file = File(imagePath);
    final fileExists = imagePath.isNotEmpty && file.existsSync();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: fileExists
                ? InteractiveViewer(
                    key: const Key('image_viewer_interactive'),
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.file(
                      file,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildErrorUI(context),
                    ),
                  )
                : _buildErrorUI(context),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 8,
            child: IconButton(
              key: const Key('image_viewer_close_button'),
              onPressed: () => Navigator.of(context).pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorUI(BuildContext context) {
    return Column(
      key: const Key('image_viewer_error_ui'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.image_not_supported,
          size: 64,
          color: Colors.white54,
        ),
        const SizedBox(height: 16),
        const Text(
          'Image unavailable',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF10B981)),
          label: const Text(
            'Go Back',
            style: TextStyle(color: Color(0xFF10B981)),
          ),
        ),
      ],
    );
  }
}

class _VideoMessageContent extends StatefulWidget {
  final String content;
  final bool isMe;

  const _VideoMessageContent({
    required this.content,
    required this.isMe,
  });

  @override
  State<_VideoMessageContent> createState() => _VideoMessageContentState();
}

class _VideoMessageContentState extends State<_VideoMessageContent> {
  static final Map<String, Uint8List> _memoryCache = {};
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  bool _hasError = false;
  late String _videoPath;

  (String, String) _parseContent() {
    final inner = widget.content.substring(13, widget.content.length - 1);
    final parts = inner.split('|');
    final path = parts.isNotEmpty ? parts[0] : '';
    final name = parts.length > 1 ? parts[1] : path.split('/').last.split('\\').last;
    return (path, name);
  }

  @override
  void initState() {
    super.initState();
    final (path, _) = _parseContent();
    _videoPath = path;
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    if (_videoPath.isEmpty || !File(_videoPath).existsSync()) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    final cacheKey = 'chat_${_videoPath.hashCode}';

    if (_memoryCache.containsKey(cacheKey)) {
      setState(() {
        _thumbnailBytes = _memoryCache[cacheKey];
        _isLoading = false;
      });
      return;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbDir = Directory('${appDir.path}/chat_video_thumbs');
      if (!await thumbDir.exists()) {
        await thumbDir.create(recursive: true);
      }
      final cachedFile = File('${thumbDir.path}/$cacheKey.jpg');

      if (await cachedFile.exists()) {
        final bytes = await cachedFile.readAsBytes();
        _memoryCache[cacheKey] = bytes;
        if (mounted) {
          setState(() {
            _thumbnailBytes = bytes;
            _isLoading = false;
          });
        }
        return;
      }

      final bytes = await VideoThumbnail.thumbnailData(
        video: _videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,
        quality: 75,
        timeMs: 0,
      );

      if (bytes != null && bytes.isNotEmpty) {
        _memoryCache[cacheKey] = bytes;
        await cachedFile.writeAsBytes(bytes);
        if (mounted) {
          setState(() {
            _thumbnailBytes = bytes;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasError = true;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('video_thumbnail_tap'),
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black87,
          builder: (ctx) => _FullScreenVideoPlayer(videoPath: _videoPath),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          key: const Key('video_thumbnail'),
          height: 200,
          width: 200,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (_isLoading)
                Container(
                  color: widget.isMe
                      ? Colors.white.withValues(alpha: 0.2)
                      : context.hintColor.withValues(alpha: 0.2),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
                  ),
                )
              else if (_hasError || _thumbnailBytes == null)
                Container(
                  color: widget.isMe
                      ? Colors.white.withValues(alpha: 0.2)
                      : context.hintColor.withValues(alpha: 0.2),
                  child: Icon(
                    Icons.videocam_off,
                    size: 40,
                    color: widget.isMe ? Colors.white70 : context.hintColor,
                  ),
                )
              else
                Image.memory(
                  _thumbnailBytes!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  gaplessPlayback: true,
                ),
              Center(
                child: Container(
                  key: const Key('video_play_overlay'),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenVideoPlayer extends StatefulWidget {
  final String videoPath;

  const _FullScreenVideoPlayer({required this.videoPath});

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _showControls = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final file = File(widget.videoPath);
    final fileExists = widget.videoPath.isNotEmpty && file.existsSync();

    if (!fileExists) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Video file not found';
        });
      }
      return;
    }

    try {
      _controller = VideoPlayerController.file(file);
      await _controller!.initialize();
      if (mounted) {
        setState(() => _isLoading = false);
        _controller!.play();
        _startHideControlsTimer();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load video';
        });
      }
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller != null && _controller!.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideControlsTimer();
    }
  }

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _hideControlsTimer?.cancel();
      } else {
        _controller!.play();
        _startHideControlsTimer();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final mins = duration.inMinutes.toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('video_player_screen'),
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: [
            Center(
              child: _error != null
                  ? _buildErrorUI(context)
                  : _isLoading
                      ? _buildLoadingUI()
                      : _controller != null && _controller!.value.isInitialized
                          ? AspectRatio(
                              aspectRatio: _controller!.value.aspectRatio,
                              child: VideoPlayer(_controller!),
                            )
                          : const SizedBox.shrink(),
            ),
            if (!_isLoading && _error == null && _showControls)
              _buildPlayerControls(),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: AnimatedOpacity(
                opacity: _showControls ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  key: const Key('video_player_close_button'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerControls() {
    if (_controller == null) return const SizedBox.shrink();
    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.of(context).padding.bottom + 20,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _controller!,
              builder: (context, value, child) {
                return Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF10B981),
                        inactiveTrackColor: Colors.white24,
                        thumbColor: const Color(0xFF10B981),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        trackHeight: 3,
                      ),
                      child: Slider(
                        key: const Key('video_player_seek_bar'),
                        value: value.position.inMilliseconds.toDouble(),
                        min: 0,
                        max: value.duration.inMilliseconds.toDouble().clamp(1, double.infinity),
                        onChanged: (v) {
                          _controller!.seekTo(Duration(milliseconds: v.toInt()));
                        },
                        onChangeStart: (_) => _hideControlsTimer?.cancel(),
                        onChangeEnd: (_) => _startHideControlsTimer(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(value.position),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                          Text(
                            _formatDuration(value.duration),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    final pos = _controller!.value.position - const Duration(seconds: 10);
                    _controller!.seekTo(pos < Duration.zero ? Duration.zero : pos);
                  },
                  icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    key: const Key('video_player_play_pause'),
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: ValueListenableBuilder<VideoPlayerValue>(
                      valueListenable: _controller!,
                      builder: (context, value, child) {
                        return Icon(
                          value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  onPressed: () {
                    final pos = _controller!.value.position + const Duration(seconds: 10);
                    final max = _controller!.value.duration;
                    _controller!.seekTo(pos > max ? max : pos);
                  },
                  icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingUI() {
    return Column(
      key: const Key('video_player_loading'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 24),
        const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF10B981),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Loading video...',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorUI(BuildContext context) {
    return Column(
      key: const Key('video_player_error_ui'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.videocam_off,
          size: 64,
          color: Colors.white54,
        ),
        const SizedBox(height: 16),
        Text(
          _error ?? 'Video unavailable',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF10B981)),
          label: const Text(
            'Go Back',
            style: TextStyle(color: Color(0xFF10B981)),
          ),
        ),
      ],
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withValues(alpha: 0.08) 
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.12) 
                  : const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
