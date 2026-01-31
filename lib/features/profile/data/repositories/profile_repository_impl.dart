import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  final bool useMockData;

  ProfileRepositoryImpl({
    required this.remoteDataSource,
    this.useMockData = false,
  });

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    if (useMockData) {
      return _getMockCurrentUser();
    }
    return remoteDataSource.getCurrentUserProfile();
  }

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    if (useMockData) {
      return _getMockUserProfile(userId);
    }
    return remoteDataSource.getUserProfile(userId);
  }

  @override
  Future<UserProfile> updateProfile({
    String? displayName,
    String? bio,
    String? website,
    String? location,
    DateTime? dateOfBirth,
    List<String>? interests,
    Map<String, String>? socialLinks,
  }) async {
    if (useMockData) {
      return _getMockCurrentUser().copyWith(
        displayName: displayName,
        bio: bio,
        website: website,
        location: location,
        dateOfBirth: dateOfBirth,
        interests: interests,
        socialLinks: socialLinks,
      );
    }
    
    return remoteDataSource.updateProfile({
      if (displayName != null) 'displayName': displayName,
      if (bio != null) 'bio': bio,
      if (website != null) 'website': website,
      if (location != null) 'location': location,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth.toIso8601String(),
      if (interests != null) 'interests': interests,
      if (socialLinks != null) 'socialLinks': socialLinks,
    });
  }

  @override
  Future<String> updateAvatar(String imagePath) async {
    if (useMockData) {
      return 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400';
    }
    return remoteDataSource.updateAvatar(imagePath);
  }

  @override
  Future<String> updateCoverImage(String imagePath) async {
    if (useMockData) {
      return 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800';
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
    await remoteDataSource.updateProfile({'notificationSettings': settings});
  }

  UserProfile _getMockCurrentUser() {
    return UserProfile(
      id: 'currentUser',
      username: 'johndoe',
      displayName: 'John Doe',
      email: 'john@example.com',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      coverImageUrl: 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=800',
      bio: 'Building the future, one line of code at a time 🚀',
      website: 'https://johndoe.dev',
      location: 'San Francisco, CA',
      isVerified: true,
      followersCount: 1234,
      followingCount: 567,
      postsCount: 89,
      createdAt: DateTime(2023, 1, 15),
      interests: ['Technology', 'Design', 'Photography'],
      socialLinks: {
        'twitter': 'johndoe',
        'github': 'johndoe',
        'linkedin': 'in/johndoe',
      },
    );
  }

  UserProfile _getMockUserProfile(String userId) {
    final profiles = {
      'user1': UserProfile(
        id: 'user1',
        username: 'sarahj',
        displayName: 'Sarah Johnson',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108755-cbb6b1809933?w=150',
        bio: 'Photographer | Traveler | Coffee lover',
        isVerified: true,
        followersCount: 5432,
        followingCount: 234,
        postsCount: 156,
        createdAt: DateTime(2022, 6, 10),
      ),
      'user2': UserProfile(
        id: 'user2',
        username: 'techinsider',
        displayName: 'Tech Insider',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        bio: 'Your daily dose of tech news and insights',
        isVerified: true,
        followersCount: 125000,
        followingCount: 50,
        postsCount: 2340,
        createdAt: DateTime(2020, 3, 1),
      ),
    };
    
    return profiles[userId] ?? _getMockCurrentUser();
  }

  List<FollowUser> _getMockFollowers() {
    return [
      const FollowUser(
        id: 'user3',
        username: 'alexr',
        displayName: 'Alex Rivera',
        avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        isVerified: false,
        isFollowing: true,
        bio: 'Software Developer',
      ),
      const FollowUser(
        id: 'user4',
        username: 'emilyd',
        displayName: 'Emily Davis',
        avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        isVerified: true,
        isFollowing: false,
        bio: 'UX Designer @ Google',
      ),
      const FollowUser(
        id: 'user5',
        username: 'mikec',
        displayName: 'Mike Chen',
        avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        isVerified: false,
        isFollowing: true,
        bio: 'Entrepreneur | Investor',
      ),
    ];
  }

  List<FollowUser> _getMockFollowing() {
    return [
      const FollowUser(
        id: 'user1',
        username: 'sarahj',
        displayName: 'Sarah Johnson',
        avatarUrl: 'https://images.unsplash.com/photo-1494790108755-cbb6b1809933?w=150',
        isVerified: true,
        isFollowing: true,
        bio: 'Photographer | Traveler',
      ),
      const FollowUser(
        id: 'user2',
        username: 'techinsider',
        displayName: 'Tech Insider',
        avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        isVerified: true,
        isFollowing: true,
        bio: 'Tech news and insights',
      ),
    ];
  }

  List<FollowUser> _getMockSuggestedUsers() {
    return [
      const FollowUser(
        id: 'user6',
        username: 'designhub',
        displayName: 'Design Hub',
        avatarUrl: 'https://images.unsplash.com/photo-1557862921-37829c790f19?w=150',
        isVerified: true,
        isFollowing: false,
        bio: 'Design inspiration daily',
      ),
      const FollowUser(
        id: 'user7',
        username: 'startuplife',
        displayName: 'Startup Life',
        avatarUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcabd36?w=150',
        isVerified: false,
        isFollowing: false,
        bio: 'Stories from the startup world',
      ),
    ];
  }
}
