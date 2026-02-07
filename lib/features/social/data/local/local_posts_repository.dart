import 'dart:async';
import 'dart:math';

import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../../models/post_data.dart';


class LocalPostsRepository implements PostsRepository {
  static final LocalPostsRepository instance = LocalPostsRepository._internal();
  
  factory LocalPostsRepository() => instance;
  
  final List<Post> _posts = [];
  final Map<String, List<Comment>> _comments = {};
  final Set<String> _viewedPostIds = {}; // Track viewed posts to avoid duplicate counts

  LocalPostsRepository._internal() {
    _seedData();
  }

  void _seedData() {
    _posts.addAll([
      Post(
        id: '0',
        authorId: 'user0',
        authorName: 'Trending Post',
        authorUsername: 'trendingpost',
        authorAvatarUrl: 'https://i.pravatar.cc/150?u=0',
        authorIsVerified: true,
        authorTrustScore: 95,
        content: '🔥 This post has ALL reaction types! Check them out above 👆',
        likesCount: 0,
        viewsCount: 24,
        reactionCounts: {
          ReactionType.love: 5,
          ReactionType.like: 3,
          ReactionType.fire: 2,
        },
        commentsCount: 0,
        sharesCount: 2,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        hashtags: ['trending', 'reactions', 'test'],
      ),
      Post(
        id: '1',
        authorId: 'user1',
        authorName: 'Sara Mahmoud',
        authorUsername: 'sara_flutter',
        authorAvatarUrl: 'https://i.pravatar.cc/150?u=1',
        authorIsVerified: true,
        content: 'Just launched my new photography portfolio! Check it out and let me know what you think 📸✨ #photography #creative #portfolio',
        mediaUrls: ['https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800'],
        mediaType: 'image',
        likesCount: 0,
        viewsCount: 12,
        commentsCount: 2,
        sharesCount: 1,
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
        likesCount: 0,
        viewsCount: 56,
        commentsCount: 0,
        sharesCount: 8,
        isLiked: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        hashtags: ['AI', 'technology', 'developers'],
      ),
      Post(
        id: '3',
        authorId: 'currentUser',
        authorName: 'John Doe',
        authorUsername: 'johndoe',
        authorAvatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
        content: 'Morning coffee and productivity ☕ What\'s your morning routine?',
        mediaUrls: ['https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800'],
        mediaType: 'image',
        likesCount: 0,
        viewsCount: 8,
        commentsCount: 0,
        sharesCount: 0,
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        location: 'Cairo, Egypt',
      ),
    ]);

    _comments['1'] = [
      Comment(
        id: 'c1',
        postId: '1',
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
        postId: '1',
        authorId: 'user6',
        authorName: 'Emily Davis',
        authorUsername: 'emilyd',
        content: 'Where was this taken? It\'s beautiful!',
        likesCount: 5,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];
  }

  Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(500)));
  }

  @override
  Future<List<Post>> getFeed({int page = 1, int limit = 20}) async {
    await _delay();
    // Simple pagination
    final start = (page - 1) * limit;
    if (start >= _posts.length) return [];
    final end = min(start + limit, _posts.length);
    return _posts.sublist(start, end);
  }

  @override
  Future<List<Post>> getDiscoverFeed({int page = 1, int limit = 20}) async {
    await _delay();
    // Return same posts randomly shuffled or reversed for variety
    return [..._posts.reversed];
  }

  @override
  Future<List<Post>> getUserPosts(String userId, {int page = 1, int limit = 20}) async {
    await _delay();
    return _posts.where((p) => p.authorId == userId).toList();
  }

  @override
  Future<Post> getPostById(String postId) async {
    await _delay();
    return _posts.firstWhere((p) => p.id == postId);
  }

  @override
  Future<Post> createPost({
    required String content,
    List<String>? mediaUrls,
    String? mediaType,
    String? location,
  }) async {
    await _delay();
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: 'currentUser',
      authorName: 'John Doe',
      authorUsername: 'johndoe',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400', // Mock data match
      authorIsVerified: true,
      content: content,
      mediaUrls: mediaUrls ?? [],
      mediaType: mediaType,
      location: location,
      viewsCount: 0,
      createdAt: DateTime.now(),
    );
    _posts.insert(0, newPost);
    return newPost;
  }

  @override
  Future<Post> updatePost(String postId, {String? content}) async {
    await _delay();
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    
    final updated = _posts[index].copyWith(content: content, updatedAt: DateTime.now());
    _posts[index] = updated;
    return updated;
  }

  @override
  Future<void> deletePost(String postId) async {
    await _delay();
    _posts.removeWhere((p) => p.id == postId);
  }

  @override
  Future<Post> likePost(String postId) async {
    // Controller handles optimistic update, but repo should also update source of truth
    await _delay();
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    
    final p = _posts[index];
    final updated = p.copyWith(isLiked: true, likesCount: p.likesCount + 1);
    _posts[index] = updated;
    return updated;
  }

  @override
  Future<Post> unlikePost(String postId) async {
    await _delay();
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    
    final p = _posts[index];
    final updated = p.copyWith(isLiked: false, likesCount: p.likesCount > 0 ? p.likesCount - 1 : 0);
    _posts[index] = updated;
    return updated;
  }

  @override
  Future<void> incrementViews(String postId) async {
    // Avoid counting duplicate views in same session
    if (_viewedPostIds.contains(postId)) return;
    _viewedPostIds.add(postId);
    
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) return;
    
    final p = _posts[index];
    _posts[index] = p.copyWith(viewsCount: p.viewsCount + 1);
    // In real backend: would call API to increment view count
  }

  @override
  Future<Post> reactToPost(String postId, ReactionType type) async {
    await _delay();
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    
    final p = _posts[index];
    final newCounts = Map<ReactionType, int>.from(p.reactionCounts);
    
    // Remove old reaction if exists
    if (p.userReaction != null) {
      final oldCount = newCounts[p.userReaction] ?? 0;
      if (oldCount > 1) {
        newCounts[p.userReaction!] = oldCount - 1;
      } else {
        newCounts.remove(p.userReaction);
      }
    }
    
    // Add new reaction
    newCounts[type] = (newCounts[type] ?? 0) + 1;
    
    final updated = p.copyWith(
      userReaction: type,
      reactionCounts: newCounts,
    );
    _posts[index] = updated;
    return updated;
  }

  @override
  Future<Post> removeReaction(String postId) async {
    await _delay();
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    
    final p = _posts[index];
    if (p.userReaction == null) return p;
    
    final newCounts = Map<ReactionType, int>.from(p.reactionCounts);
    final oldCount = newCounts[p.userReaction] ?? 0;
    if (oldCount > 1) {
      newCounts[p.userReaction!] = oldCount - 1;
    } else {
      newCounts.remove(p.userReaction);
    }
    
    final updated = p.copyWith(
      clearUserReaction: true,
      reactionCounts: newCounts,
    );
    _posts[index] = updated;
    return updated;
  }

  @override
  Future<Post> bookmarkPost(String postId) async {
    await _delay();
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    
    final updated = _posts[index].copyWith(isBookmarked: true);
    _posts[index] = updated;
    return updated;
  }

  @override
  Future<Post> unbookmarkPost(String postId) async {
    await _delay();
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index == -1) throw Exception('Post not found');
    
    final updated = _posts[index].copyWith(isBookmarked: false);
    _posts[index] = updated;
    return updated;
  }

  @override
  Future<List<Post>> getBookmarkedPosts({int page = 1, int limit = 20}) async {
    await _delay();
    final bookmarked = _posts.where((p) => p.isBookmarked).toList();
    final start = (page - 1) * limit;
    if (start >= bookmarked.length) return [];
    final end = (start + limit).clamp(0, bookmarked.length);
    return bookmarked.sublist(start, end);
  }

  @override
  Future<List<Comment>> getComments(String postId, {int page = 1, int limit = 20}) async {
    await _delay();
    return _comments[postId] ?? [];
  }

  @override
  Future<Comment> addComment(String postId, String content, {String? parentCommentId}) async {
    await _delay();
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: postId,
      authorId: 'currentUser',
      authorName: 'John Doe',
      authorUsername: 'johndoe',
      authorAvatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      content: content,
      createdAt: DateTime.now(),
      parentCommentId: parentCommentId,
    );
    
    if (!_comments.containsKey(postId)) {
      _comments[postId] = [];
    }
    _comments[postId]!.add(newComment);
    
    // Update post comment count
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(commentsCount: _posts[index].commentsCount + 1);
    }
    
    return newComment;
  }

  @override
  Future<Comment> updateComment(String postId, String commentId, String content) async {
    await _delay();
    final list = _comments[postId];
    if (list == null) throw Exception('Comments not found');
    
    final index = list.indexWhere((c) => c.id == commentId);
    if (index == -1) throw Exception('Comment not found');
    
    final updated = list[index].copyWith(content: content);
    list[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    await _delay();
    final list = _comments[postId];
    if (list != null) {
      list.removeWhere((c) => c.id == commentId);
    }
    
    // Update post comment count
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        commentsCount: max(0, _posts[index].commentsCount - 1)
      );
    }
  }

  @override
  Future<Comment> likeComment(String commentId) async {
    // Simplifying: search in all posts' comments
    await _delay();
     for (var key in _comments.keys) {
      final list = _comments[key]!;
      final index = list.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final c = list[index];
        final updated = c.copyWith(isLiked: true, likesCount: c.likesCount + 1);
        list[index] = updated;
        return updated;
      }
    }
    throw Exception('Comment not found');
  }

  @override
  Future<Comment> unlikeComment(String commentId) async {
    await _delay();
    for (var key in _comments.keys) {
      final list = _comments[key]!;
      final index = list.indexWhere((c) => c.id == commentId);
      if (index != -1) {
        final c = list[index];
        final updated = c.copyWith(isLiked: false, likesCount: max(0, c.likesCount - 1));
        list[index] = updated;
        return updated;
      }
    }
    throw Exception('Comment not found');
  }

  @override
  Future<void> sharePost(String postId) async {
     await _delay();
     final index = _posts.indexWhere((p) => p.id == postId);
     if (index != -1) {
       _posts[index] = _posts[index].copyWith(sharesCount: _posts[index].sharesCount + 1);
     }
  }

  @override
  Future<List<Post>> searchPosts(String query, {int page = 1, int limit = 20}) async {
    await _delay();
    final q = query.toLowerCase();
    return _posts.where((p) => 
      (p.content?.toLowerCase().contains(q) ?? false) ||
      p.hashtags.any((h) => h.toLowerCase().contains(q))
    ).toList();
  }

  @override
  Future<List<Post>> getPostsByHashtag(String hashtag, {int page = 1, int limit = 20}) async {
    await _delay();
    return _posts.where((p) => p.hashtags.contains(hashtag)).toList();
  }

  /// Returns the count of posts for a specific user synchronously
  int getUserPostsCount(String userId) {
    return _posts.where((p) => p.authorId == userId).length;
  }
}
