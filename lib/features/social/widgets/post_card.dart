import 'package:flutter/material.dart';
import '../../../core/motion/motion_system.dart';
import '../../../app/theme/uaxis_theme.dart';
import '../models/post_data.dart';
import 'reaction_selector.dart';

class PostCard extends StatefulWidget {
  final PostData post;
  final VoidCallback? onReact;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onSave;

  const PostCard({
    super.key,
    required this.post,
    this.onReact,
    this.onComment,
    this.onShare,
    this.onSave,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  ReactionType? _userReaction;

  @override
  void initState() {
    super.initState();
    _userReaction = widget.post.userReaction;
  }

  void _handleReaction(ReactionType type) {
    setState(() {
      if (_userReaction == type) {
        _userReaction = null;
      } else {
        _userReaction = type;
      }
    });
    widget.onReact?.call();
  }

  void _showReactionSelector() {
    showReactionSelector(
      context: context,
      onReactionSelected: _handleReaction,
      currentReaction: _userReaction,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
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
          _buildReactionBar(),
          const SizedBox(height: 12),
          _buildActionButtons(),
          if (widget.post.topComments.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildCommentPreview(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                UAxisColors.social,
                UAxisColors.social.withValues(alpha: 0.6),
              ],
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: ClipOval(
            child: Image.network(
              'https://i.pravatar.cc/150?u=${widget.post.handle}',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF1A1A1A),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.post.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.post.isVerified) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: UAxisColors.social,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 10,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                '${widget.post.handle} • ${widget.post.timeAgo}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.more_horiz,
          color: Colors.white.withValues(alpha: 0.5),
          size: 20,
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Text(
      widget.post.content,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 15,
        height: 1.4,
      ),
    );
  }

  Widget _buildMedia() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: widget.post.type == PostType.video
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    'https://picsum.photos/seed/${widget.post.id}video/800/450',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2A2A2A)),
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
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '2:45',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )
            : Image.network(
                'https://picsum.photos/seed/${widget.post.id}/800/450',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2A2A2A)),
              ),
      ),
    );
  }

  Widget _buildReactionBar() {
    if (widget.post.reactions.isEmpty) {
      return const SizedBox.shrink();
    }

    final topReactions = widget.post.reactions.take(3).toList();

    return Row(
      children: [
        SizedBox(
          width: (topReactions.length * 14.0) + 6,
          height: 20,
          child: Stack(
            clipBehavior: Clip.none,
            children: topReactions.asMap().entries.map((entry) {
              final index = entry.key;
              final reaction = entry.value;
              return Positioned(
                left: index * 14.0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(reaction.color),
                    border: Border.all(
                      color: const Color(0xFF0A0A0A),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      reaction.icon,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.post.reactionsText,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            '• ${widget.post.commentsText} comments • ${widget.post.sharesText} shares',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: TapScaleButton(
            onTap: _userReaction != null ? () => _handleReaction(_userReaction!) : _showReactionSelector,
            child: GestureDetector(
              onLongPress: _showReactionSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _userReaction != null
                      ? Color(PostReaction(type: _userReaction!, count: 0).color).withValues(alpha: 0.15)
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
                        Icons.favorite_border,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'React',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
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
        const SizedBox(width: 8),
        Expanded(
          child: TapScaleButton(
            onTap: widget.onComment,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Comment',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TapScaleButton(
            onTap: widget.onShare,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.share_outlined,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Share',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        TapScaleButton(
          onTap: widget.onSave,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Icon(
              Icons.bookmark_border,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentPreview() {
    final comment = widget.post.topComments.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF121212),
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
                      color: const Color(0xFF2A2A2A),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://i.pravatar.cc/150?u=${comment.userName}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFF2A2A2A),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    comment.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                comment.content,
                style: const TextStyle(
                  color: Colors.white,
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
                    'Like',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '• ${comment.likes}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Reply',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '• ${comment.timeAgo}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
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
              'View ${widget.post.commentCount - 1} more comments',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
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
