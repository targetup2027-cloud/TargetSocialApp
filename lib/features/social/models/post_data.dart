import 'package:flutter/material.dart';
import '../domain/entities/post.dart';

enum PostType { text, image, video }

enum ReactionType { love, like, fire, inspire, boost }

enum PostVisibility { public, friends, onlyMe }

enum MediaType { image, video }

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

class PostMedia {
  final String id;
  final MediaType type;
  final String localPath;
  final String? remoteUrl;
  final int? width;
  final int? height;
  final int? durationMs;

  const PostMedia({
    required this.id,
    required this.type,
    required this.localPath,
    this.remoteUrl,
    this.width,
    this.height,
    this.durationMs,
  });

  PostMedia copyWith({
    String? id,
    MediaType? type,
    String? localPath,
    String? remoteUrl,
    int? width,
    int? height,
    int? durationMs,
  }) {
    return PostMedia(
      id: id ?? this.id,
      type: type ?? this.type,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: durationMs ?? this.durationMs,
    );
  }
}

class CommentReaction {
  final String commentId;
  final String userId;
  final ReactionType type;

  const CommentReaction({
    required this.commentId,
    required this.userId,
    required this.type,
  });

  CommentReaction copyWith({
    String? commentId,
    String? userId,
    ReactionType? type,
  }) {
    return CommentReaction(
      commentId: commentId ?? this.commentId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
    );
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
  final String authorId;
  final String userName;
  final String userAvatar;
  final String handle;
  final String timeAgo;
  final bool isVerified;
  final int authorTrustScore;
  final String content;
  final PostType type;
  final String? mediaUrl;
  final List<String> mediaUrls;
  final List<PostReaction> reactions;
  final int commentCount;
  final int shareCount;
  final List<PostComment> topComments;
  final ReactionType? userReaction;
  final bool isSaved;

  const PostData({
    required this.id,
    required this.authorId,
    required this.userName,
    required this.userAvatar,
    required this.handle,
    required this.timeAgo,
    required this.isVerified,
    this.authorTrustScore = 0,
    required this.content,
    required this.type,
    this.mediaUrl,
    this.mediaUrls = const [],
    required this.reactions,
    required this.commentCount,
    required this.shareCount,
    required this.topComments,
    this.userReaction,
    this.isSaved = false,
  });

  bool get isTopRanked => authorTrustScore >= 70;
  
  String get trustTierName {
    if (authorTrustScore >= 90) return 'Elite';
    if (authorTrustScore >= 70) return 'Verified';
    if (authorTrustScore >= 40) return 'Trusted';
    return 'New';
  }

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

  PostData copyWith({
    String? id,
    String? userName,
    String? userAvatar,
    String? handle,
    String? timeAgo,
    bool? isVerified,
    int? authorTrustScore,
    String? content,
    PostType? type,
    String? mediaUrl,
    List<String>? mediaUrls,
    List<PostReaction>? reactions,
    int? commentCount,
    int? shareCount,
    List<PostComment>? topComments,
    ReactionType? userReaction,
    bool? clearUserReaction,
    bool? isSaved,
  }) {
    return PostData(
      id: id ?? this.id,
      authorId: authorId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      handle: handle ?? this.handle,
      timeAgo: timeAgo ?? this.timeAgo,
      isVerified: isVerified ?? this.isVerified,
      authorTrustScore: authorTrustScore ?? this.authorTrustScore,
      content: content ?? this.content,
      type: type ?? this.type,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      reactions: reactions ?? this.reactions,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      topComments: topComments ?? this.topComments,
      userReaction: clearUserReaction == true ? null : (userReaction ?? this.userReaction),
      isSaved: isSaved ?? this.isSaved,
    );
  }

  static String formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  factory PostData.fromPost(Post post) {
    final reactions = <PostReaction>[];
    
    for (final entry in post.reactionCounts.entries) {
      if (entry.value > 0) {
        reactions.add(PostReaction(type: entry.key, count: entry.value));
      }
    }
    
    if (reactions.isEmpty && post.likesCount > 0) {
      reactions.add(PostReaction(type: ReactionType.like, count: post.likesCount));
    }

    PostType type = PostType.text;
    if (post.mediaType == 'video') {
      type = PostType.video;
    } else if (post.mediaUrls.isNotEmpty) {
      type = PostType.image;
    }

    return PostData(
      id: post.id,
      authorId: post.authorId,
      userName: post.authorName,
      userAvatar: post.authorAvatarUrl ?? '',
      handle: post.authorUsername,
      timeAgo: formatTimeAgo(post.createdAt),
      isVerified: post.authorIsVerified,
      authorTrustScore: post.authorTrustScore,
      content: post.content ?? '',
      type: type,
      mediaUrl: post.mediaUrls.isNotEmpty ? post.mediaUrls.first : null,
      mediaUrls: post.mediaUrls,
      reactions: reactions,
      commentCount: post.commentsCount,
      shareCount: post.sharesCount,
      topComments: [],
      userReaction: post.userReaction,
      isSaved: post.isBookmarked,
    );
  }
}
