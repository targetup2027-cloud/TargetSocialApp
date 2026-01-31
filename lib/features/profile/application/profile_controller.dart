import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../domain/entities/user_profile.dart';
import '../domain/repositories/profile_repository.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../data/datasources/profile_remote_data_source.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ProfileRemoteDataSourceImpl(client: http.Client()),
    useMockData: true,
  );
});

final currentUserProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getCurrentUserProfile();
});

final userProfileProvider = FutureProvider.family<UserProfile, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfile(userId);
});

final followersProvider = FutureProvider.family<List<FollowUser>, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getFollowers(userId);
});

final followingProvider = FutureProvider.family<List<FollowUser>, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getFollowing(userId);
});

final searchUsersProvider = FutureProvider.family<List<FollowUser>, String>((ref, query) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.searchUsers(query);
});

final suggestedUsersProvider = FutureProvider<List<FollowUser>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getSuggestedUsers();
});

class ProfileController extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;

  ProfileController(this._repository) : super(const AsyncValue.loading()) {
    loadCurrentUser();
  }

  Future<void> loadCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getCurrentUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? website,
    String? location,
  }) async {
    try {
      final updatedProfile = await _repository.updateProfile(
        displayName: displayName,
        bio: bio,
        website: website,
        location: location,
      );
      state = AsyncValue.data(updatedProfile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAvatar(String imagePath) async {
    try {
      final newAvatarUrl = await _repository.updateAvatar(imagePath);
      final currentProfile = state.valueOrNull;
      if (currentProfile != null) {
        state = AsyncValue.data(currentProfile.copyWith(avatarUrl: newAvatarUrl));
      }
    } catch (e) {
      
    }
  }

  Future<void> updateCoverImage(String imagePath) async {
    try {
      final newCoverUrl = await _repository.updateCoverImage(imagePath);
      final currentProfile = state.valueOrNull;
      if (currentProfile != null) {
        state = AsyncValue.data(currentProfile.copyWith(coverImageUrl: newCoverUrl));
      }
    } catch (e) {
      
    }
  }
}

final profileControllerProvider = StateNotifierProvider<ProfileController, AsyncValue<UserProfile>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileController(repository);
});

class UserProfileController extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;
  final String userId;

  UserProfileController(this._repository, this.userId) : super(const AsyncValue.loading()) {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getUserProfile(userId);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFollow() async {
    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;

    try {
      final updatedProfile = currentProfile.isFollowing
          ? await _repository.unfollowUser(userId)
          : await _repository.followUser(userId);
      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      
    }
  }
}

final userProfileControllerProvider = StateNotifierProvider.family<UserProfileController, AsyncValue<UserProfile>, String>((ref, userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return UserProfileController(repository, userId);
});

class FollowListController extends StateNotifier<AsyncValue<List<FollowUser>>> {
  final ProfileRepository _repository;
  final String userId;
  final bool isFollowers;
  int _currentPage = 1;
  bool _hasMore = true;

  FollowListController(this._repository, this.userId, this.isFollowers) : super(const AsyncValue.loading()) {
    loadList();
  }

  Future<void> loadList() async {
    state = const AsyncValue.loading();
    try {
      final users = isFollowers 
          ? await _repository.getFollowers(userId, page: 1)
          : await _repository.getFollowing(userId, page: 1);
      _currentPage = 1;
      _hasMore = users.length >= 20;
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    final currentUsers = state.valueOrNull ?? [];
    try {
      final newUsers = isFollowers 
          ? await _repository.getFollowers(userId, page: _currentPage + 1)
          : await _repository.getFollowing(userId, page: _currentPage + 1);
      _currentPage++;
      _hasMore = newUsers.length >= 20;
      state = AsyncValue.data([...currentUsers, ...newUsers]);
    } catch (e) {
      
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    final currentUsers = state.valueOrNull ?? [];
    final index = currentUsers.indexWhere((u) => u.id == targetUserId);
    if (index < 0) return;

    final user = currentUsers[index];
    try {
      if (user.isFollowing) {
        await _repository.unfollowUser(targetUserId);
      } else {
        await _repository.followUser(targetUserId);
      }

      final updatedUsers = [...currentUsers];
      updatedUsers[index] = user.copyWith(isFollowing: !user.isFollowing);
      state = AsyncValue.data(updatedUsers);
    } catch (e) {
      
    }
  }
}

final followersControllerProvider = StateNotifierProvider.family<FollowListController, AsyncValue<List<FollowUser>>, String>((ref, userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return FollowListController(repository, userId, true);
});

final followingControllerProvider = StateNotifierProvider.family<FollowListController, AsyncValue<List<FollowUser>>, String>((ref, userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return FollowListController(repository, userId, false);
});
