import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme_extensions.dart';
import '../domain/entities/post.dart';
import '../application/posts_controller.dart';
import '../application/current_user_provider.dart';
import '../models/post_data.dart';
import '../widgets/reaction_selector.dart';

const int _kMaxCommentLength = 1000;

const Map<ReactionType, _ReactionStyle> _reactionStyles = {
  ReactionType.love: _ReactionStyle(Icons.favorite, 0xFFEF4444),
  ReactionType.like: _ReactionStyle(Icons.thumb_up, 0xFF3B82F6),
  ReactionType.fire: _ReactionStyle(Icons.local_fire_department, 0xFFF97316),
  ReactionType.inspire: _ReactionStyle(Icons.auto_awesome, 0xFFA855F7),
  ReactionType.boost: _ReactionStyle(Icons.bolt, 0xFFEAB308),
};

class _ReactionStyle {
  final IconData icon;
  final int color;
  const _ReactionStyle(this.icon, this.color);
}

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  final ScrollController? scrollController;

  const CommentsSheet({super.key, required this.postId, this.scrollController});

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();

  static void show(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => CommentsSheet(
              postId: postId,
              scrollController: scrollController,
            ),
          ),
        );
      },
    );
  }
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final GlobalKey _composerKey = GlobalKey();
  bool _isSubmitting = false;
  String? _replyToCommentId;
  String? _replyToAuthorName;
  String? _editingCommentId;
  ScrollController? _scrollController;

  ScrollController get _effectiveScrollController =>
      widget.scrollController ?? (_scrollController ??= ScrollController());

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController?.dispose();
    super.dispose();
  }

  void _startReply(Comment comment) {
    _cancelEdit();
    setState(() {
      _replyToCommentId = comment.id;
      _replyToAuthorName = comment.authorName;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _commentFocusNode.requestFocus();
      if (_effectiveScrollController.hasClients) {
        _effectiveScrollController.animateTo(
          _effectiveScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToAuthorName = null;
    });
    _commentController.clear();
  }

  void _startEdit(Comment comment) {
    _cancelReply();
    setState(() {
      _editingCommentId = comment.id;
      _commentController.text = comment.content;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _commentFocusNode.requestFocus();
    });
  }

  void _cancelEdit() {
    setState(() {
      _editingCommentId = null;
      _commentController.clear();
    });
    FocusScope.of(context).unfocus();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    if (text.length > _kMaxCommentLength) {
      _showError('Comment is too long (max $_kMaxCommentLength characters)');
      return;
    }

    final post = ref.read(postsControllerProvider.notifier).getPostById(widget.postId);
    if (post != null && !post.commentsEnabled && _editingCommentId == null) {
      _showError('Comments are closed');
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.lightImpact();

    try {
      if (_editingCommentId != null) {
        await ref.read(commentsControllerProvider(widget.postId).notifier).editComment(
          commentId: _editingCommentId!,
          content: text,
        );
        _cancelEdit();
      } else if (_replyToCommentId != null) {
        await ref.read(commentsControllerProvider(widget.postId).notifier).addReply(
          parentCommentId: _replyToCommentId!,
          text: text,
        );
        _commentController.clear();
        _cancelReply();
        _scrollToBottom();
      } else {
        await ref.read(commentsControllerProvider(widget.postId).notifier).addComment(text);
        _commentController.clear();
        _scrollToBottom();
      }
      
      if (mounted && _editingCommentId == null && _replyToCommentId == null) {
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      _showError('Failed to post comment');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_effectiveScrollController.hasClients) return;
      _effectiveScrollController.animateTo(
        _effectiveScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _deleteComment(Comment comment) {
    // Ensure keyboard is hidden
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    final currentUserId = ref.read(currentUserIdProvider);
    
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.6),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curve = Curves.easeOutCubic;
        final tween = Tween<double>(begin: 0.9, end: 1.0);
        final opacity = Tween<double>(begin: 0.0, end: 1.0);
        
        return Transform.scale(
          scale: tween.animate(CurvedAnimation(parent: anim1, curve: curve)).value,
          child: Opacity(
            opacity: opacity.animate(CurvedAnimation(parent: anim1, curve: curve)).value,
            child: AlertDialog(
              backgroundColor: context.cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              contentPadding: EdgeInsets.zero,
              content: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: context.dividerColor.withValues(alpha: 0.5),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.cardColor,
                      context.cardColor.withValues(alpha: 0.95),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Delete Comment',
                      style: TextStyle(
                        color: context.onSurface,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'Are you sure you want to delete this comment? This action cannot be undone.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: context.dividerColor),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.pop(ctx),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: context.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: context.dividerColor,
                          ),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  HapticFeedback.mediumImpact();
                                  
                                  try {
                                    await ref.read(commentsControllerProvider(widget.postId).notifier).deleteComment(
                                      commentId: comment.id,
                                      requestedByUserId: currentUserId,
                                    );
                                  } catch (e) {
                                    _showError('Failed to delete comment');
                                  }
                                },
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(20),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

  void _showReactionSelector(Comment comment) {
    _commentFocusNode.unfocus();
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        
        final currentUserId = ref.read(currentUserIdProvider);
        showReactionSelector(
          context: context,
          currentReaction: comment.userReaction,
          onReactionSelected: (type) {
            try {
              ref.read(commentsControllerProvider(widget.postId).notifier).reactToComment(
                commentId: comment.id,
                userId: currentUserId,
                type: type,
              );
            } catch (e) {
              _showError('Failed to react');
            }
          },
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsControllerProvider(widget.postId));
    final postsAsync = ref.watch(postsControllerProvider);
    final currentUserId = ref.watch(currentUserIdProvider);

    final post = postsAsync.whenOrNull(
      data: (posts) {
        if (posts.isEmpty) return null;
        try {
          return posts.firstWhere((p) => p.id == widget.postId);
        } catch (_) {
          return null;
        }
      },
    );

    if (postsAsync.hasError || (postsAsync.hasValue && post == null)) {
      return Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: context.hintColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Post not found',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      );
    }

    final commentsEnabled = post?.commentsEnabled ?? true;
    final isPostOwner = post?.authorId == currentUserId;

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.hintColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (!commentsEnabled) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.dividerColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock,
                          color: context.hintColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Closed',
                          style: TextStyle(
                            color: context.hintColor,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: context.onSurface),
                  onPressed: () {
                    if (MediaQuery.of(context).viewInsets.bottom > 0) {
                      FocusScope.of(context).unfocus();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            ),
          ),
          Divider(color: context.dividerColor, height: 1),
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height * 0.3,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: context.hintColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No comments yet',
                              style: TextStyle(
                                color: context.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              commentsEnabled ? 'Be the first to comment!' : 'Comments are closed',
                              style: TextStyle(
                                color: context.hintColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final topLevel = comments.where((c) => c.parentCommentId == null).toList()
                  ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

                return ListView.builder(
                  controller: _effectiveScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: topLevel.length,
                  itemBuilder: (context, index) {
                    final comment = topLevel[index];
                    final replies = comments.where((c) => c.parentCommentId == comment.id).toList()
                      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
                    return _CommentThread(
                      comment: comment,
                      replies: replies,
                      allComments: comments,
                      isPostOwner: isPostOwner,
                      currentUserId: currentUserId,
                      onReply: commentsEnabled ? () => _startReply(comment) : null,
                      onReplyToReply: commentsEnabled ? (c) => _startReply(c) : null,
                      onDelete: (c) => _deleteComment(c),
                      onReact: (c) => _showReactionSelector(c),
                      onEdit: (c) => _startEdit(c),
                      commentsEnabled: commentsEnabled,
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              ),
              error: (e, s) => Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: context.hintColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load comments',
                        style: TextStyle(
                          color: context.onSurface,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => ref.invalidate(commentsControllerProvider(widget.postId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_replyToCommentId != null || _editingCommentId != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _editingCommentId != null
                      ? [const Color(0xFF8B5CF6).withValues(alpha: 0.15), const Color(0xFF8B5CF6).withValues(alpha: 0.05)]
                      : [const Color(0xFF3B82F6).withValues(alpha: 0.15), const Color(0xFF3B82F6).withValues(alpha: 0.05)],
                ),
                border: Border(
                  top: BorderSide(color: context.dividerColor),
                  left: BorderSide(
                    color: _editingCommentId != null
                        ? const Color(0xFF8B5CF6)
                        : const Color(0xFF3B82F6),
                    width: 3,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (_editingCommentId != null
                              ? const Color(0xFF8B5CF6)
                              : const Color(0xFF3B82F6))
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _editingCommentId != null ? Icons.edit : Icons.reply,
                      color: _editingCommentId != null
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF3B82F6),
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _editingCommentId != null ? 'Editing comment' : 'Replying to',
                          style: TextStyle(
                            color: context.hintColor,
                            fontSize: 11,
                          ),
                        ),
                        if (_replyToAuthorName != null && _editingCommentId == null)
                          Text(
                            _replyToAuthorName!,
                            style: TextStyle(
                              color: context.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (_editingCommentId != null) {
                        _cancelEdit();
                      } else {
                        _cancelReply();
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: context.dividerColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        color: context.hintColor,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          SafeArea(
            top: false,
            minimum: const EdgeInsets.only(bottom: 4),
            child: Container(
              key: _composerKey,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: context.cardColor,
                border: Border(
                  top: BorderSide(color: context.dividerColor.withValues(alpha: 0.5)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: commentsEnabled
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                              ),
                            ),
                            child: const Icon(Icons.person, color: Colors.white, size: 16),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: context.isDarkMode 
                                  ? Colors.white.withValues(alpha: 0.05) 
                                  : Colors.black.withValues(alpha: 0.03),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: context.isDarkMode 
                                    ? Colors.white.withValues(alpha: 0.1) 
                                    : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: TextField(
                              controller: _commentController,
                              focusNode: _commentFocusNode,
                              textInputAction: TextInputAction.send,
                              keyboardType: TextInputType.multiline,
                              maxLines: 5,
                              minLines: 1,
                              maxLength: _kMaxCommentLength,
                              onChanged: (text) => setState(() {}),
                              onSubmitted: (_) => _submitComment(),
                              style: TextStyle(color: context.onSurface, fontSize: 15),
                              decoration: InputDecoration(
                                hintText: _editingCommentId != null
                                    ? 'Edit your comment...'
                                    : _replyToCommentId != null
                                        ? 'Reply to ${_replyToAuthorName ?? "user"}...'
                                        : 'Add a comment...',
                                hintStyle: TextStyle(
                                  color: context.hintColor,
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                isDense: true,
                                counterText: '',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 200),
                            scale: _commentController.text.trim().isNotEmpty ? 1.0 : 0.0,
                            child: GestureDetector(
                              onTap: _isSubmitting 
                                  ? null 
                                  : () {
                                      HapticFeedback.mediumImpact();
                                      _submitComment();
                                    },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: _isSubmitting
                                    ? const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.lock,
                            color: context.hintColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Comments are closed',
                            style: TextStyle(
                              color: context.hintColor,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentThread extends StatelessWidget {
  final Comment comment;
  final List<Comment> replies;
  final List<Comment> allComments;
  final bool isPostOwner;
  final String currentUserId;
  final VoidCallback? onReply;
  final void Function(Comment)? onReplyToReply;
  final void Function(Comment) onDelete;
  final void Function(Comment) onReact;
  final void Function(Comment)? onEdit;
  final bool commentsEnabled;

  const _CommentThread({
    required this.comment,
    required this.replies,
    required this.allComments,
    required this.isPostOwner,
    required this.currentUserId,
    this.onReply,
    this.onReplyToReply,
    required this.onDelete,
    required this.onReact,
    this.onEdit,
    required this.commentsEnabled,
  });

  List<Comment> _getNestedReplies(String parentId) {
    return allComments.where((c) => c.parentCommentId == parentId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CommentItem(
          comment: comment,
          isPostOwner: isPostOwner,
          currentUserId: currentUserId,
          onReply: onReply,
          onDelete: () => onDelete(comment),
          onReact: () => onReact(comment),
          onEdit: onEdit != null ? () => onEdit!(comment) : null,
          indent: 0,
        ),
        if (replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Column(
              children: replies.map((reply) {
                final nestedReplies = _getNestedReplies(reply.id);
                return Column(
                  children: [
                    _CommentItem(
                      comment: reply,
                      isPostOwner: isPostOwner,
                      currentUserId: currentUserId,
                      onReply: onReplyToReply != null ? () => onReplyToReply!(reply) : null,
                      onDelete: () => onDelete(reply),
                      onReact: () => onReact(reply),
                      onEdit: onEdit != null ? () => onEdit!(reply) : null,
                      indent: 1,
                    ),
                    if (nestedReplies.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Column(
                          children: nestedReplies.map((nested) => _CommentItem(
                            comment: nested,
                            isPostOwner: isPostOwner,
                            currentUserId: currentUserId,
                            onReply: null,
                            onDelete: () => onDelete(nested),
                            onReact: () => onReact(nested),
                            onEdit: onEdit != null ? () => onEdit!(nested) : null,
                            indent: 2,
                          )).toList(),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _CommentItem extends StatelessWidget {
  final Comment comment;
  final bool isPostOwner;
  final String currentUserId;
  final VoidCallback? onReply;
  final VoidCallback onDelete;
  final VoidCallback onReact;
  final VoidCallback? onEdit;
  final int indent;

  const _CommentItem({
    required this.comment,
    required this.isPostOwner,
    required this.currentUserId,
    this.onReply,
    required this.onDelete,
    required this.onReact,
    this.onEdit,
    required this.indent,
  });

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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

  @override
  Widget build(BuildContext context) {
    final canDelete = isPostOwner || comment.authorId == currentUserId;
    final reactionStyle = comment.userReaction != null
        ? _reactionStyles[comment.userReaction]
        : null;

    final avatarBg = context.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push('/user/${comment.authorId}'),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: indent == 0 ? 36 : 28,
              height: indent == 0 ? 36 : 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarBg,
                image: comment.authorAvatarUrl != null
                    ? DecorationImage(
                        image: NetworkImage(comment.authorAvatarUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: comment.authorAvatarUrl == null
                  ? Icon(Icons.person, color: context.iconColor, size: indent == 0 ? 18 : 14)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.push('/user/${comment.authorId}'),
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        comment.authorName,
                        style: TextStyle(
                          color: context.onSurface,
                          fontSize: indent == 0 ? 14 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(comment.createdAt),
                      style: TextStyle(
                        color: context.hintColor,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    if (canDelete || (comment.authorId == currentUserId && onEdit != null))
                      Builder(
                        builder: (buttonContext) => GestureDetector(
                          onTap: () async {
                            final navigator = Navigator.of(buttonContext);
                            final RenderBox button = buttonContext.findRenderObject() as RenderBox;
                            final RenderBox overlay = navigator.overlay!.context.findRenderObject() as RenderBox;
                            final RelativeRect position = RelativeRect.fromRect(
                              Rect.fromPoints(
                                button.localToGlobal(Offset.zero, ancestor: overlay),
                                button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
                              ),
                              Offset.zero & overlay.size,
                            );
                            final cardColor = buttonContext.cardColor;
                            final onSurfaceColor = buttonContext.onSurface;
                            
                            FocusManager.instance.primaryFocus?.unfocus();
                            SystemChannels.textInput.invokeMethod('TextInput.hide');
                            
                            await Future.delayed(const Duration(milliseconds: 150));
                            
                            if (!buttonContext.mounted) return;
                            
                            final result = await showMenu<String>(
                              context: buttonContext,
                              position: position,
                              color: cardColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              items: [
                                if (comment.authorId == currentUserId && onEdit != null)
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 16, color: onSurfaceColor),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Edit',
                                          style: TextStyle(color: onSurfaceColor),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (canDelete)
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 16, color: Color(0xFFEF4444)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Delete',
                                          style: TextStyle(color: Color(0xFFEF4444)),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            );
                            
                            if (result == 'delete') {
                              onDelete();
                            } else if (result == 'edit') {
                              onEdit?.call();
                            }
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.more_horiz,
                              color: buttonContext.hintColor,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.isDeleted ? 'Comment deleted' : comment.content,
                  style: TextStyle(
                    color: comment.isDeleted
                        ? context.hintColor
                        : context.onSurface,
                    fontSize: indent == 0 ? 14 : 13,
                    height: 1.4,
                    fontStyle: comment.isDeleted ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
                if (!comment.isDeleted) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: onReact,
                        onLongPress: onReact,
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Row(
                            children: [
                              Icon(
                                reactionStyle?.icon ?? Icons.favorite_border,
                                size: 16,
                                color: reactionStyle != null
                                    ? Color(reactionStyle.color)
                                    : context.subtleIconColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${comment.likesCount}',
                                style: TextStyle(
                                  color: reactionStyle != null
                                      ? Color(reactionStyle.color)
                                      : context.subtleIconColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (onReply != null) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: onReply,
                          behavior: HitTestBehavior.opaque,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Reply',
                              style: TextStyle(
                                color: context.hintColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
