import '../../models/post_data.dart';

class Post {
  final String id;
  final String authorId;
  final String authorName;
  final String authorUsername;
  final String? authorAvatarUrl;
  final bool authorIsVerified;
  final int authorTrustScore;
  final String? content;
  final List<String> mediaUrls;
  final String? mediaType;
  final int likesCount;
  final int viewsCount;
  final Map<ReactionType, int> reactionCounts;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final ReactionType? userReaction;
  final bool isBookmarked;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? location;
  final List<String> hashtags;
  final List<String> mentions;
  final PostVisibility visibility;
  final List<PostMedia> media;
  final bool commentsEnabled;

  const Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorUsername,
    this.authorAvatarUrl,
    this.authorIsVerified = false,
    this.authorTrustScore = 0,
    this.content,
    this.mediaUrls = const [],
    this.mediaType,
    this.likesCount = 0,
    this.viewsCount = 0,
    this.reactionCounts = const {},
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.userReaction,
    this.isBookmarked = false,
    required this.createdAt,
    this.updatedAt,
    this.location,
    this.hashtags = const [],
    this.mentions = const [],
    this.visibility = PostVisibility.public,
    this.media = const [],
    this.commentsEnabled = true,
  });

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorUsername,
    String? authorAvatarUrl,
    bool? authorIsVerified,
    int? authorTrustScore,
    String? content,
    List<String>? mediaUrls,
    String? mediaType,
    int? likesCount,
    int? viewsCount,
    Map<ReactionType, int>? reactionCounts,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    ReactionType? userReaction,
    bool clearUserReaction = false,
    bool? isBookmarked,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? location,
    List<String>? hashtags,
    List<String>? mentions,
    PostVisibility? visibility,
    List<PostMedia>? media,
    bool? commentsEnabled,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorUsername: authorUsername ?? this.authorUsername,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      authorIsVerified: authorIsVerified ?? this.authorIsVerified,
      authorTrustScore: authorTrustScore ?? this.authorTrustScore,
      content: content ?? this.content,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      mediaType: mediaType ?? this.mediaType,
      likesCount: likesCount ?? this.likesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      reactionCounts: reactionCounts ?? this.reactionCounts,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      userReaction: clearUserReaction ? null : (userReaction ?? this.userReaction),
      isBookmarked: isBookmarked ?? this.isBookmarked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      visibility: visibility ?? this.visibility,
      media: media ?? this.media,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
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
  final bool isDeleted;
  final ReactionType? userReaction;
  final Map<ReactionType, int> reactionCounts;

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
    this.isDeleted = false,
    this.userReaction,
    this.reactionCounts = const {},
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
    bool? isDeleted,
    ReactionType? userReaction,
    bool clearUserReaction = false,
    Map<ReactionType, int>? reactionCounts,
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
      isDeleted: isDeleted ?? this.isDeleted,
      userReaction: clearUserReaction ? null : (userReaction ?? this.userReaction),
      reactionCounts: reactionCounts ?? this.reactionCounts,
    );
  }
}
