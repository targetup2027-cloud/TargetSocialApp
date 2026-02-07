import '../../../../core/network/network_client.dart';
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
  final NetworkClient _client;

  ProfileRemoteDataSourceImpl({required NetworkClient client}) : _client = client;

  UserProfileModel _parseProfile(dynamic response) {
    final data = response['data'] ?? response;
    return UserProfileModel.fromJson(data as Map<String, dynamic>);
  }

  List<FollowUserModel> _parseFollowList(dynamic response) {
    final List<dynamic> data = response['data'] ?? response;
    return data
        .map((json) => FollowUserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<UserProfileModel> getCurrentUserProfile() async {
    final response = await _client.get('/api/Users/me');
    return _parseProfile(response);
  }

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    final response = await _client.get('/api/Users/$userId');
    return _parseProfile(response);
  }

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.put('/api/Users/me', data: data);
    return _parseProfile(response);
  }

  @override
  Future<String> updateAvatar(String imagePath) async {
    // TODO: Implement multipart upload via Dio directly when needed
    // Backend expects: PUT /api/Users/me/avatar with multipart form data
    final response = await _client.put('/api/Users/me/avatar', data: {
      'avatarPath': imagePath,
    });
    final data = response['data'] ?? response;
    return (data is Map) ? (data['profilePictureUrl'] as String? ?? '') : '';
  }

  @override
  Future<String> updateCoverImage(String imagePath) async {
    // TODO: Implement multipart upload via Dio directly when needed
    // Backend expects: PUT /api/Users/me/cover with multipart form data
    final response = await _client.put('/api/Users/me/cover', data: {
      'coverPath': imagePath,
    });
    final data = response['data'] ?? response;
    return (data is Map) ? (data['coverImageUrl'] as String? ?? '') : '';
  }

  @override
  Future<UserProfileModel> followUser(String userId) async {
    final response = await _client.post('/api/Users/$userId/follow');
    return _parseProfile(response);
  }

  @override
  Future<UserProfileModel> unfollowUser(String userId) async {
    final response = await _client.delete('/api/Users/$userId/unfollow');
    return _parseProfile(response);
  }

  @override
  Future<List<FollowUserModel>> getFollowers(String userId, {int page = 1, int limit = 20}) async {
    final response = await _client.get('/api/Friends/$userId/followers');
    return _parseFollowList(response);
  }

  @override
  Future<List<FollowUserModel>> getFollowing(String userId, {int page = 1, int limit = 20}) async {
    final response = await _client.get('/api/Friends/$userId/following');
    return _parseFollowList(response);
  }

  @override
  Future<List<FollowUserModel>> searchUsers(String query, {int page = 1, int limit = 20}) async {
    final response = await _client.get(
      '/api/Search/users',
      queryParameters: {'query': query},
    );
    return _parseFollowList(response);
  }

  @override
  Future<List<FollowUserModel>> getSuggestedUsers({int limit = 10}) async {
    final response = await _client.get('/api/Friends/suggestions');
    return _parseFollowList(response);
  }

  @override
  Future<void> blockUser(String userId) async {
    await _client.post('/api/privacy/users/$userId/block');
  }

  @override
  Future<void> unblockUser(String userId) async {
    await _client.post('/api/Users/$userId/unblock');
  }

  @override
  Future<List<FollowUserModel>> getBlockedUsers() async {
    final response = await _client.get('/api/privacy/users/blocked');
    return _parseFollowList(response);
  }

  @override
  Future<void> reportUser(String userId, String reason) async {
    await _client.post('/api/Users/$userId/report', data: {
      'reason': reason,
    });
  }
}
