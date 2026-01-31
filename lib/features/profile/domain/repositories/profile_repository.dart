import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getCurrentUserProfile();
  
  Future<UserProfile> getUserProfile(String userId);
  
  Future<UserProfile> updateProfile({
    String? displayName,
    String? bio,
    String? website,
    String? location,
    DateTime? dateOfBirth,
    List<String>? interests,
    Map<String, String>? socialLinks,
  });
  
  Future<String> updateAvatar(String imagePath);
  
  Future<String> updateCoverImage(String imagePath);
  
  Future<UserProfile> followUser(String userId);
  
  Future<UserProfile> unfollowUser(String userId);
  
  Future<List<FollowUser>> getFollowers(String userId, {int page = 1, int limit = 20});
  
  Future<List<FollowUser>> getFollowing(String userId, {int page = 1, int limit = 20});
  
  Future<List<FollowUser>> searchUsers(String query, {int page = 1, int limit = 20});
  
  Future<List<FollowUser>> getSuggestedUsers({int limit = 10});
  
  Future<void> blockUser(String userId);
  
  Future<void> unblockUser(String userId);
  
  Future<List<FollowUser>> getBlockedUsers();
  
  Future<void> reportUser(String userId, String reason);
  
  Future<void> updatePrivacySettings({bool? isPrivate});
  
  Future<void> updateNotificationSettings(Map<String, bool> settings);
}
