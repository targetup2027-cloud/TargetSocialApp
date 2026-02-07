import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/motion/motion_system.dart';
import '../../../app/theme/uaxis_theme.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../app/i18n/generated/app_localizations.dart';
import '../models/post_data.dart';
import 'reaction_selector.dart';
import 'media_viewer.dart';
import 'video_player_screen.dart';

class PostCard extends StatefulWidget {
  final PostData post;
  final void Function(ReactionType)? onReact;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;
  final VoidCallback? onTapPost;
  final VoidCallback? onMoreOptions;
  final VoidCallback? onAuthorTap;
  final bool isOwner;
  final VoidCallback? onDeleteMedia;
  final VoidCallback? onEditMedia;

  const PostCard({
    super.key,
    required this.post,
    this.onReact,
    this.onComment,
    this.onShare,
    this.onSave,
    this.onTapPost,
    this.onMoreOptions,
    this.onAuthorTap,
    this.isOwner = false,
    this.onDeleteMedia,
    this.onEditMedia,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  ReactionType? _userReaction;
  late bool _isSaved;

  @override
  void initState() {
    super.initState();
    _userReaction = widget.post.userReaction;
    _isSaved = widget.post.isSaved;
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id || 
        oldWidget.post.userReaction != widget.post.userReaction) {
      _userReaction = widget.post.userReaction;
    }
    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.isSaved != widget.post.isSaved) {
      _isSaved = widget.post.isSaved;
    }
  }

  void _handleReaction(ReactionType type) {
    setState(() {
      if (_userReaction == type) {
        _userReaction = null;
      } else {
        _userReaction = type;
      }
    });
    widget.onReact?.call(type);
  }

