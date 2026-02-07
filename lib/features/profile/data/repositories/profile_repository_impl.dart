import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../../../../core/data/mock_data.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final bool useMockData;
  static UserProfile? _cachedMockProfile;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    this.useMockData = false,
  });

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getMockCurrentUser();
    }
    return remoteDataSource.getCurrentUserProfile();
  }

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getMockUserProfile(userId);
    }
    return remoteDataSource.getUserProfile(userId);
  }

  @override
  Future<UserProfile> updateProfile({
    String? displayName,
    String? username,
    Nullable<String>? bio,
    Nullable<String>? website,
    Nullable<String>? location,
    Nullable<String>? phoneNumber,
    Nullable<String>? email,
    Nullable<String>? nationalId,
    Nullable<String>? nationalIdImageUrl,
    Nullable<IdDocumentType>? idDocumentType,
    Nullable<DateTime>? dateOfBirth,
    List<String>? interests,
    Nullable<Map<String, String>>? socialLinks,
    bool? isVerified,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      final currentProfile = _getMockCurrentUser();
      _cachedMockProfile = currentProfile.copyWith(
        displayName: displayName ?? currentProfile.displayName,
        username: username ?? currentProfile.username,
        bio: bio,
        website: website,
        location: location,
        phoneNumber: phoneNumber,
        email: email,
        nationalId: nationalId,
        nationalIdImageUrl: nationalIdImageUrl,
        idDocumentType: idDocumentType,
        dateOfBirth: dateOfBirth,
        interests: interests,
        socialLinks: socialLinks,
        isVerified: isVerified,
       );
       
      return _cachedMockProfile!;
    }
    
    return remoteDataSource.updateProfile({
      if (displayName != null) 'displayName': displayName,
      if (username != null) 'username': username,
      if (bio != null) 'bio': bio.value,
      if (website != null) 'website': website.value,
      if (location != null) 'location': location.value,
      if (phoneNumber != null) 'phoneNumber': phoneNumber.value,
      if (email != null) 'email': email.value,
      if (nationalId != null) 'nationalId': nationalId.value,
      if (nationalIdImageUrl != null) 'nationalIdImageUrl': nationalIdImageUrl.value,
      if (idDocumentType != null) 'idDocumentType': idDocumentType.value?.name,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.value?.toIso8601String(),
      if (interests != null) 'interests': interests,
      if (socialLinks != null) 'socialLinks': socialLinks.value,
      if (isVerified != null) 'isVerified': isVerified,
    });
  }

  @override
  Future<String> updateAvatar(String imagePath) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      await Future.delayed(const Duration(milliseconds: 800));
      // In a real app we would use the file path, but for mock, we return a web URL valid for network image
      // Or we can return the path if we handle FileImage in UI.
      // The UI shows using FileImage if path is local, so this must return the SERVER url.
      // For mock, we simply update the profile with the "new" URL which points to a random image.
      const newUrl = 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400';
      _cachedMockProfile = _getMockCurrentUser().copyWith(avatarUrl: Nullable(newUrl));
      return newUrl;
    }
    return remoteDataSource.updateAvatar(imagePath);
  }

  @override
  Future<String> updateCoverImage(String imagePath) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 800));
      const newUrl = 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800';
      _cachedMockProfile = _getMockCurrentUser().copyWith(coverImageUrl: Nullable(newUrl));
      return newUrl;
    }
    return remoteDataSource.updateCoverImage(imagePath);
  }

  @override
  Future<UserProfile> followUser(String userId) async {
    if (useMockData) {
      final user = _getMockUserProfile(userId);
      return user.copyWith(
        isFollowing: true,
        followersCount: user.followersCount + 1,
      );
    }
    return remoteDataSource.followUser(userId);
  }

  @override
  Future<UserProfile> unfollowUser(String userId) async {
    if (useMockData) {
      final user = _getMockUserProfile(userId);
      return user.copyWith(
        isFollowing: false,
        followersCount: user.followersCount - 1,
      );
    }
    return remoteDataSource.unfollowUser(userId);
  }

  @override
  Future<List<FollowUser>> getFollowers(String userId, {int page = 1, int limit = 20}) async {
    if (useMockData) {
      return _getMockFollowers();
    }
    return remoteDataSource.getFollowers(userId, page: page, limit: limit);
  }

  @override
  Future<List<FollowUser>> getFollowing(String userId, {int page = 1, int limit = 20}) async {
    if (useMockData) {
      return _getMockFollowing();
    }
    return remoteDataSource.getFollowing(userId, page: page, limit: limit);
  }

  @override
  Future<List<FollowUser>> searchUsers(String query, {int page = 1, int limit = 20}) async {
    if (useMockData) {
      return _getMockFollowers().where((u) => 
        u.displayName.toLowerCase().contains(query.toLowerCase()) ||
        u.username.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    return remoteDataSource.searchUsers(query, page: page, limit: limit);
  }

  @override
  Future<List<FollowUser>> getSuggestedUsers({int limit = 10}) async {
    if (useMockData) {
      return _getMockSuggestedUsers();
    }
    return remoteDataSource.getSuggestedUsers(limit: limit);
  }

  @override
  Future<void> blockUser(String userId) async {
    if (useMockData) return;
    await remoteDataSource.blockUser(userId);
  }

  @override
  Future<void> unblockUser(String userId) async {
    if (useMockData) return;
    await remoteDataSource.unblockUser(userId);
  }

  @override
  Future<List<FollowUser>> getBlockedUsers() async {
    if (useMockData) return [];
    return remoteDataSource.getBlockedUsers();
  }

  @override
  Future<void> reportUser(String userId, String reason) async {
    if (useMockData) return;
    await remoteDataSource.reportUser(userId, reason);
  }

  @override
  Future<void> updatePrivacySettings({bool? isPrivate}) async {
    if (useMockData) return;
    await remoteDataSource.updateProfile({'isPrivate': isPrivate});
  }

  @override
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    if (useMockData) return;
    await remoteDataSource.updateProfile({'notificationSettings': settings}    );
  }

  UserProfile _getMockCurrentUser() {
    if (_cachedMockProfile != null) {
      return _cachedMockProfile!;
    }
    
    _cachedMockProfile = MockData.currentUser;
    return _cachedMockProfile!;
  }

  UserProfile _getMockUserProfile(String userId) {
    if (userId == 'currentUser' || userId == MockData.currentUser.id) {
       return _getMockCurrentUser();
    }
    // Return from MockData followers as simple check
    final found = MockData.followers.firstWhere((e) => e.id == userId, orElse: () => MockData.following.firstWhere((e) => e.id == userId, orElse: () => MockData.followers.first));
    
    return UserProfile(
      id: found.id,
      username: found.username,
      displayName: found.displayName,
      avatarUrl: found.avatarUrl,
      isVerified: found.isVerified,
      bio: found.bio,
      isFollowing: found.isFollowing,
      followersCount: 100,
      followingCount: 50,
      postsCount: 10, 
      createdAt: DateTime.now(),
    );
  }

  List<FollowUser> _getMockFollowers() {
    return MockData.followers;
  }

  List<FollowUser> _getMockFollowing() {
    return MockData.following;
  }

  List<FollowUser> _getMockSuggestedUsers() {
    return MockData.suggestedUsers;
  }
}
