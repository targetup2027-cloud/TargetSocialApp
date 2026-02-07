import '../entities/post.dart';
import '../../models/post_data.dart';

abstract class PostsRepository {
  Future<List<Post>> getFeed({int page = 1, int limit = 20});
  
  Future<List<Post>> getDiscoverFeed({int page = 1, int limit = 20});
  
  Future<List<Post>> getUserPosts(String userId, {int page = 1, int limit = 20});
  
  Future<Post> getPostById(String postId);
  
  Future<Post> createPost({
    required String content,
    List<String>? mediaUrls,
    String? mediaType,
    String? location,
  });
  
  Future<Post> updatePost(String postId, {String? content});
  
  Future<void> deletePost(String postId);
  
  Future<Post> likePost(String postId);
  
  Future<Post> unlikePost(String postId);
  
  /// Increment view count for a post (called when post becomes visible)
  Future<void> incrementViews(String postId);
  
  /// React to a post with a specific reaction type
  Future<Post> reactToPost(String postId, ReactionType type);
  
  /// Remove reaction from a post
  Future<Post> removeReaction(String postId);
  
  Future<Post> bookmarkPost(String postId);
  
  Future<Post> unbookmarkPost(String postId);
  
  Future<List<Post>> getBookmarkedPosts({int page = 1, int limit = 20});
  
  Future<List<Comment>> getComments(String postId, {int page = 1, int limit = 20});
  
  Future<Comment> addComment(String postId, String content, {String? parentCommentId});
  
  Future<Comment> updateComment(String postId, String commentId, String content);
  
  Future<void> deleteComment(String postId, String commentId);
  
  Future<Comment> likeComment(String commentId);
  
  Future<Comment> unlikeComment(String commentId);
  
  Future<void> sharePost(String postId);
  
  Future<List<Post>> searchPosts(String query, {int page = 1, int limit = 20});
  
  Future<List<Post>> getPostsByHashtag(String hashtag, {int page = 1, int limit = 20});
}
