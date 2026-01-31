import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/post_model.dart';

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
  Future<PostModel> bookmarkPost(String postId);
  Future<PostModel> unbookmarkPost(String postId);
  Future<List<CommentModel>> getComments(String postId, {int page = 1, int limit = 20});
  Future<CommentModel> addComment(String postId, String content, {String? parentCommentId});
  Future<void> deleteComment(String postId, String commentId);
  Future<CommentModel> likeComment(String commentId);
  Future<CommentModel> unlikeComment(String commentId);
  Future<void> sharePost(String postId);
  Future<List<PostModel>> searchPosts(String query, {int page = 1, int limit = 20});
  Future<List<PostModel>> getPostsByHashtag(String hashtag, {int page = 1, int limit = 20});
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  final http.Client client;
  final String? authToken;

  PostsRemoteDataSourceImpl({
    required this.client,
    this.authToken,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  @override
  Future<List<PostModel>> getFeed({int page = 1, int limit = 20}) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/posts?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load feed');
    }
  }

  @override
  Future<List<PostModel>> getDiscoverFeed({int page = 1, int limit = 20}) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/posts/discover?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load discover feed');
    }
  }

  @override
  Future<List<PostModel>> getUserPosts(String userId, {int page = 1, int limit = 20}) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/posts?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user posts');
    }
  }

  @override
  Future<PostModel> getPostById(String postId) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  @override
  Future<PostModel> createPost({
    required String content,
    List<String>? mediaUrls,
    String? mediaType,
    String? location,
  }) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/posts'),
      headers: _headers,
      body: json.encode({
        'content': content,
        if (mediaUrls != null) 'mediaUrls': mediaUrls,
        if (mediaType != null) 'mediaType': mediaType,
        if (location != null) 'location': location,
      }),
    );

    if (response.statusCode == 201) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create post');
    }
  }

  @override
  Future<PostModel> updatePost(String postId, {String? content}) async {
    final response = await client.put(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId'),
      headers: _headers,
      body: json.encode({
        if (content != null) 'content': content,
      }),
    );

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update post');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete post');
    }
  }

  @override
  Future<PostModel> likePost(String postId) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId/like'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to like post');
    }
  }

  @override
  Future<PostModel> unlikePost(String postId) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId/like'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to unlike post');
    }
  }

  @override
  Future<PostModel> bookmarkPost(String postId) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId/bookmark'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to bookmark post');
    }
  }

  @override
  Future<PostModel> unbookmarkPost(String postId) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId/bookmark'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return PostModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to unbookmark post');
    }
  }

  @override
  Future<List<CommentModel>> getComments(String postId, {int page = 1, int limit = 20}) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId/comments?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => CommentModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  @override
  Future<CommentModel> addComment(String postId, String content, {String? parentCommentId}) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId/comments'),
      headers: _headers,
      body: json.encode({
        'content': content,
        if (parentCommentId != null) 'parentCommentId': parentCommentId,
      }),
    );

    if (response.statusCode == 201) {
      return CommentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add comment');
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId/comments/$commentId'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete comment');
    }
  }

  @override
  Future<CommentModel> likeComment(String commentId) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/comments/$commentId/like'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return CommentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to like comment');
    }
  }

  @override
  Future<CommentModel> unlikeComment(String commentId) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}/comments/$commentId/like'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return CommentModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to unlike comment');
    }
  }

  @override
  Future<void> sharePost(String postId) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/posts/$postId/share'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to share post');
    }
  }

  @override
  Future<List<PostModel>> searchPosts(String query, {int page = 1, int limit = 20}) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/posts/search?q=$query&page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search posts');
    }
  }

  @override
  Future<List<PostModel>> getPostsByHashtag(String hashtag, {int page = 1, int limit = 20}) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/posts/hashtag/$hashtag?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => PostModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts by hashtag');
    }
  }
}
