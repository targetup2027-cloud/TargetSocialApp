import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/post.dart';
import '../domain/repositories/posts_repository.dart';
import '../data/repositories/posts_repository_impl.dart';
import '../data/datasources/posts_remote_data_source.dart';
import '../data/datasources/posts_local_data_source.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final httpClientProvider = Provider<http.Client>((ref) {
  return http.Client();
});

final postsRemoteDataSourceProvider = Provider<PostsRemoteDataSource>((ref) {
  final client = ref.watch(httpClientProvider);
  return PostsRemoteDataSourceImpl(client: client);
});

final postsLocalDataSourceProvider = Provider<PostsLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PostsLocalDataSourceImpl(sharedPreferences: prefs);
});

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  final remote = ref.watch(postsRemoteDataSourceProvider);
  final local = ref.watch(postsLocalDataSourceProvider);
  return PostsRepositoryImpl(
    remoteDataSource: remote,
    localDataSource: local,
    useMockData: true,
  );
});

final feedProvider = FutureProvider.family<List<Post>, int>((ref, page) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getFeed(page: page);
});

final discoverFeedProvider = FutureProvider.family<List<Post>, int>((ref, page) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getDiscoverFeed(page: page);
});

final userPostsProvider = FutureProvider.family<List<Post>, String>((ref, userId) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getUserPosts(userId);
});

final postByIdProvider = FutureProvider.family<Post, String>((ref, postId) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getPostById(postId);
});

final commentsProvider = FutureProvider.family<List<Comment>, String>((ref, postId) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getComments(postId);
});

final searchPostsProvider = FutureProvider.family<List<Post>, String>((ref, query) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.searchPosts(query);
});

class PostsController extends StateNotifier<AsyncValue<List<Post>>> {
  final PostsRepository _repository;
  int _currentPage = 1;
  bool _hasMore = true;

  PostsController(this._repository) : super(const AsyncValue.loading()) {
    loadFeed();
  }

  Future<void> loadFeed() async {
    state = const AsyncValue.loading();
    try {
      final posts = await _repository.getFeed(page: 1);
      _currentPage = 1;
      _hasMore = posts.length >= 20;
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;
    
    final currentPosts = state.valueOrNull ?? [];
    try {
      final newPosts = await _repository.getFeed(page: _currentPage + 1);
      _currentPage++;
      _hasMore = newPosts.length >= 20;
      state = AsyncValue.data([...currentPosts, ...newPosts]);
    } catch (e) {
      
    }
  }

  Future<void> refresh() async {
    await loadFeed();
  }

  Future<void> createPost({
    required String content,
    List<String>? mediaUrls,
    String? mediaType,
    String? location,
  }) async {
    try {
      final newPost = await _repository.createPost(
        content: content,
        mediaUrls: mediaUrls,
        mediaType: mediaType,
        location: location,
      );
      final currentPosts = state.valueOrNull ?? [];
      state = AsyncValue.data([newPost, ...currentPosts]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _repository.deletePost(postId);
      final currentPosts = state.valueOrNull ?? [];
      state = AsyncValue.data(currentPosts.where((p) => p.id != postId).toList());
    } catch (e) {
      
    }
  }

  Future<void> toggleLike(String postId) async {
    final currentPosts = state.valueOrNull ?? [];
    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    final post = currentPosts[index];
    try {
      final updatedPost = post.isLiked
          ? await _repository.unlikePost(postId)
          : await _repository.likePost(postId);
      
      final updatedPosts = [...currentPosts];
      updatedPosts[index] = updatedPost;
      state = AsyncValue.data(updatedPosts);
    } catch (e) {
      
    }
  }

  Future<void> toggleBookmark(String postId) async {
    final currentPosts = state.valueOrNull ?? [];
    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    final post = currentPosts[index];
    try {
      final updatedPost = post.isBookmarked
          ? await _repository.unbookmarkPost(postId)
          : await _repository.bookmarkPost(postId);
      
      final updatedPosts = [...currentPosts];
      updatedPosts[index] = updatedPost;
      state = AsyncValue.data(updatedPosts);
    } catch (e) {
      
    }
  }
}

final postsControllerProvider = StateNotifierProvider<PostsController, AsyncValue<List<Post>>>((ref) {
  final repository = ref.watch(postsRepositoryProvider);
  return PostsController(repository);
});

class CommentsController extends StateNotifier<AsyncValue<List<Comment>>> {
  final PostsRepository _repository;
  final String postId;

  CommentsController(this._repository, this.postId) : super(const AsyncValue.loading()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = const AsyncValue.loading();
    try {
      final comments = await _repository.getComments(postId);
      state = AsyncValue.data(comments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addComment(String content, {String? parentCommentId}) async {
    try {
      final newComment = await _repository.addComment(postId, content, parentCommentId: parentCommentId);
      final currentComments = state.valueOrNull ?? [];
      state = AsyncValue.data([...currentComments, newComment]);
    } catch (e) {
      
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _repository.deleteComment(postId, commentId);
      final currentComments = state.valueOrNull ?? [];
      state = AsyncValue.data(currentComments.where((c) => c.id != commentId).toList());
    } catch (e) {
      
    }
  }
}

final commentsControllerProvider = StateNotifierProvider.family<CommentsController, AsyncValue<List<Comment>>, String>((ref, postId) {
  final repository = ref.watch(postsRepositoryProvider);
  return CommentsController(repository, postId);
});
