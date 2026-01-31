class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String? coverImageUrl;
  final String? bio;
  final String? website;
  final String? location;
  final DateTime? dateOfBirth;
  final bool isVerified;
  final bool isPrivate;
  final bool isFollowing;
  final bool isFollowedBy;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final DateTime createdAt;
  final DateTime? lastActiveAt;
  final List<String> interests;
  final Map<String, String>? socialLinks;

  const UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.coverImageUrl,
    this.bio,
    this.website,
    this.location,
    this.dateOfBirth,
    this.isVerified = false,
    this.isPrivate = false,
    this.isFollowing = false,
    this.isFollowedBy = false,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    required this.createdAt,
    this.lastActiveAt,
    this.interests = const [],
    this.socialLinks,
  });

  UserProfile copyWith({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? coverImageUrl,
    String? bio,
    String? website,
    String? location,
    DateTime? dateOfBirth,
    bool? isVerified,
    bool? isPrivate,
    bool? isFollowing,
    bool? isFollowedBy,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    DateTime? createdAt,
    DateTime? lastActiveAt,
    List<String>? interests,
    Map<String, String>? socialLinks,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      bio: bio ?? this.bio,
      website: website ?? this.website,
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      isFollowing: isFollowing ?? this.isFollowing,
      isFollowedBy: isFollowedBy ?? this.isFollowedBy,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      interests: interests ?? this.interests,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }
}

class FollowUser {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final bool isFollowing;
  final String? bio;

  const FollowUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.isFollowing = false,
    this.bio,
  });

  FollowUser copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    bool? isVerified,
    bool? isFollowing,
    String? bio,
  }) {
    return FollowUser(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isFollowing: isFollowing ?? this.isFollowing,
      bio: bio ?? this.bio,
    );
  }
}
