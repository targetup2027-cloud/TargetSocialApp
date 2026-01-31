import '../../domain/entities/post.dart';

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
    return PostModel(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorUsername: json['authorUsername'] as String,
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      authorIsVerified: json['authorIsVerified'] as bool? ?? false,
      content: json['content'] as String?,
      mediaUrls: (json['mediaUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      mediaType: json['mediaType'] as String?,
      likesCount: json['likesCount'] as int? ?? 0,
      commentsCount: json['commentsCount'] as int? ?? 0,
      sharesCount: json['sharesCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
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
    return CommentModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorUsername: json['authorUsername'] as String,
      authorAvatarUrl: json['authorAvatarUrl'] as String?,
      content: json['content'] as String,
      likesCount: json['likesCount'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      parentCommentId: json['parentCommentId'] as String?,
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
