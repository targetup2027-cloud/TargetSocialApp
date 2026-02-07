import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';




import '../domain/entities/user_profile.dart';
import '../domain/repositories/profile_repository.dart';

import '../data/repositories/profile_repository_impl.dart';
import '../data/datasources/profile_remote_data_source.dart';
import '../../auth/data/datasources/auth_remote_data_source.dart';
import '../../../core/validation/validators.dart';
import '../../notifications/application/notification_service.dart';
import '../../notifications/application/notifications_controller.dart';
import '../../social/application/current_user_provider.dart';

const int kFollowPageSize = 20;

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  final client = ref.watch(networkClientProvider);
  return ProfileRemoteDataSourceImpl(client: client);
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.watch(profileRemoteDataSourceProvider),
    useMockData: false,
  );
});

final currentUserProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getCurrentUserProfile();
});

final userProfileProvider =
    FutureProvider.family<UserProfile, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getUserProfile(userId);
});

final followersProvider =
    FutureProvider.family<List<FollowUser>, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getFollowers(userId);
});

final followingProvider =
    FutureProvider.family<List<FollowUser>, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getFollowing(userId);
});

final searchUsersProvider =
    FutureProvider.family<List<FollowUser>, String>((ref, query) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.searchUsers(query);
});

final suggestedUsersProvider = FutureProvider<List<FollowUser>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getSuggestedUsers();
});

