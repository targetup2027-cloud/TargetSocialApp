import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';

abstract class PostsLocalDataSource {
  Future<List<PostModel>> getCachedFeed();
  Future<void> cacheFeed(List<PostModel> posts);
  Future<List<PostModel>> getCachedUserPosts(String userId);
  Future<void> cacheUserPosts(String userId, List<PostModel> posts);
  Future<PostModel?> getCachedPost(String postId);
  Future<void> cachePost(PostModel post);
  Future<void> clearCache();
  Future<List<String>> getBookmarkedPostIds();
  Future<void> addBookmark(String postId);
  Future<void> removeBookmark(String postId);
  Future<List<PostModel>> getDraftPosts();
  Future<void> saveDraftPost(PostModel post);
  Future<void> deleteDraftPost(String postId);
}

class PostsLocalDataSourceImpl implements PostsLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String feedCacheKey = 'CACHED_FEED_V2';
  static const String userPostsCachePrefix = 'CACHED_USER_POSTS_V2_';
  static const String postCachePrefix = 'CACHED_POST_V2_';
  static const String bookmarksKey = 'BOOKMARKED_POSTS';
  static const String draftsKey = 'DRAFT_POSTS';

  PostsLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<PostModel>> getCachedFeed() async {
    final jsonString = sharedPreferences.getString(feedCacheKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheFeed(List<PostModel> posts) async {
    final jsonList = posts.map((post) => post.toJson()).toList();
    await sharedPreferences.setString(feedCacheKey, json.encode(jsonList));
  }

  @override
  Future<List<PostModel>> getCachedUserPosts(String userId) async {
    final jsonString = sharedPreferences.getString('$userPostsCachePrefix$userId');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheUserPosts(String userId, List<PostModel> posts) async {
    final jsonList = posts.map((post) => post.toJson()).toList();
    await sharedPreferences.setString('$userPostsCachePrefix$userId', json.encode(jsonList));
  }

  @override
  Future<PostModel?> getCachedPost(String postId) async {
    final jsonString = sharedPreferences.getString('$postCachePrefix$postId');
    if (jsonString != null) {
      return PostModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> cachePost(PostModel post) async {
    await sharedPreferences.setString('$postCachePrefix${post.id}', json.encode(post.toJson()));
  }

  @override
  Future<void> clearCache() async {
    final keys = sharedPreferences.getKeys();
    for (final key in keys) {
      if (key.startsWith(feedCacheKey) || 
          key.startsWith(userPostsCachePrefix) || 
          key.startsWith(postCachePrefix)) {
        await sharedPreferences.remove(key);
      }
    }
  }

  @override
  Future<List<String>> getBookmarkedPostIds() async {
    return sharedPreferences.getStringList(bookmarksKey) ?? [];
  }

  @override
  Future<void> addBookmark(String postId) async {
    final bookmarks = await getBookmarkedPostIds();
    if (!bookmarks.contains(postId)) {
      bookmarks.add(postId);
      await sharedPreferences.setStringList(bookmarksKey, bookmarks);
    }
  }

  @override
  Future<void> removeBookmark(String postId) async {
    final bookmarks = await getBookmarkedPostIds();
    bookmarks.remove(postId);
    await sharedPreferences.setStringList(bookmarksKey, bookmarks);
  }

  @override
  Future<List<PostModel>> getDraftPosts() async {
    final jsonString = sharedPreferences.getString(draftsKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> saveDraftPost(PostModel post) async {
    final drafts = await getDraftPosts();
    final index = drafts.indexWhere((d) => d.id == post.id);
    if (index >= 0) {
      drafts[index] = post;
    } else {
      drafts.add(post);
    }
    final jsonList = drafts.map((d) => d.toJson()).toList();
    await sharedPreferences.setString(draftsKey, json.encode(jsonList));
  }

  @override
  Future<void> deleteDraftPost(String postId) async {
    final drafts = await getDraftPosts();
    drafts.removeWhere((d) => d.id == postId);
    final jsonList = drafts.map((d) => d.toJson()).toList();
    await sharedPreferences.setString(draftsKey, json.encode(jsonList));
  }
}
