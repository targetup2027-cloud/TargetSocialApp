class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final bool authorIsVerified;
  final String? content;
  final List<String> mediaUrls;
  final String? mediaType;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isBookmarked;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? location;
  final List<String> hashtags;
  final List<String> mentions;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    this.authorIsVerified = false,
    this.content,
    this.mediaUrls = const [],
    this.mediaType,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.isBookmarked = false,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.hashtags = const [],
    this.mentions = const [],
  });

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorUsername,
    String? authorAvatarUrl,
    bool? authorIsVerified,
    String? content,
    List<String>? mediaUrls,
    String? mediaType,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    bool? isBookmarked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    List<String>? hashtags,
    List<String>? mentions,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      authorIsVerified: authorIsVerified ?? this.authorIsVerified,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
    );
  }
}

class Comment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String content;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;
  final String? parentCommentId;
  final int repliesCount;

  const Comment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.content,
    this.likesCount = 0,
    this.isLiked = false,
    required this.createdAt,
    this.parentCommentId,
    this.repliesCount = 0,
  });

  Comment copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorUsername,
    String? authorAvatarUrl,
    String? content,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
    String? parentCommentId,
    int? repliesCount,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      repliesCount: repliesCount ?? this.repliesCount,
    );
  }
}
