import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
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

  List<Post> _getMockFeed() {
    return [
      Post(
        id: '1',
        authorId: 'user1',
        authorName: 'Sarah Johnson',
        authorUsername: 'sarahj',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1494790108755-cbb6b1809933?w=150',
        authorIsVerified: true,
        content: 'Just launched my new photography portfolio! Check it out and let me know what you think 📸✨ #photography #creative #portfolio',
        mediaUrls: ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800'],
        mediaType: 'image',
        likesCount: 234,
        commentsCount: 45,
        sharesCount: 12,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        hashtags: ['photography', 'creative', 'portfolio'],
      ),
      Post(
        id: '2',
        authorId: 'user2',
        authorName: 'Tech Insider',
        authorUsername: 'techinsider',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        authorIsVerified: true,
        content: 'AI is transforming the way we work. Here are 5 tools every developer should know about in 2024 🤖💻',
        likesCount: 892,
        commentsCount: 156,
        sharesCount: 89,
        isLiked: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        hashtags: ['AI', 'technology', 'developers'],
      ),
      Post(
        id: '3',
        authorId: 'user3',
        authorName: 'Alex Rivera',
        authorUsername: 'alexr',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        content: 'Morning coffee and productivity ☕ What\'s your morning routine?',
        mediaUrls: ['https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800'],
        mediaType: 'image',
        likesCount: 156,
        commentsCount: 34,
        sharesCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        location: 'San Francisco, CA',
      ),
    ];
  }

  List<Post> _getMockDiscoverFeed() {
    return [
      Post(
        id: '4',
        authorId: 'user4',
        authorName: 'Travel Diaries',
        authorUsername: 'traveldiaries',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        authorIsVerified: true,
        content: 'Exploring the hidden gems of Bali 🌴🌊 This island never ceases to amaze me!',
        mediaUrls: ['https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=800'],
        mediaType: 'image',
        likesCount: 1203,
        commentsCount: 89,
        sharesCount: 234,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        hashtags: ['travel', 'bali', 'adventure'],
        location: 'Bali, Indonesia',
      ),
    ];
  }

  List<Post> _getMockUserPosts(String userId) {
    return _getMockFeed().where((p) => p.authorId == userId).toList();
  }

  Post _getMockPost(String postId) {
    return _getMockFeed().firstWhere(
      (p) => p.id == postId,
      orElse: () => _getMockFeed().first,
    );
  }

  Post _createMockPost(String content, List<String>? mediaUrls, String? mediaType, String? location) {
    return Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: 'currentUser',
      authorName: 'You',
      authorUsername: 'you',
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
        authorId: 'user5',
        authorName: 'Mike Chen',
        authorUsername: 'mikec',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        content: 'This is amazing! Love the composition 👏',
        likesCount: 12,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      Comment(
        id: 'c2',
        postId: postId,
        authorId: 'user6',
        authorName: 'Emily Davis',
        authorUsername: 'emilyd',
        content: 'Where was this taken? It\'s beautiful!',
        likesCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  Comment _createMockComment(String postId, String content, String? parentCommentId) {
    return Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      authorId: 'currentUser',
      authorName: 'You',
      authorUsername: 'you',
      content: content,
      createdAt: DateTime.now(),
      parentCommentId: parentCommentId,
    );
  }
}
