import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getCurrentUserProfile();
  Future<UserProfileModel> getUserProfile(String userId);
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data);
  Future<String> updateAvatar(String imagePath);
  Future<String> updateCoverImage(String imagePath);
  Future<UserProfileModel> followUser(String userId);
  Future<UserProfileModel> unfollowUser(String userId);
  Future<List<FollowUserModel>> getFollowers(String userId, {int page = 1, int limit = 20});
  Future<List<FollowUserModel>> getFollowing(String userId, {int page = 1, int limit = 20});
  Future<List<FollowUserModel>> searchUsers(String query, {int page = 1, int limit = 20});
  Future<List<FollowUserModel>> getSuggestedUsers({int limit = 10});
  Future<void> blockUser(String userId);
  Future<void> unblockUser(String userId);
  Future<List<FollowUserModel>> getBlockedUsers();
  Future<void> reportUser(String userId, String reason);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final http.Client client;
  final String? authToken;

  ProfileRemoteDataSourceImpl({
    required this.client,
    this.authToken,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  @override
  Future<UserProfileModel> getCurrentUserProfile() async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/users/me'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await client.put(
      Uri.parse('${ApiConfig.baseUrl}/users/me'),
      headers: _headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update profile');
    }
  }

  @override
  Future<String> updateAvatar(String imagePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/users/me/avatar'),
    );
    request.headers.addAll(_headers);
    request.files.add(await http.MultipartFile.fromPath('avatar', imagePath));

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['avatarUrl'] as String;
    } else {
      throw Exception('Failed to update avatar');
    }
  }

  @override
  Future<String> updateCoverImage(String imagePath) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/users/me/cover'),
    );
    request.headers.addAll(_headers);
    request.files.add(await http.MultipartFile.fromPath('cover', imagePath));

    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['coverImageUrl'] as String;
    } else {
      throw Exception('Failed to update cover image');
    }
  }

  @override
  Future<UserProfileModel> followUser(String userId) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/follow'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to follow user');
    }
  }

  @override
  Future<UserProfileModel> unfollowUser(String userId) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/follow'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return UserProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to unfollow user');
    }
  }

  @override
  Future<List<FollowUserModel>> getFollowers(String userId, {int page = 1, int limit = 20}) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/followers?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => FollowUserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load followers');
    }
  }

  @override
  Future<List<FollowUserModel>> getFollowing(String userId, {int page = 1, int limit = 20}) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/following?page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => FollowUserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load following');
    }
  }

  @override
  Future<List<FollowUserModel>> searchUsers(String query, {int page = 1, int limit = 20}) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/users/search?q=$query&page=$page&limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => FollowUserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search users');
    }
  }

  @override
  Future<List<FollowUserModel>> getSuggestedUsers({int limit = 10}) async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/users/suggested?limit=$limit'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => FollowUserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load suggested users');
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/block'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to block user');
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    final response = await client.delete(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/block'),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to unblock user');
    }
  }

  @override
  Future<List<FollowUserModel>> getBlockedUsers() async {
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/users/blocked'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => FollowUserModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load blocked users');
    }
  }

  @override
  Future<void> reportUser(String userId, String reason) async {
    final response = await client.post(
      Uri.parse('${ApiConfig.baseUrl}/users/$userId/report'),
      headers: _headers,
      body: json.encode({'reason': reason}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to report user');
    }
  }
}
