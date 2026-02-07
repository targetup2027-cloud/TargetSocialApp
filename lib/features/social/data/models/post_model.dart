import '../../domain/entities/post.dart';

import '../../models/post_data.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.authorId,
    required super.authorName,
    required super.authorUsername,
    super.authorAvatarUrl,
    super.authorIsVerified,
    super.content,
    super.mediaUrls,
    super.mediaType,
    super.likesCount,
    super.reactionCounts,
    super.commentsCount,
    super.sharesCount,
    super.isLiked,
    super.isBookmarked,
    required super.createdAt,
    super.updatedAt,
    super.location,
    super.hashtags,
    super.mentions,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final mediaList = json['media'] as List<dynamic>? ?? [];
    final mediaUrls = mediaList
        .map((m) => (m as Map<String, dynamic>)['url'] as String? ?? '')
        .where((url) => url.isNotEmpty)
        .toList();

    String? mediaType;
    if (mediaList.isNotEmpty) {
      final firstMedia = mediaList.first as Map<String, dynamic>;
      final type = firstMedia['mediaType'];
      if (type == 0 || type == 'image') {
        mediaType = 'image';
      } else if (type == 1 || type == 'video') {
        mediaType = 'video';
      }
    }

    final userName = json['userName'] as String? ?? '';

    return PostModel(
      id: json['id'].toString(),
      authorId: (json['userId'] ?? json['authorId'] ?? '').toString(),
      authorName: userName,
      authorUsername: userName.toLowerCase().replaceAll(' ', '_'),
      authorAvatarUrl: json['userAvatarUrl'] as String? ?? json['authorAvatarUrl'] as String?,
      authorIsVerified: json['authorIsVerified'] as bool? ?? false,
      content: json['content'] as String?,
      mediaUrls: mediaUrls,
      mediaType: mediaType,
      likesCount: json['reactionsCount'] as int? ?? json['likesCount'] as int? ?? 0,
      reactionCounts: (json['reactionCounts'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(
              ReactionType.values.firstWhere(
                (e) => e.name == k,
                orElse: () => ReactionType.like,
              ),
              v as int,
            ),
          ) ??
          {},
      commentsCount: json['commentsCount'] as int? ?? 0,
      sharesCount: json['sharesCount'] as int? ?? 0,
      isLiked: json['isLikedByCurrentUser'] as bool? ?? json['isLiked'] as bool? ?? false,
      isBookmarked: json['isSavedByCurrentUser'] as bool? ?? json['isBookmarked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
      location: json['location'] as String?,
      hashtags: (json['hashtags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      mentions: (json['mentions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatarUrl': authorAvatarUrl,
      'authorIsVerified': authorIsVerified,
      'content': content,
      'mediaUrls': mediaUrls,
      'mediaType': mediaType,
      'likesCount': likesCount,
      'reactionCounts': reactionCounts.map((k, v) => MapEntry(k.name, v)),
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'isLiked': isLiked,
      'isBookmarked': isBookmarked,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'location': location,
      'hashtags': hashtags,
      'mentions': mentions,
    };
  }
}

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.postId,
    required super.authorId,
    required super.authorName,
    required super.authorUsername,
    super.authorAvatarUrl,
    required super.content,
    super.likesCount,
    super.isLiked,
    required super.createdAt,
    super.parentCommentId,
    super.repliesCount,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final userName = json['userName'] as String? ?? json['authorName'] as String? ?? '';

    return CommentModel(
      id: json['id'].toString(),
      postId: (json['postId'] ?? '').toString(),
      authorId: (json['userId'] ?? json['authorId'] ?? '').toString(),
      authorName: userName,
      authorUsername: userName.toLowerCase().replaceAll(' ', '_'),
      authorAvatarUrl: json['userAvatarUrl'] as String? ?? json['authorAvatarUrl'] as String?,
      content: json['content'] as String? ?? '',
      likesCount: json['reactionsCount'] as int? ?? json['likesCount'] as int? ?? 0,
      isLiked: json['isLikedByCurrentUser'] as bool? ?? json['isLiked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      parentCommentId: json['parentCommentId']?.toString(),
      repliesCount: json['repliesCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorAvatarUrl': authorAvatarUrl,
      'content': content,
      'likesCount': likesCount,
      'isLiked': isLiked,
      'createdAt': createdAt.toIso8601String(),
      'parentCommentId': parentCommentId,
      'repliesCount': repliesCount,
    };
  }
}
