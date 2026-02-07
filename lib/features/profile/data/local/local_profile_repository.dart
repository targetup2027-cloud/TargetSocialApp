import 'dart:async';
import 'dart:math';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../../core/data/mock_data.dart';
import '../../../social/data/local/local_posts_repository.dart';

class LocalProfileRepository implements ProfileRepository {
  UserProfile _currentUser;
  final List<FollowUser> _followers;
  final List<FollowUser> _following;
  final List<FollowUser> _suggested;

  LocalProfileRepository()
      : _currentUser = MockData.currentUser,
        _followers = List.from(MockData.followers),
        _following = List.from(MockData.following),
        _suggested = List.from(MockData.suggestedUsers);

  // Fake network delay
  Future<void> _delay() async {
    await Future.delayed(Duration(milliseconds: 50 + Random().nextInt(100)));
  }

  @override
  Future<UserProfile> getCurrentUserProfile() async {
    await _delay();
    final postsCount = LocalPostsRepository.instance.getUserPostsCount(_currentUser.id);
    return _currentUser.copyWith(
      followersCount: _followers.length,
      followingCount: _following.length,
      postsCount: postsCount,
    );
  }

  @override
  Future<UserProfile> getUserProfile(String userId) async {
    await _delay();
    if (userId == 'currentUser' || userId == _currentUser.id) {
      return _currentUser;
    }
    
    FollowUser? found;
    for (final user in _followers) {
      if (user.id == userId) {
        found = user;
        break;
      }
    }
    if (found == null) {
      for (final user in _following) {
        if (user.id == userId) {
          found = user;
          break;
        }
      }
    }
    if (found == null) {
      for (final user in _suggested) {
        if (user.id == userId) {
          found = user;
          break;
        }
      }
    }

    if (found != null) {
      return UserProfile(
        id: found.id,
        username: found.username,
        displayName: found.displayName,
        avatarUrl: found.avatarUrl,
        isVerified: found.isVerified,
        bio: found.bio,
        isFollowing: found.isFollowing,
        followersCount: 10 + Random().nextInt(1000),
        followingCount: 5 + Random().nextInt(500),
        postsCount: Random().nextInt(50),
        createdAt: DateTime.now().subtract(const Duration(days: 100)),
      );
    }

    return UserProfile(
      id: userId,
      username: 'user_$userId',
      displayName: 'User $userId',
      avatarUrl: 'https://i.pravatar.cc/150?u=$userId',
      isVerified: false,
      bio: null,
      isFollowing: false,
      followersCount: Random().nextInt(100),
      followingCount: Random().nextInt(50),
      postsCount: Random().nextInt(20),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
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
    await _delay();
    _currentUser = _currentUser.copyWith(
      displayName: displayName ?? _currentUser.displayName,
      username: username ?? _currentUser.username,
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
    return _currentUser;
  }

  @override
  Future<String> updateAvatar(String imagePath) async {
    await _delay();
    // In local mode, we return the path itself to be displayed via FileImage (or handled by UI)
    // However, the Model expects a URL string. 
    // We will store the path. The UI needs to handle "if !http then File".
    _currentUser = _currentUser.copyWith(avatarUrl: Nullable(imagePath));
    return imagePath;
  }

  @override
  Future<String> updateCoverImage(String imagePath) async {
    await _delay();
    _currentUser = _currentUser.copyWith(coverImageUrl: Nullable(imagePath));
    return imagePath;
  }

  @override
  Future<UserProfile> followUser(String userId) async {
    await _delay();
    final user = await getUserProfile(userId);
    
    // Add to following list if not already following
    if (!_following.any((u) => u.id == userId)) {
      _following.add(FollowUser(
        id: user.id,
        username: user.username,
        displayName: user.displayName,
        avatarUrl: user.avatarUrl,
        isVerified: user.isVerified,
        isFollowing: true,
        bio: user.bio,
      ));
    }
    
    return user.copyWith(isFollowing: true, followersCount: user.followersCount + 1);
  }

  @override
  Future<UserProfile> unfollowUser(String userId) async {
    await _delay();
    final user = await getUserProfile(userId);
    
    // Remove from following list
    _following.removeWhere((u) => u.id == userId);
    
    return user.copyWith(isFollowing: false, followersCount: max(0, user.followersCount - 1));
  }

  @override
  Future<List<FollowUser>> getFollowers(String userId, {int page = 1, int limit = 20}) async {
    await _delay();
    return _followers;
  }

  @override
  Future<List<FollowUser>> getFollowing(String userId, {int page = 1, int limit = 20}) async {
    await _delay();
    return _following;
  }

  @override
  Future<List<FollowUser>> searchUsers(String query, {int page = 1, int limit = 20}) async {
    await _delay();
    final q = query.toLowerCase();
    final all = [..._followers, ..._following, ..._suggested];
    return all.where((u) => 
      u.displayName.toLowerCase().contains(q) || 
      u.username.toLowerCase().contains(q)
    ).toList();
  }

  @override
  Future<List<FollowUser>> getSuggestedUsers({int limit = 10}) async {
    await _delay();
    return _suggested;
  }

  @override
  Future<void> blockUser(String userId) async {
    await _delay();
  }

  @override
  Future<void> unblockUser(String userId) async {
    await _delay();
  }

  @override
  Future<List<FollowUser>> getBlockedUsers() async {
    await _delay();
    return [];
  }

  @override
  Future<void> reportUser(String userId, String reason) async {
    await _delay();
  }

  @override
  Future<void> updatePrivacySettings({bool? isPrivate}) async {
    await _delay();
    if (isPrivate != null) {
      _currentUser = _currentUser.copyWith(isPrivate: isPrivate);
    }
  }

  @override
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    await _delay();
    // No field in UserProfile for this, ignoring
  }
}
