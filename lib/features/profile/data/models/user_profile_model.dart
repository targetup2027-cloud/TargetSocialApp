import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.username,
    required super.displayName,
    super.email,
    super.phoneNumber,
    super.avatarUrl,
    super.coverImageUrl,
    super.bio,
    super.website,
    super.location,
    super.dateOfBirth,
    super.isVerified,
    super.isPrivate,
    super.isFollowing,
    super.isFollowedBy,
    super.followersCount,
    super.followingCount,
    super.postsCount,
    required super.createdAt,
    super.lastActiveAt,
    super.interests,
    super.socialLinks,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final fullName = json['displayName'] as String? ??
        '$firstName $lastName'.trim();
    final username = json['username'] as String? ??
        json['email'] as String? ??
        fullName.toLowerCase().replaceAll(' ', '_');

    DateTime createdAt;
    try {
      createdAt = json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now();
    } catch (_) {
      createdAt = DateTime.now();
    }

    return UserProfileModel(
      id: json['id'].toString(),
      username: username,
      displayName: fullName,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['profilePictureUrl'] as String?,
      coverImageUrl: json['coverImageUrl'] as String? ?? json['coverPhotoUrl'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : null,
      isVerified: json['isVerified'] as bool? ?? json['isEmailVerified'] as bool? ?? false,
      isPrivate: json['isPrivate'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      isFollowedBy: json['isFollowedBy'] as bool? ?? false,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      postsCount: json['postsCount'] as int? ?? 0,
      createdAt: createdAt,
      lastActiveAt: json['lastActiveAt'] != null
          ? DateTime.tryParse(json['lastActiveAt'] as String)
          : null,
      interests: (json['interests'] as List<dynamic>?)
          ?.map((e) => e as String).toList() ?? [],
      socialLinks: (json['socialLinks'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'coverImageUrl': coverImageUrl,
      'bio': bio,
      'website': website,
      'location': location,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'isVerified': isVerified,
      'isPrivate': isPrivate,
      'isFollowing': isFollowing,
      'isFollowedBy': isFollowedBy,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'createdAt': createdAt.toIso8601String(),
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'interests': interests,
      'socialLinks': socialLinks,
    };
  }
}

class FollowUserModel extends FollowUser {
  const FollowUserModel({
    required super.id,
    required super.username,
    required super.displayName,
    super.avatarUrl,
    super.isVerified,
    super.isFollowing,
    super.bio,
    super.profileCompletionPercentage,
  });

  factory FollowUserModel.fromJson(Map<String, dynamic> json) {
    final firstName = json['firstName'] as String? ?? '';
    final lastName = json['lastName'] as String? ?? '';
    final fullName = json['displayName'] as String? ??
        '$firstName $lastName'.trim();
    final username = json['username'] as String? ??
        json['email'] as String? ??
        fullName.toLowerCase().replaceAll(' ', '_');

    return FollowUserModel(
      id: json['id'].toString(),
      username: username,
      displayName: fullName,
      avatarUrl: json['avatarUrl'] as String? ?? json['profilePictureUrl'] as String?,
      isVerified: json['isVerified'] as bool? ?? json['isEmailVerified'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      bio: json['bio'] as String?,
      profileCompletionPercentage: json['profileCompletionPercentage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'isVerified': isVerified,
      'isFollowing': isFollowing,
      'bio': bio,
      'profileCompletionPercentage': profileCompletionPercentage,
    };
  }
}
