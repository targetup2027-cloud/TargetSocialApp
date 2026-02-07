import '../../../../core/network/network_client.dart';
import '../models/post_model.dart';
import '../../models/post_data.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getFeed({int page = 1, int limit = 20});
  Future<List<PostModel>> getDiscoverFeed({int page = 1, int limit = 20});
  Future<List<PostModel>> getUserPosts(String userId, {int page = 1, int limit = 20});
  Future<PostModel> getPostById(String postId);
  Future<PostModel> createPost({
    required String content,
    List<String>? mediaUrls,
    String? mediaType,
    String? location,
  });
  Future<PostModel> updatePost(String postId, {String? content});
  Future<void> deletePost(String postId);
  Future<PostModel> likePost(String postId);
  Future<PostModel> unlikePost(String postId);
  Future<void> incrementViews(String postId);
  Future<PostModel> reactToPost(String postId, ReactionType type);
  Future<PostModel> removeReaction(String postId);
  Future<PostModel> bookmarkPost(String postId);
  Future<PostModel> unbookmarkPost(String postId);
  Future<List<CommentModel>> getComments(String postId, {int page = 1, int limit = 20});
  Future<CommentModel> addComment(String postId, String content, {String? parentCommentId});
  Future<CommentModel> updateComment(String postId, String commentId, String content);
  Future<void> deleteComment(String postId, String commentId);
  Future<CommentModel> likeComment(String commentId);
  Future<CommentModel> unlikeComment(String commentId);
  Future<void> sharePost(String postId);
  Future<List<PostModel>> searchPosts(String query, {int page = 1, int limit = 20});
  Future<List<PostModel>> getPostsByHashtag(String hashtag, {int page = 1, int limit = 20});
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final NetworkClient _client;

  PostsRemoteDataSourceImpl({required NetworkClient client}) : _client = client;

  List<PostModel> _parsePostList(dynamic response) {
    final List<dynamic> data = response['data'] ?? response;
    return data.map((json) => PostModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<PostModel>> getFeed({int page = 1, int limit = 20}) async {
    final response = await _client.get('/api/Posts/feed');
    return _parsePostList(response);
  }

  @override
  Future<List<PostModel>> getDiscoverFeed({int page = 1, int limit = 20}) async {
    final response = await _client.get('/api/Posts/feed');
    return _parsePostList(response);
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId, {int page = 1, int limit = 20}) async {
    final response = await _client.get('/api/Posts/user/$userId');
    return _parsePostList(response);
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    final response = await _client.get('/api/Posts/$postId');
    final data = response['data'] ?? response;
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PostModel> createPost({
    required String content,
    List<String>? mediaUrls,
    String? mediaType,
    String? location,
  }) async {
    final response = await _client.post('/api/Posts', data: {
      'content': content,
      if (mediaUrls != null) 'mediaUrls': mediaUrls,
      if (mediaType != null) 'mediaType': mediaType,
      if (location != null) 'location': location,
    });

    final data = response['data'] ?? response;
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PostModel> updatePost(String postId, {String? content}) async {
    final response = await _client.put('/api/Posts/$postId', data: {
      if (content != null) 'content': content,
    });

    final data = response['data'] ?? response;
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deletePost(String postId) async {
    await _client.delete('/api/Posts/$postId');
  }

  @override
  Future<PostModel> likePost(String postId) async {
    final response = await _client.post('/api/Posts/$postId/like');
    final data = response['data'] ?? response;
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PostModel> unlikePost(String postId) async {
    final response = await _client.post('/api/Posts/$postId/like');
    final data = response['data'] ?? response;
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PostModel> bookmarkPost(String postId) async {
    final response = await _client.post('/api/Posts/$postId/save');
    final data = response['data'] ?? response;
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PostModel> unbookmarkPost(String postId) async {
    final response = await _client.delete('/api/Posts/$postId/save');
    final data = response['data'] ?? response;
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<List<CommentModel>> getComments(String postId, {int page = 1, int limit = 20}) async {
    final response = await _client.get('/api/posts/$postId/comments');
    return (response['data'] as List<dynamic>?)
            ?.map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
            .toList() ??
        [];
  }

  @override
  Future<CommentModel> addComment(String postId, String content, {String? parentCommentId}) async {
    final response = await _client.post('/api/posts/$postId/comments', data: {
      'content': content,
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
    });

    final data = response['data'] ?? response;
    return CommentModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CommentModel> updateComment(String postId, String commentId, String content) async {
    final response = await _client.put('/api/comments/$commentId', data: {
      'content': content,
    });

    final data = response['data'] ?? response;
    return CommentModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    await _client.delete('/api/comments/$commentId');
  }

  @override
  Future<CommentModel> likeComment(String commentId) async {
    final response = await _client.post('/api/comments/$commentId/like');
    final data = response['data'] ?? response;
    return CommentModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<CommentModel> unlikeComment(String commentId) async {
    final response = await _client.delete('/api/comments/$commentId/like');
    final data = response['data'] ?? response;
    return CommentModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> sharePost(String postId) async {
    await _client.post('/api/Posts/$postId/share');
  }

  @override
  Future<List<PostModel>> searchPosts(String query, {int page = 1, int limit = 20}) async {
    final response = await _client.get(
      '/api/Search/posts',
      queryParameters: {'query': query},
    );
    return _parsePostList(response);
  }

  @override
  Future<List<PostModel>> getPostsByHashtag(String hashtag, {int page = 1, int limit = 20}) async {
    final response = await _client.get(
      '/api/Search/hashtags',
      queryParameters: {'query': hashtag},
    );
    return _parsePostList(response);
  }

  @override
  Future<void> incrementViews(String postId) async {
    try {
      await _client.post('/api/Posts/$postId/view');
    } catch (_) {
      // Fire-and-forget
    }
  }

  @override
  Future<PostModel> reactToPost(String postId, ReactionType type) async {
    final response = await _client.post('/api/Posts/$postId/react', data: {
      'type': type.name,
    });
    final data = response['data'] ?? response;
    return PostModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<PostModel> removeReaction(String postId) async {
    final response = await _client.post('/api/Posts/$postId/react');
    final data = response['data'] ?? response;
    return PostModel.fromJson(data as Map<String, dynamic>);
  }
}
