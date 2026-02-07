import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_data.dart';
import '../domain/entities/post.dart';
import '../domain/repositories/posts_repository.dart';

import '../data/datasources/posts_remote_data_source.dart';
import '../data/datasources/posts_local_data_source.dart';
import '../data/repositories/posts_repository_impl.dart';
import '../../../core/validation/validators.dart';
import '../../auth/data/datasources/auth_remote_data_source.dart';
import '../../notifications/application/notification_service.dart';
import '../../notifications/application/notifications_controller.dart';
import '../../profile/application/profile_controller.dart';
import 'current_user_provider.dart';

const String kCurrentUserId = 'currentUser';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final postsRemoteDataSourceProvider = Provider<PostsRemoteDataSource>((ref) {
  final client = ref.watch(networkClientProvider);
  return PostsRemoteDataSourceImpl(client: client);
});

final postsLocalDataSourceProvider = Provider<PostsLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PostsLocalDataSourceImpl(sharedPreferences: prefs);
});

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepositoryImpl(
    remoteDataSource: ref.watch(postsRemoteDataSourceProvider),
    localDataSource: ref.watch(postsLocalDataSourceProvider),
    useMockData: false,
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

final bookmarkedPostsProvider = FutureProvider<List<Post>>((ref) async {
  final repository = ref.watch(postsRepositoryProvider);
  return repository.getBookmarkedPosts();
});

class PostsController extends StateNotifier<AsyncValue<List<Post>>> {
  final PostsRepository _repository;
  final Ref _ref;
  int _currentPage = 1;
  bool _hasMore = true;
  int _currentTabIndex = 0;

  PostsController(this._repository, this._ref) : super(const AsyncValue.loading()) {
    loadFeed();
  }

  Future<void> changeTab(int index) async {
    if (_currentTabIndex == index) return;
    _currentTabIndex = index;
    await loadFeed();
  }

  Future<void> loadFeed() async {
    state = const AsyncValue.loading();
    try {
      List<Post> posts;
      if (_currentTabIndex == 2) {
        // Trending
        posts = await _repository.getDiscoverFeed(page: 1);
      } else if (_currentTabIndex == 1) {
        // Following - Just a mock simulation, normally would be getFollowingFeed
        // For now using getFeed but reversed to show difference
        final allPosts = await _repository.getFeed(page: 1);
        posts = allPosts.reversed.toList();
      } else {
        // For You
        posts = await _repository.getFeed(page: 1);
      }
      
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
      List<Post> newPosts;
      if (_currentTabIndex == 2) {
        newPosts = await _repository.getDiscoverFeed(page: _currentPage + 1);
      } else if (_currentTabIndex == 1) {
        final allPosts = await _repository.getFeed(page: _currentPage + 1);
        newPosts = allPosts.reversed.toList();
      } else {
        newPosts = await _repository.getFeed(page: _currentPage + 1);
      }

      _currentPage++;
      _hasMore = newPosts.length >= 20;
      state = AsyncValue.data([...currentPosts, ...newPosts]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
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
    PostVisibility visibility = PostVisibility.public,
    List<PostMedia> media = const [],
  }) async {
    final hasMedia = media.isNotEmpty || (mediaUrls != null && mediaUrls.isNotEmpty);
    final hasContent = content.trim().isNotEmpty;
    
    if (!hasContent && !hasMedia) {
      state = AsyncValue.error(
        Exception('يرجى إضافة نص أو وسائط'),
        StackTrace.current,
      );
      return;
    }

    if (hasContent) {
      final contentValidation = Validators.maxLength(content, 5000, fieldName: 'محتوى المنشور');
      if (!contentValidation.isValid) {
        state = AsyncValue.error(
          Exception(contentValidation.errorMessage),
          StackTrace.current,
        );
        return;
      }
    }

    if (media.isNotEmpty) {
      final mediaValidation = Validators.listMaxLength(
        media,
        10,
        fieldName: 'الصور والفيديوهات',
      );
      
      if (!mediaValidation.isValid) {
        state = AsyncValue.error(
          Exception(mediaValidation.errorMessage),
          StackTrace.current,
        );
        return;
      }
    }

    try {
      final newPost = await _repository.createPost(
        content: content.trim(),
        mediaUrls: mediaUrls,
        mediaType: mediaType,
        location: location,
      );
      final postWithPostVisibility = newPost.copyWith(
        visibility: visibility,
        media: media,
      );
      final currentPosts = state.valueOrNull ?? [];
      state = AsyncValue.data([postWithPostVisibility, ...currentPosts]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePost({
    required String postId,
    String? content,
    PostVisibility? visibility,
    List<PostMedia>? media,
    List<String>? mediaUrls,
  }) async {
    final currentPosts = state.valueOrNull ?? [];
    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    final originalPost = currentPosts[index];
    final updatedPost = originalPost.copyWith(
      content: content,
      visibility: visibility,
      media: media,
      mediaUrls: mediaUrls,
      updatedAt: DateTime.now(),
    );

    final updatedPosts = [...currentPosts];
    updatedPosts[index] = updatedPost;
    state = AsyncValue.data(updatedPosts);

    try {
      await _repository.updatePost(postId, content: content);
    } catch (_) {
      final revertPosts = state.valueOrNull ?? [];
      final revertIndex = revertPosts.indexWhere((p) => p.id == postId);
      if (revertIndex >= 0) {
        final reverted = [...revertPosts];
        reverted[revertIndex] = originalPost;
        state = AsyncValue.data(reverted);
      }
    }
  }

  Future<void> deletePost(String postId) async {
    final currentPosts = state.valueOrNull ?? [];
    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    
    final deletedPost = currentPosts[index];
    
    state = AsyncValue.data(
      currentPosts.where((p) => p.id != postId).toList(),
    );

    try {
      await _repository.deletePost(postId);
    } catch (_) {
      final revertPosts = state.valueOrNull ?? [];
      final insertIndex = index.clamp(0, revertPosts.length);
      final updatedPosts = [...revertPosts];
      updatedPosts.insert(insertIndex, deletedPost);
      state = AsyncValue.data(updatedPosts);
    }
  }

  Future<void> setCommentsEnabled({
    required String postId,
    required bool enabled,
  }) async {
    final currentPosts = state.valueOrNull ?? [];
    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    final post = currentPosts[index];
    final updatedPost = post.copyWith(commentsEnabled: enabled);

    final updatedPosts = [...currentPosts];
    updatedPosts[index] = updatedPost;
    state = AsyncValue.data(updatedPosts);
  }

  Future<void> toggleLike(String postId) async {
    final currentPosts = state.valueOrNull ?? [];
    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    final post = currentPosts[index];
    final wasLiked = post.isLiked;
    
    final optimisticPost = post.copyWith(
      isLiked: !wasLiked,
      likesCount: wasLiked ? post.likesCount - 1 : post.likesCount + 1,
    );
    
    final optimisticPosts = [...currentPosts];
    optimisticPosts[index] = optimisticPost;
    state = AsyncValue.data(optimisticPosts);

    try {
      final serverPost = wasLiked
          ? await _repository.unlikePost(postId)
          : await _repository.likePost(postId);
      
      final finalPosts = state.valueOrNull ?? [];
      final finalIndex = finalPosts.indexWhere((p) => p.id == postId);
      if (finalIndex >= 0) {
        final updatedPosts = [...finalPosts];
        updatedPosts[finalIndex] = serverPost;
        state = AsyncValue.data(updatedPosts);
      }

      if (!wasLiked) {
        final currentUserId = _ref.read(currentUserIdProvider);
        if (post.authorId != currentUserId) {
          final currentUserProfile = _ref.read(profileControllerProvider).valueOrNull;
          final notificationsRepo = _ref.read(notificationsRepositoryProvider);
          final notificationService = NotificationService(notificationsRepo);
          await notificationService.createPostLikedNotification(
            actorUserId: currentUserId,
            actorDisplayName: currentUserProfile?.displayName ?? 'Someone',
            actorAvatarUrl: currentUserProfile?.avatarUrl,
            targetUserId: post.authorId,
            postId: postId,
          );
        }
      }
    } catch (_) {
      final revertPosts = state.valueOrNull ?? [];
      final revertIndex = revertPosts.indexWhere((p) => p.id == postId);
      if (revertIndex >= 0) {
        final updatedPosts = [...revertPosts];
        updatedPosts[revertIndex] = post;
        state = AsyncValue.data(updatedPosts);
      }
    }
  }

  Future<void> toggleBookmark(String postId) async {
    final currentPosts = state.valueOrNull ?? [];
    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    final post = currentPosts[index];
    final wasBookmarked = post.isBookmarked;
    
    final optimisticPost = post.copyWith(
      isBookmarked: !wasBookmarked,
    );
    
    final optimisticPosts = [...currentPosts];
    optimisticPosts[index] = optimisticPost;
    state = AsyncValue.data(optimisticPosts);

    try {
      final serverPost = wasBookmarked
          ? await _repository.unbookmarkPost(postId)
          : await _repository.bookmarkPost(postId);
      
      final finalPosts = state.valueOrNull ?? [];
      final finalIndex = finalPosts.indexWhere((p) => p.id == postId);
      if (finalIndex >= 0) {
        final updatedPosts = [...finalPosts];
        updatedPosts[finalIndex] = serverPost;
        state = AsyncValue.data(updatedPosts);
      }
    } catch (_) {
      final revertPosts = state.valueOrNull ?? [];
      final revertIndex = revertPosts.indexWhere((p) => p.id == postId);
      if (revertIndex >= 0) {
        final updatedPosts = [...revertPosts];
        updatedPosts[revertIndex] = post;
        state = AsyncValue.data(updatedPosts);
      }
    }
  }

  Future<void> reactToPost(String postId, ReactionType type) async {
    final currentPosts = state.valueOrNull ?? [];
    final index = currentPosts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    final post = currentPosts[index];
    
    final bool clearReaction = post.userReaction == type;
    
    // Update reaction counts properly
    final newReactionCounts = Map<ReactionType, int>.from(post.reactionCounts);
    
    // Remove old reaction if exists
    if (post.userReaction != null) {
      final oldCount = newReactionCounts[post.userReaction] ?? 0;
      if (oldCount > 1) {
        newReactionCounts[post.userReaction!] = oldCount - 1;
      } else {
        newReactionCounts.remove(post.userReaction);
      }
    }
    
    // Add new reaction if not clearing
    if (!clearReaction) {
      newReactionCounts[type] = (newReactionCounts[type] ?? 0) + 1;
    }
    
    final updatedPost = post.copyWith(
      userReaction: clearReaction ? null : type,
      clearUserReaction: clearReaction,
      isLiked: !clearReaction,
      reactionCounts: newReactionCounts,
    );

    final updatedPosts = [...currentPosts];
    updatedPosts[index] = updatedPost;
    state = AsyncValue.data(updatedPosts);
  }

  Post? getPostById(String postId) {
    final posts = state.valueOrNull ?? [];
    try {
      return posts.firstWhere((p) => p.id == postId);
    } catch (_) {
      return null;
    }
  }
}

final postsControllerProvider = StateNotifierProvider<PostsController, AsyncValue<List<Post>>>((ref) {
  final repository = ref.watch(postsRepositoryProvider);
  return PostsController(repository, ref);
});

class CommentsController extends StateNotifier<AsyncValue<List<Comment>>> {
  final PostsRepository _repository;
  final String postId;
  final Ref _ref;

  CommentsController(this._repository, this.postId, this._ref) : super(const AsyncValue.loading()) {
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
    final contentValidation = Validators.combine([
      Validators.required(content, fieldName: 'التعليق'),
      Validators.maxLength(content, 1000, fieldName: 'التعليق'),
    ]);

    if (!contentValidation.isValid) {
      state = AsyncValue.error(
        Exception(contentValidation.errorMessage),
        StackTrace.current,
      );
      return;
    }

    try {
      final newComment = await _repository.addComment(
        postId,
        content.trim(),
        parentCommentId: parentCommentId,
      );
      final currentComments = state.valueOrNull ?? [];
      if (!currentComments.any((c) => c.id == newComment.id)) {
        state = AsyncValue.data([...currentComments, newComment]);
      }
      
      _ref.read(postsControllerProvider.notifier).state.whenData((posts) {
        final index = posts.indexWhere((p) => p.id == postId);
        if (index >= 0) {
          final post = posts[index];
          final updatedPost = post.copyWith(commentsCount: post.commentsCount + 1);
          final updatedPosts = [...posts];
          updatedPosts[index] = updatedPost;
          _ref.read(postsControllerProvider.notifier).state = AsyncValue.data(updatedPosts);

          final currentUserId = _ref.read(currentUserIdProvider);
          if (post.authorId != currentUserId) {
            final currentUserProfile = _ref.read(profileControllerProvider).valueOrNull;
            final notificationsRepo = _ref.read(notificationsRepositoryProvider);
            final notificationService = NotificationService(notificationsRepo);
            notificationService.createCommentNotification(
              actorUserId: currentUserId,
              actorDisplayName: currentUserProfile?.displayName ?? 'Someone',
              actorAvatarUrl: currentUserProfile?.avatarUrl,
              targetUserId: post.authorId,
              postId: postId,
              commentId: newComment.id,
              commentPreview: content.trim().length > 50 ? '${content.trim().substring(0, 50)}...' : content.trim(),
            );
          }
        }
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> editComment({
    required String commentId,
    required String content,
  }) async {
    try {
      final updatedComment = await _repository.updateComment(postId, commentId, content);
      final currentComments = state.valueOrNull ?? [];
      final index = currentComments.indexWhere((c) => c.id == commentId);
      if (index >= 0) {
        final updatedComments = [...currentComments];
        updatedComments[index] = updatedComment;
        state = AsyncValue.data(updatedComments);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addReply({
    required String parentCommentId,
    required String text,
  }) async {
    await addComment(text, parentCommentId: parentCommentId);
  }

  Future<void> deleteComment({
    required String commentId,
    required String requestedByUserId,
  }) async {
    final currentComments = state.valueOrNull ?? [];
    final index = currentComments.indexWhere((c) => c.id == commentId);
    if (index < 0) return;

    final comment = currentComments[index];
    
    final post = _ref.read(postsControllerProvider.notifier).getPostById(postId);
    final isPostOwner = post?.authorId == requestedByUserId;
    final isCommentOwner = comment.authorId == requestedByUserId;
    
    if (!isPostOwner && !isCommentOwner) return;

    try {
      await _repository.deleteComment(postId, commentId);
      final updatedComments = [...currentComments];
      updatedComments.removeAt(index);
      state = AsyncValue.data(updatedComments);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reactToComment({
    required String commentId,
    required String userId,
    required ReactionType type,
  }) async {
    final currentComments = state.valueOrNull ?? [];
    final index = currentComments.indexWhere((c) => c.id == commentId);
    if (index < 0) return;

    final comment = currentComments[index];
    final bool clearReaction = comment.userReaction == type;
    
    final newReactionCounts = Map<ReactionType, int>.from(comment.reactionCounts);
    
    if (comment.userReaction != null) {
      final oldCount = newReactionCounts[comment.userReaction] ?? 0;
      if (oldCount > 1) {
        newReactionCounts[comment.userReaction!] = oldCount - 1;
      } else {
        newReactionCounts.remove(comment.userReaction);
      }
    }
    
    if (!clearReaction) {
      newReactionCounts[type] = (newReactionCounts[type] ?? 0) + 1;
    }

    final updatedComment = comment.copyWith(
      userReaction: clearReaction ? null : type,
      clearUserReaction: clearReaction,
      reactionCounts: newReactionCounts,
      likesCount: clearReaction 
          ? (comment.likesCount > 0 ? comment.likesCount - 1 : 0)
          : (comment.userReaction == null ? comment.likesCount + 1 : comment.likesCount),
    );

    final updatedComments = [...currentComments];
    updatedComments[index] = updatedComment;
    state = AsyncValue.data(updatedComments);
  }

  Future<void> removeReactionFromComment({
    required String commentId,
    required String userId,
  }) async {
    final currentComments = state.valueOrNull ?? [];
    final index = currentComments.indexWhere((c) => c.id == commentId);
    if (index < 0) return;

    final comment = currentComments[index];
    if (comment.userReaction == null) return;

    final newReactionCounts = Map<ReactionType, int>.from(comment.reactionCounts);
    final oldCount = newReactionCounts[comment.userReaction] ?? 0;
    if (oldCount > 1) {
      newReactionCounts[comment.userReaction!] = oldCount - 1;
    } else {
      newReactionCounts.remove(comment.userReaction);
    }

    final updatedComment = comment.copyWith(
      clearUserReaction: true,
      reactionCounts: newReactionCounts,
      likesCount: comment.likesCount > 0 ? comment.likesCount - 1 : 0,
    );

    final updatedComments = [...currentComments];
    updatedComments[index] = updatedComment;
    state = AsyncValue.data(updatedComments);
  }

  List<Comment> getTopLevelComments() {
    final comments = state.valueOrNull ?? [];
    return comments.where((c) => c.parentCommentId == null).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  List<Comment> getReplies(String parentCommentId) {
    final comments = state.valueOrNull ?? [];
    return comments.where((c) => c.parentCommentId == parentCommentId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }
}

final commentsControllerProvider = StateNotifierProvider.family<CommentsController, AsyncValue<List<Comment>>, String>((ref, postId) {
  final repository = ref.watch(postsRepositoryProvider);
  return CommentsController(repository, postId, ref);
});