  void _showReactionSelector() {
    FocusScope.of(context).unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      showReactionSelector(
        context: context,
        onReactionSelected: _handleReaction,
        currentReaction: _userReaction,
      );
    });
  }

  void _handleReactButtonTap() {
    if (_userReaction != null) {
      _handleReaction(_userReaction!);
    } else {
      _showReactionSelector();
    }
  }

  Future<void> _handleShare() async {
    final post = widget.post;
    final shareText = '${post.userName} (@${post.handle})\n\n${post.content}\n\nShared via U-ΛXIS';
    
    try {
      await Share.share(
        shareText,
        subject: 'Post by ${post.userName}',
      );
      widget.onShare?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to share'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          transform: Matrix4.identity()..scale(_isHovered ? 1.005 : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: _isHovered 
                ? context.cardColor.withValues(alpha: 0.95)
                : context.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered 
                  ? const Color(0xFF3B82F6).withValues(alpha: 0.3)
                  : context.dividerColor,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: GestureDetector(
            onTap: widget.onTapPost,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildContent(),
                if (widget.post.type != PostType.text) ...[
                  const SizedBox(height: 12),
                  _buildMedia(),
                ],
                const SizedBox(height: 12),
                _buildReactionBar(l10n),
                const SizedBox(height: 12),
                _buildActionButtons(l10n),
                if (widget.post.topComments.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildCommentPreview(l10n),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final trustScore = widget.post.authorTrustScore;
    final isTopRanked = widget.post.isTopRanked;
    
    Color getTrustColor() {
      if (trustScore >= 90) return const Color(0xFFF59E0B);
      if (trustScore >= 70) return const Color(0xFF10B981);
      if (trustScore >= 40) return const Color(0xFF3B82F6);
      return const Color(0xFF6B7280);
    }
    
    return Row(
      children: [
        GestureDetector(
          onTap: widget.onAuthorTap,
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      isTopRanked ? getTrustColor() : UAxisColors.social,
                      (isTopRanked ? getTrustColor() : UAxisColors.social).withValues(alpha: 0.6),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: 'https://i.pravatar.cc/150?u=${widget.post.handle}',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: context.isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFEEEEEE),
                      child: Icon(
                        Icons.person,
                        color: context.iconColor,
                        size: 20,
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: context.isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFEEEEEE),
                      child: Icon(
                        Icons.person,
                        color: context.iconColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
              if (trustScore >= 70)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: getTrustColor(),
                      border: Border.all(color: context.cardColor, width: 2),
                    ),
                    child: Icon(
                      trustScore >= 90 ? Icons.star : Icons.check,
                      size: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: widget.onAuthorTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.post.userName,
                        style: TextStyle(
                          color: context.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.post.isVerified || trustScore >= 70) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 14,
                        color: getTrustColor(),
                      ),
                    ],
                    if (trustScore >= 70) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: getTrustColor().withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.post.trustTierName,
                          style: TextStyle(
                            color: getTrustColor(),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${widget.post.handle} • ${widget.post.timeAgo}',
                  style: TextStyle(
                    color: context.hintColor,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: widget.onMoreOptions,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              Icons.more_horiz,
              color: context.hintColor,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      widget.post.content,
      style: TextStyle(
        color: context.onSurface,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildMedia() {
    final mediaUrls = widget.post.mediaUrls.isNotEmpty 
        ? widget.post.mediaUrls 
        : (widget.post.mediaUrl != null && widget.post.mediaUrl!.isNotEmpty ? [widget.post.mediaUrl!] : <String>[]);
    
    if (mediaUrls.isEmpty) return const SizedBox.shrink();

    final isVideo = widget.post.type == PostType.video;
    
    // If it's a video, usually it's a single file. 
    if (isVideo) {
      final mediaUrl = mediaUrls.first;
      return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VideoPlayerScreen(
                videoUrl: mediaUrl,
                localPath: mediaUrl.startsWith('/') ? mediaUrl : null,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: VideoThumb(
              videoUrl: mediaUrl,
              postId: widget.post.id,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      videoUrl: mediaUrl,
                      localPath: mediaUrl.startsWith('/') ? mediaUrl : null,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    }

    // Images Grid
    final isSingleImage = mediaUrls.length == 1;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: isSingleImage
          ? ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              child: _buildSingleImage(mediaUrls[0], useCover: false),
            )
          : AspectRatio(
              aspectRatio: 1.0,
              child: _buildImageGrid(mediaUrls),
            ),
    );
  }

  Widget _buildImageGrid(List<String> urls) {
    final count = urls.length;
    if (count == 1) return _buildSingleImage(urls[0]);
    
    if (count == 2) {
      return Row(
        children: [
          Expanded(child: _buildSingleImage(urls[0])),
          const SizedBox(width: 2),
          Expanded(child: _buildSingleImage(urls[1])),
        ],
      );
    }
    
    if (count == 3) {
      return Row(
        children: [
          Expanded(child: _buildSingleImage(urls[0])),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildSingleImage(urls[1])),
                const SizedBox(height: 2),
                Expanded(child: _buildSingleImage(urls[2])),
              ],
            ),
          ),
        ],
      );
    }
    
    // 4 or more
    final extra = count > 4 ? count - 4 : 0;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildSingleImage(urls[0])),
              const SizedBox(width: 2),
              Expanded(child: _buildSingleImage(urls[1])),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildSingleImage(urls[2])),
              const SizedBox(width: 2),
              Expanded(child: _buildSingleImage(urls[3], overlayCount: extra)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleImage(String mediaUrl, {int overlayCount = 0, bool useCover = true}) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MediaViewer(
              mediaUrl: mediaUrl,
              localPath: mediaUrl.startsWith('/') ? mediaUrl : null,
              isOwner: widget.isOwner,
              onDelete: widget.onDeleteMedia,
              onEdit: widget.onEditMedia,
            ),
          ),
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImageWidget(mediaUrl, useCover: useCover),
          if (overlayCount > 0)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: Center(
                child: Text(
                  '+$overlayCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String mediaUrl, {bool useCover = true}) {
    final fit = useCover ? BoxFit.cover : BoxFit.contain;
    
    if (mediaUrl.isEmpty) {
      return Container(
        color: const Color(0xFF2A2A2A),
        child: const Center(
          child: Icon(Icons.image, color: Colors.white38, size: 48),
        ),
      );
    }

    if (mediaUrl.startsWith('/')) {
      return Container(
        color: Colors.black,
        child: Image.file(
          File(mediaUrl),
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFF2A2A2A),
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white38, size: 48),
            ),
          ),
        ),
      );
    }

    return Container(
      color: Colors.black,
      child: CachedNetworkImage(
        imageUrl: mediaUrl,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        memCacheWidth: 400,
        memCacheHeight: 400,
        fadeInDuration: const Duration(milliseconds: 150),
        placeholder: (context, url) => const _ImagePlaceholder(),
        errorWidget: (context, url, error) => const _ImageErrorWidget(),
      ),
    );
  }

  List<PostReaction> _getCurrentReactions() {
    // Controller now properly updates reactionCounts, so we can use the reactions directly
    return widget.post.reactions.where((r) => r.count > 0).toList();
  }

  Widget _buildReactionBar(AppLocalizations l10n) {
    final currentReactions = _getCurrentReactions();

    if (currentReactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedReactions = currentReactions
      ..sort((a, b) => b.count.compareTo(a.count));
    final topReactions = sortedReactions.take(3).toList();

    // Calculate total for display
    final totalReactions = currentReactions.fold(0, (sum, r) => sum + r.count);
    String reactionsText;
    if (totalReactions >= 1000000) {
      reactionsText = '${(totalReactions / 1000000).toStringAsFixed(1)}M';
    } else if (totalReactions >= 1000) {
      reactionsText = '${(totalReactions / 1000).toStringAsFixed(1)}k';
    } else {
      reactionsText = totalReactions.toString();
    }

    // Use a fixed dark border for reactions stack to ensure visibility against overlapping avatars
    // regardless of theme, or match the card background if that's preferred.
    final borderColor = context.cardColor; 

    return Row(
      children: [
        SizedBox(
          width: (topReactions.length * 18.0) + 6,
          height: 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: topReactions.asMap().entries.map((entry) {
              final index = entry.key;
              final reaction = entry.value;
              return Positioned(
                left: index * 18.0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(reaction.color),
                    border: Border.all(
                      color: borderColor,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      reaction.icon,
                      color: Colors.white,
                      size: 11,
                    ),
                  ),
                ),
              );
            }).toList().reversed.toList(),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          reactionsText,
          style: TextStyle(
            color: context.hintColor,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '• ${widget.post.commentsText} ${l10n.comments} • ${widget.post.sharesText} ${l10n.shares}',
            style: TextStyle(
              color: context.hintColor,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    widget.onSave?.call();
    
    if (mounted) {
       ScaffoldMessenger.of(context).clearSnackBars();
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                _isSaved ? 'Post saved' : 'Post unsaved',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF333333),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Widget _buildActionButtons(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: TapScaleButton(
              onTap: _handleReactButtonTap,
              child: GestureDetector(
                onLongPress: _showReactionSelector,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: _userReaction != null
                        ? Color(PostReaction(type: _userReaction!, count: 0).color).withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_userReaction != null) ...[
                        Icon(
                          PostReaction(type: _userReaction!, count: 0).icon,
                          color: Color(PostReaction(type: _userReaction!, count: 0).color),
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            PostReaction(type: _userReaction!, count: 0).label,
                            style: TextStyle(
                              color: Color(PostReaction(type: _userReaction!, count: 0).color),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ] else ...[
                        Icon(
                          Icons.favorite_border_rounded,
                          color: context.subtleIconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l10n.react,
                            style: TextStyle(
                              color: context.subtleIconColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TapScaleButton(
              onTap: widget.onComment,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.transparent, // For hit test
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: context.subtleIconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.comment,
                        style: TextStyle(
                          color: context.subtleIconColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: TapScaleButton(
              onTap: _handleShare,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.transparent, // For hit test
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.share_rounded,
                      color: context.subtleIconColor,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.share,
                        style: TextStyle(
                          color: context.subtleIconColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          TapScaleButton(
            onTap: _handleSave,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                _isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _isSaved ? context.onSurface : context.subtleIconColor,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentPreview(AppLocalizations l10n) {
    final comment = widget.post.topComments.first;
    // Comment background slightly different from card background
    final commentBg = context.isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: commentBg,
            borderRadius: BorderRadius.circular(12),
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
                      shape: BoxShape.circle,
                      color: context.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: 'https://i.pravatar.cc/150?u=${comment.userName}',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: context.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                          child: Icon(
                            Icons.person,
                            color: context.iconColor,
                            size: 14,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: context.isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                          child: Icon(
                            Icons.person,
                            color: context.iconColor,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    comment.userName,
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comment.content,
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 14,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    l10n.like,
                    style: TextStyle(
                      color: context.hintColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '• ${comment.likes}',
                    style: TextStyle(
                      color: context.hintColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.reply,
                    style: TextStyle(
                      color: context.hintColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '• ${comment.timeAgo}',
                    style: TextStyle(
                      color: context.hintColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (widget.post.commentCount > 1) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              '${l10n.viewMoreComments} ${widget.post.commentCount - 1}',
              style: TextStyle(
                color: context.hintColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class VideoThumb extends StatefulWidget {
  final String videoUrl;
  final String postId;
  final VoidCallback? onTap;

  const VideoThumb({
    super.key,
    required this.videoUrl,
    required this.postId,
    this.onTap,
  });

  @override
  State<VideoThumb> createState() => _VideoThumbState();
}

class _VideoThumbState extends State<VideoThumb> {
  static final Map<String, Uint8List> _memoryCache = {};
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  @override
  void didUpdateWidget(VideoThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl || oldWidget.postId != widget.postId) {
      _loadThumbnail();
    }
  }

  Future<void> _loadThumbnail() async {
    if (widget.videoUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    final cacheKey = '${widget.postId}_${widget.videoUrl.hashCode}';

    if (_memoryCache.containsKey(cacheKey)) {
      setState(() {
        _thumbnailBytes = _memoryCache[cacheKey];
        _isLoading = false;
      });
      return;
    }

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final thumbDir = Directory('${appDir.path}/video_thumbs');
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

      // Use isolate for thumbnail generation to avoid UI thread blocking
      final bytes = await _generateThumbnailInIsolate(widget.videoUrl);

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

  static Future<Uint8List?> _generateThumbnailInIsolate(String videoUrl) async {
    // VideoThumbnail already runs in a separate thread internally,
    // but we wrap it to ensure proper async handling
    try {
      return await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 400,  // Reduced for performance
        quality: 50,    // Reduced for faster generation
        timeMs: 0,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isLoading)
            Container(
              color: const Color(0xFF2A2A2A),
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: CircularProgressIndicator(
                  color: UAxisColors.social,
                  strokeWidth: 2,
                ),
              ),
            )
          else if (_hasError || _thumbnailBytes == null)
            Container(
              color: const Color(0xFF2A2A2A),
              width: double.infinity,
              height: double.infinity,
              child: const Center(
                child: Icon(Icons.videocam, color: Colors.white38, size: 48),
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
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.black,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: CircularProgressIndicator(
          color: UAxisColors.social,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

class _ImageErrorWidget extends StatelessWidget {
  const _ImageErrorWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(Icons.broken_image, color: Colors.white38, size: 48),
      ),
    );
  }
}
