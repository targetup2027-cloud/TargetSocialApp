import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../../models/post_data.dart';
import '../datasources/posts_remote_data_source.dart';
import '../datasources/posts_local_data_source.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;
  final PostsLocalDataSource localDataSource;
  final bool useMockData;

  PostsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    this.useMockData = false,
  });

  @override
  Future<List<Post>> getFeed({int page = 1, int limit = 20}) async {
    if (useMockData) {
      return _getMockFeed();
    }
    
    try {
      final posts = await remoteDataSource.getFeed(page: page, limit: limit);
      if (page == 1) {
        await localDataSource.cacheFeed(posts);
      }
      return posts;
    } catch (e) {
      final cachedPosts = await localDataSource.getCachedFeed();
      if (cachedPosts.isNotEmpty) {
        return cachedPosts;
      }
      rethrow;
    }
  }

  @override
  Future<List<Post>> getDiscoverFeed({int page = 1, int limit = 20}) async {
    if (useMockData) {
      return _getMockDiscoverFeed();
    }
    return remoteDataSource.getDiscoverFeed(page: page, limit: limit);
  }

  @override
  Future<List<Post>> getUserPosts(String userId, {int page = 1, int limit = 20}) async {
    if (useMockData) {
      return _getMockUserPosts(userId);
    }
    
    try {
      final posts = await remoteDataSource.getUserPosts(userId, page: page, limit: limit);
      if (page == 1) {
        await localDataSource.cacheUserPosts(userId, posts);
      }
      return posts;
    } catch (e) {
      final cachedPosts = await localDataSource.getCachedUserPosts(userId);
      if (cachedPosts.isNotEmpty) {
        return cachedPosts;
      }
      rethrow;
    }
  }

  @override
  Future<Post> getPostById(String postId) async {
    if (useMockData) {
      return _getMockPost(postId);
    }
    
    try {
      final post = await remoteDataSource.getPostById(postId);
      await localDataSource.cachePost(post);
      return post;
    } catch (e) {
      final cachedPost = await localDataSource.getCachedPost(postId);
      if (cachedPost != null) {
        return cachedPost;
      }
      rethrow;
    }
  }

  @override
  Future<Post> createPost({
    required String content,
    List<String>? mediaUrls,
    String? mediaType,
    String? location,
  }) async {
    if (useMockData) {
      return _createMockPost(content, mediaUrls, mediaType, location);
    }
    
    return remoteDataSource.createPost(
      content: content,
      mediaUrls: mediaUrls,
      mediaType: mediaType,
      location: location,
    );
  }

  @override
  Future<Post> updatePost(String postId, {String? content}) async {
    if (useMockData) {
      final post = _getMockPost(postId);
      return post.copyWith(content: content);
    }
    
    return remoteDataSource.updatePost(postId, content: content);
  }

  @override
  Future<void> deletePost(String postId) async {
    if (useMockData) {
      return;
    }
    
    await remoteDataSource.deletePost(postId);
  }

  @override
  Future<Post> likePost(String postId) async {
    if (useMockData) {
      final post = _getMockPost(postId);
      return post.copyWith(isLiked: true, likesCount: post.likesCount + 1);
    }
    
    return remoteDataSource.likePost(postId);
  }

  @override
  Future<Post> unlikePost(String postId) async {
    if (useMockData) {
      final post = _getMockPost(postId);
      return post.copyWith(isLiked: false, likesCount: post.likesCount - 1);
    }
    
    return remoteDataSource.unlikePost(postId);
  }

  @override
  Future<Post> bookmarkPost(String postId) async {
    await localDataSource.addBookmark(postId);
    
    if (useMockData) {
      final post = _getMockPost(postId);
      return post.copyWith(isBookmarked: true);
    }
    
    return remoteDataSource.bookmarkPost(postId);
  }

  @override
  Future<Post> unbookmarkPost(String postId) async {
    await localDataSource.removeBookmark(postId);
    
    if (useMockData) {
      final post = _getMockPost(postId);
      return post.copyWith(isBookmarked: false);
    }
    
    return remoteDataSource.unbookmarkPost(postId);
  }

  @override
  Future<List<Post>> getBookmarkedPosts({int page = 1, int limit = 20}) async {
    final bookmarkedIds = await localDataSource.getBookmarkedPostIds();
    if (bookmarkedIds.isEmpty) return [];

    final posts = <Post>[];
    for (final id in bookmarkedIds) {
      try {
        final post = await remoteDataSource.getPostById(id);
        posts.add(post.copyWith(isBookmarked: true));
      } catch (_) {}
    }
    return posts;
  }

  @override
  Future<List<Comment>> getComments(String postId, {int page = 1, int limit = 20}) async {
    if (useMockData) {
      return _getMockComments(postId);
    }
    
    return remoteDataSource.getComments(postId, page: page, limit: limit);
  }

  @override
  Future<Comment> addComment(String postId, String content, {String? parentCommentId}) async {
    if (useMockData) {
      return _createMockComment(postId, content, parentCommentId);
    }
    
    return remoteDataSource.addComment(postId, content, parentCommentId: parentCommentId);
  }

  @override
  Future<Comment> updateComment(String postId, String commentId, String content) async {
    if (useMockData) {
      final comments = _getMockComments(postId);
      final comment = comments.firstWhere((c) => c.id == commentId);
      return comment.copyWith(content: content);
    }
    
    return remoteDataSource.updateComment(postId, commentId, content);
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    if (useMockData) {
      return;
    }
    
    await remoteDataSource.deleteComment(postId, commentId);
  }

  @override
  Future<Comment> likeComment(String commentId) async {
    if (useMockData) {
      throw UnimplementedError();
    }
    
    return remoteDataSource.likeComment(commentId);
  }

  @override
  Future<Comment> unlikeComment(String commentId) async {
    if (useMockData) {
      throw UnimplementedError();
    }
    
    return remoteDataSource.unlikeComment(commentId);
  }

  @override
  Future<void> sharePost(String postId) async {
    if (useMockData) {
      return;
    }
    
    await remoteDataSource.sharePost(postId);
  }

  @override
  Future<List<Post>> searchPosts(String query, {int page = 1, int limit = 20}) async {
    if (useMockData) {
      final feed = _getMockFeed();
      return feed.where((p) => 
        (p.content?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
        p.hashtags.any((h) => h.toLowerCase().contains(query.toLowerCase()))
      ).toList();
    }
    
    return remoteDataSource.searchPosts(query, page: page, limit: limit);
  }

  @override
  Future<List<Post>> getPostsByHashtag(String hashtag, {int page = 1, int limit = 20}) async {
    if (useMockData) {
      final feed = _getMockFeed();
      return feed.where((p) => p.hashtags.contains(hashtag)).toList();
    }
    
    return remoteDataSource.getPostsByHashtag(hashtag, page: page, limit: limit);
  }

  @override
  Future<void> incrementViews(String postId) async {
    if (useMockData) {
      // In mock mode, just no-op
      return;
    }
    
    await remoteDataSource.incrementViews(postId);
  }

  @override
  Future<Post> reactToPost(String postId, ReactionType type) async {
    if (useMockData) {
      final post = _getMockPost(postId);
      final newCounts = Map<ReactionType, int>.from(post.reactionCounts);
      newCounts[type] = (newCounts[type] ?? 0) + 1;
      return post.copyWith(
        userReaction: type,
        reactionCounts: newCounts,
      );
    }
    
    return remoteDataSource.reactToPost(postId, type);
  }

  @override
  Future<Post> removeReaction(String postId) async {
    if (useMockData) {
      final post = _getMockPost(postId);
      return post.copyWith(clearUserReaction: true);
    }
    
    return remoteDataSource.removeReaction(postId);
  }

  List<Post> _getMockFeed() {
    return [
      Post(
        id: '1',
        authorId: 'user1',
        authorName: 'Layla Ahmed',
        authorUsername: 'layla_design',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        authorIsVerified: true,
        content: 'Just finished this UI kit for chat apps! The emerald color palette gives it such a fresh vibe 💚✨ What do you think? #UIDesign #ChatUI #DesignSystem',
        mediaUrls: ['https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=800'],
        mediaType: 'image',
        likesCount: 847,
        reactionCounts: {
          ReactionType.love: 523,
          ReactionType.like: 201,
          ReactionType.fire: 89,
          ReactionType.inspire: 34,
        },
        commentsCount: 92,
        sharesCount: 156,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        hashtags: ['UIDesign', 'ChatUI', 'DesignSystem'],
      ),
      Post(
        id: '2',
        authorId: 'user2',
        authorName: 'Omar Hassan',
        authorUsername: 'omar_tech',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
        content: 'The secret to smooth page transitions in Flutter? Use easeOutCubic curves and keep duration under 300ms. Your users will thank you! 🚀\n\n#FlutterDev #MobileUI #Animations',
        likesCount: 423,
        reactionCounts: {
          ReactionType.like: 245,
          ReactionType.inspire: 112,
          ReactionType.boost: 66,
        },
        commentsCount: 67,
        sharesCount: 89,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        hashtags: ['FlutterDev', 'MobileUI', 'Animations'],
      ),
      Post(
        id: '3',
        authorId: 'user3',
        authorName: 'Sara Mahmoud',
        authorUsername: 'sara_flutter',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        authorIsVerified: true,
        content: 'Day 100 of coding in Flutter! 🎉\n\nWhat I learned:\n• State management matters\n• UI/UX consistency is key\n• Community is everything\n\nThank you all for the support! 💜',
        mediaUrls: ['https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=800'],
        mediaType: 'image',
        likesCount: 1256,
        reactionCounts: {
          ReactionType.love: 678,
          ReactionType.fire: 312,
          ReactionType.inspire: 189,
          ReactionType.like: 77,
        },
        commentsCount: 234,
        sharesCount: 89,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        hashtags: ['Flutter', '100DaysOfCode'],
      ),
      Post(
        id: '4',
        authorId: 'currentUser',
        authorName: 'Yazan Al-Rashid',
        authorUsername: 'yazan_codes',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        authorIsVerified: true,
        content: 'U-AXIS just got a major UI upgrade! 🔥\n\n✅ Smooth page transitions\n✅ New chat bubble design\n✅ Emerald theme for messages\n✅ Shimmer loading states\n\nMore updates coming soon! Stay tuned 🚀',
        likesCount: 678,
        reactionCounts: {
          ReactionType.fire: 345,
          ReactionType.love: 198,
          ReactionType.boost: 89,
          ReactionType.like: 46,
        },
        commentsCount: 145,
        sharesCount: 234,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        hashtags: ['UAXIS', 'Flutter', 'AppUpdate'],
      ),
      Post(
        id: '5',
        authorId: 'user4',
        authorName: 'Ahmed Khaled',
        authorUsername: 'ahmed_dev',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
        content: 'Coffee + code = productivity ☕💻\n\nWorking on some exciting features today. Can\'t wait to share!',
        mediaUrls: ['https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=800'],
        mediaType: 'image',
        likesCount: 312,
        reactionCounts: {
          ReactionType.like: 178,
          ReactionType.love: 89,
          ReactionType.fire: 45,
        },
        commentsCount: 28,
        sharesCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        location: 'Dubai, UAE',
      ),
    ];
  }

  List<Post> _getMockDiscoverFeed() {
    return [
      Post(
        id: '6',
        authorId: 'user5',
        authorName: 'Nour Ali',
        authorUsername: 'nour_pm',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
        authorIsVerified: true,
        content: '5 Product Management lessons I wish I knew earlier:\n\n1. Listen more than you speak\n2. Data tells stories\n3. Users don\'t always know what they want\n4. Ship fast, iterate faster\n5. Collaboration > Competition\n\n#ProductManagement #Startups',
        likesCount: 2341,
        reactionCounts: {
          ReactionType.inspire: 1245,
          ReactionType.love: 678,
          ReactionType.like: 312,
          ReactionType.boost: 106,
        },
        commentsCount: 312,
        sharesCount: 567,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        hashtags: ['ProductManagement', 'Startups', 'Leadership'],
      ),
      Post(
        id: '7',
        authorId: 'user6',
        authorName: 'Maya Ibrahim',
        authorUsername: 'maya_ui',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
        content: 'Design systems are like gardens 🌸\n\nYou plant the seeds (tokens), nurture them (components), and watch them bloom (beautiful UIs).\n\nTake care of your design system!',
        mediaUrls: ['https://images.unsplash.com/photo-1561070791-2526d30994b5?w=800'],
        mediaType: 'image',
        likesCount: 892,
        reactionCounts: {
          ReactionType.love: 456,
          ReactionType.inspire: 234,
          ReactionType.like: 145,
          ReactionType.fire: 57,
        },
        commentsCount: 76,
        sharesCount: 145,
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
        hashtags: ['DesignSystem', 'UXDesign'],
      ),
    ];
  }

  List<Post> _getMockUserPosts(String userId) {
    final allPosts = [..._getMockFeed(), ..._getMockDiscoverFeed()];
    final userPosts = allPosts.where((p) => p.authorId == userId).toList();
    if (userPosts.isEmpty && userId == 'currentUser') {
      return [_getMockFeed()[3]];
    }
    return userPosts.isNotEmpty ? userPosts : [_getMockFeed().first];
  }

  Post _getMockPost(String postId) {
    final allPosts = [..._getMockFeed(), ..._getMockDiscoverFeed()];
    return allPosts.firstWhere(
      (p) => p.id == postId,
      orElse: () => _getMockFeed().first,
    );
  }

  Post _createMockPost(String content, List<String>? mediaUrls, String? mediaType, String? location) {
    return Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: 'currentUser',
      authorName: 'Yazan Al-Rashid',
      authorUsername: 'yazan_codes',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      authorIsVerified: true,
      content: content,
      mediaUrls: mediaUrls ?? [],
      mediaType: mediaType,
      location: location,
      createdAt: DateTime.now(),
    );
  }

  List<Comment> _getMockComments(String postId) {
    return [
      Comment(
        id: 'c1',
        postId: postId,
        authorId: 'user1',
        authorName: 'Layla Ahmed',
        authorUsername: 'layla_design',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
        content: 'This is incredible! The attention to detail is amazing 🔥👏',
        likesCount: 45,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Comment(
        id: 'c2',
        postId: postId,
        authorId: 'user2',
        authorName: 'Omar Hassan',
        authorUsername: 'omar_tech',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
        content: 'The transitions are so smooth! What animation library did you use?',
        likesCount: 23,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Comment(
        id: 'c3',
        postId: postId,
        authorId: 'user3',
        authorName: 'Sara Mahmoud',
        authorUsername: 'sara_flutter',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
        content: 'Love the emerald color scheme! Very refreshing 💚',
        likesCount: 18,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  Comment _createMockComment(String postId, String content, String? parentCommentId) {
    return Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      authorId: 'currentUser',
      authorName: 'Yazan Al-Rashid',
      authorUsername: 'yazan_codes',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      content: content,
      createdAt: DateTime.now(),
      parentCommentId: parentCommentId,
    );
  }
}
