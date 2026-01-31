import 'package:flutter/material.dart';

enum PostType { text, image, video }

enum ReactionType { love, like, fire, inspire, boost }

class PostReaction {
  final ReactionType type;
  final int count;

  const PostReaction({
    required this.type,
    required this.count,
  });

  IconData get icon {
    switch (type) {
      case ReactionType.love:
        return Icons.favorite;
      case ReactionType.like:
        return Icons.thumb_up;
      case ReactionType.fire:
        return Icons.local_fire_department;
      case ReactionType.inspire:
        return Icons.auto_awesome;
      case ReactionType.boost:
        return Icons.bolt;
    }
  }

  int get color {
    switch (type) {
      case ReactionType.love:
        return 0xFFEF4444;
      case ReactionType.like:
        return 0xFF3B82F6;
      case ReactionType.fire:
        return 0xFFF97316;
      case ReactionType.inspire:
        return 0xFFA855F7;
      case ReactionType.boost:
        return 0xFFEAB308;
    }
  }

  String get label {
    switch (type) {
      case ReactionType.love:
        return 'Love';
      case ReactionType.like:
        return 'Like';
      case ReactionType.fire:
        return 'Fire';
      case ReactionType.inspire:
        return 'Inspire';
      case ReactionType.boost:
        return 'Boost';
    }
  }
}

class PostComment {
  final String userName;
  final String userAvatar;
  final String content;
  final int likes;
  final String timeAgo;

  const PostComment({
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.likes,
    required this.timeAgo,
  });
}

class PostData {
  final String id;
  final String userName;
  final String userAvatar;
  final String handle;
  final String timeAgo;
  final bool isVerified;
  final String content;
  final PostType type;
  final String? mediaUrl;
  final List<PostReaction> reactions;
  final int commentCount;
  final int shareCount;
  final List<PostComment> topComments;
  final ReactionType? userReaction;

  const PostData({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.handle,
    required this.timeAgo,
    required this.isVerified,
    required this.content,
    required this.type,
    this.mediaUrl,
    required this.reactions,
    required this.commentCount,
    required this.shareCount,
    required this.topComments,
    this.userReaction,
  });

  int get totalReactions {
    return reactions.fold(0, (sum, reaction) => sum + reaction.count);
  }

  String get reactionsText {
    if (totalReactions >= 1000000) {
      return '${(totalReactions / 1000000).toStringAsFixed(1)}M';
    } else if (totalReactions >= 1000) {
      return '${(totalReactions / 1000).toStringAsFixed(1)}k';
    }
    return totalReactions.toString();
  }

  String get commentsText {
    if (commentCount >= 1000) {
      return '${(commentCount / 1000).toStringAsFixed(0)}k';
    }
    return commentCount.toString();
  }

  String get sharesText {
    if (shareCount >= 1000) {
      return '${(shareCount / 1000).toStringAsFixed(0)}k';
    }
    return shareCount.toString();
  }
}