class ProfileController extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;
  UserProfile? _cachedProfile;
  bool _isUpdating = false;

  ProfileController(this._repository) : super(AsyncValue.data(_createDefaultProfile())) {
    // Start with default profile, then load real data
    _loadRealProfile();
  }

  static UserProfile _createDefaultProfile() {
    return UserProfile(
      id: 'current_user',
      username: 'user',
      displayName: 'User',
      email: null,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _loadRealProfile() async {
    try {
      final profile = await _repository.getCurrentUserProfile();
      _cachedProfile = profile;
      if (mounted) {
        state = AsyncValue.data(profile);
      }
    } catch (e) {
      // Keep the default profile on error
      _cachedProfile = state.valueOrNull;
    }
  }

  UserProfile _createFallbackProfile() {
    return UserProfile(
      id: 'current_user',
      username: 'user',
      displayName: 'New User',
      email: null,
      createdAt: DateTime.now(),
    );
  }

  Future<void> loadCurrentUser({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedProfile != null) {
      state = AsyncValue.data(_cachedProfile!);
      return;
    }

    try {
      final profile = await _repository.getCurrentUserProfile();
      _cachedProfile = profile;
      state = AsyncValue.data(profile);
    } catch (e) {
      if (_cachedProfile != null) {
        state = AsyncValue.data(_cachedProfile!);
      } else {
        _cachedProfile = _createFallbackProfile();
        state = AsyncValue.data(_cachedProfile!);
      }
    }
  }

  Future<void> updateProfile({
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
    if (_isUpdating) return;
    _isUpdating = true;

    final previousProfile = _cachedProfile ?? state.valueOrNull;

    try {
      final validations = <ValidationResult>[];

      if (displayName != null) {
        validations.add(Validators.combine([
          Validators.minLength(displayName, 2, fieldName: 'Display Name'),
          Validators.maxLength(displayName, 50, fieldName: 'Display Name'),
        ]));
      }

      if (username != null) {
        validations.add(Validators.combine([
          Validators.minLength(username, 3, fieldName: 'Username'),
          Validators.maxLength(username, 30, fieldName: 'Username'),
        ]));
      }

      if (bio != null && bio.value != null) {
        validations.add(Validators.maxLength(bio.value!, 160, fieldName: 'Bio'));
      }

      if (website != null && website.value != null && website.value!.isNotEmpty) {
        validations.add(Validators.url(website.value!, fieldName: 'Website'));
      }

      if (email != null && email.value != null && email.value!.isNotEmpty) {
        validations.add(Validators.email(email.value!));
      }

      final invalidResult = validations.cast<ValidationResult?>().firstWhere(
        (v) => !v!.isValid,
        orElse: () => null,
      );
      if (invalidResult != null) {
        throw Exception(invalidResult.errorMessage);
      }

      if (previousProfile != null) {
        final optimisticProfile = previousProfile.copyWith(
          displayName: displayName,
          username: username,
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
        state = AsyncValue.data(optimisticProfile);
      } else {
         state = const AsyncValue.loading();
      }

      final updatedProfile = await _repository.updateProfile(
        displayName: displayName?.trim(),
        username: username?.trim(),
        bio: bio != null ? Nullable(bio.value?.trim()) : null,
        website: website != null ? Nullable(website.value?.trim()) : null,
        location: location != null ? Nullable(location.value?.trim()) : null,
        phoneNumber: phoneNumber != null ? Nullable(phoneNumber.value?.trim()) : null,
        email: email != null ? Nullable(email.value?.trim()) : null,
        nationalId: nationalId != null ? Nullable(nationalId.value?.trim()) : null,
        nationalIdImageUrl: nationalIdImageUrl,
        idDocumentType: idDocumentType,
        dateOfBirth: dateOfBirth,
        interests: interests,
        socialLinks: socialLinks,
        isVerified: isVerified,
      );

      _cachedProfile = updatedProfile;
      state = AsyncValue.data(updatedProfile);
    } catch (e) {
      if (previousProfile != null) {
        state = AsyncValue.data(previousProfile);
      } else {
        state = AsyncValue.error(e, StackTrace.current);
      }
      rethrow;
    } finally {
      _isUpdating = false;
    }
  }

  Future<void> updateAvatar(String imagePath) async {
    try {
      final newAvatarUrl = await _repository.updateAvatar(imagePath);
      final currentProfile = state.valueOrNull ?? _cachedProfile;
      if (currentProfile != null) {
        final updated = currentProfile.copyWith(avatarUrl: Nullable(newAvatarUrl));
        _cachedProfile = updated;
        state = AsyncValue.data(updated);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCoverImage(String imagePath) async {
    try {
      final newCoverUrl = await _repository.updateCoverImage(imagePath);
      final currentProfile = state.valueOrNull ?? _cachedProfile;
      if (currentProfile != null) {
        final updated = currentProfile.copyWith(coverImageUrl: Nullable(newCoverUrl));
        _cachedProfile = updated;
        state = AsyncValue.data(updated);
      }
    } catch (e) {
      rethrow;
    }
  }



  Future<void> updateNationalIdImage(String imagePath) async {
    try {
      await updateProfile(nationalIdImageUrl: Nullable(imagePath));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateIdDocumentType(IdDocumentType type) async {
    try {
      await updateProfile(idDocumentType: Nullable(type));
    } catch (e) {
      rethrow;
    }
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, AsyncValue<UserProfile>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileController(repository);
});

class UserProfileController extends StateNotifier<AsyncValue<UserProfile>> {
  final ProfileRepository _repository;
  final String userId;
  final Ref _ref;
  bool _isToggling = false;

  UserProfileController(this._repository, this.userId, this._ref)
      : super(const AsyncValue.loading()) {
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
    if (_isToggling) return;

    final currentProfile = state.valueOrNull;
    if (currentProfile == null) return;

    _isToggling = true;

    final wasFollowing = currentProfile.isFollowing;

    final optimisticProfile = currentProfile.copyWith(
      isFollowing: !wasFollowing,
      followersCount: wasFollowing
          ? max(0, currentProfile.followersCount - 1)
          : currentProfile.followersCount + 1,
    );
    state = AsyncValue.data(optimisticProfile);

    try {
      final serverProfile = wasFollowing
          ? await _repository.unfollowUser(userId)
          : await _repository.followUser(userId);
      state = AsyncValue.data(serverProfile);

      final currentUserId = _ref.read(currentUserIdProvider);
      final currentUserProfile = _ref.read(profileControllerProvider).valueOrNull;
      final notificationsRepo = _ref.read(notificationsRepositoryProvider);
      final notificationService = NotificationService(notificationsRepo);

      if (!wasFollowing) {
        await notificationService.createFollowNotification(
          actorUserId: currentUserId,
          actorDisplayName: currentUserProfile?.displayName ?? 'Someone',
          actorAvatarUrl: currentUserProfile?.avatarUrl,
          targetUserId: userId,
        );
      }
    } catch (_) {
      state = AsyncValue.data(currentProfile);
    } finally {
      _isToggling = false;
    }
  }
}

final userProfileControllerProvider = StateNotifierProvider.family<
    UserProfileController, AsyncValue<UserProfile>, String>((ref, userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return UserProfileController(repository, userId, ref);
});

class FollowListController extends StateNotifier<AsyncValue<List<FollowUser>>> {
  final ProfileRepository _repository;
  final String userId;
  final bool isFollowers;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  FollowListController(this._repository, this.userId, this.isFollowers)
      : super(const AsyncValue.loading()) {
    loadList();
  }

  Future<void> loadList() async {
    state = const AsyncValue.loading();
    try {
      final users = isFollowers
          ? await _repository.getFollowers(userId, page: 1)
          : await _repository.getFollowing(userId, page: 1);

      _currentPage = 1;
      _hasMore = users.length >= kFollowPageSize;
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore) return;

    final currentUsers = state.valueOrNull ?? [];
    _isLoadingMore = true;

    try {
      final nextPage = _currentPage + 1;
      final newUsers = isFollowers
          ? await _repository.getFollowers(userId, page: nextPage)
          : await _repository.getFollowing(userId, page: nextPage);

      _currentPage = nextPage;
      _hasMore = newUsers.length >= kFollowPageSize;

      state = AsyncValue.data([...currentUsers, ...newUsers]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      state = AsyncValue.data(currentUsers);
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> toggleFollow(String targetUserId) async {
    final currentUsers = state.valueOrNull ?? [];
    final index = currentUsers.indexWhere((u) => u.id == targetUserId);
    if (index < 0) return;

    final user = currentUsers[index];
    final wasFollowing = user.isFollowing;

    final optimisticUsers = [...currentUsers];
    optimisticUsers[index] = user.copyWith(isFollowing: !wasFollowing);
    state = AsyncValue.data(optimisticUsers);

    try {
      if (wasFollowing) {
        await _repository.unfollowUser(targetUserId);
      } else {
        await _repository.followUser(targetUserId);
      }
    } catch (_) {
      final revertUsers = [...(state.valueOrNull ?? optimisticUsers)];
      final revertIndex = revertUsers.indexWhere((u) => u.id == targetUserId);
      if (revertIndex >= 0) {
        revertUsers[revertIndex] = user;
      }
      state = AsyncValue.data(revertUsers);
    }
  }
}

final followersControllerProvider = StateNotifierProvider.family<
    FollowListController, AsyncValue<List<FollowUser>>, String>((ref, userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return FollowListController(repository, userId, true);
});

final followingControllerProvider = StateNotifierProvider.family<
    FollowListController, AsyncValue<List<FollowUser>>, String>((ref, userId) {
  final repository = ref.watch(profileRepositoryProvider);
  return FollowListController(repository, userId, false);
});
