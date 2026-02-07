import 'package:flutter/material.dart';

class Nullable<T> {
  final T? value;
  const Nullable(this.value);
}

class ProfileStatusInfo {
  final String label;
  final String scoreRange;
  final Color color;
  final IconData icon;
  final List<String> benefits;

  const ProfileStatusInfo._({
    required this.label,
    required this.scoreRange,
    required this.color,
    required this.icon,
    required this.benefits,
  });

  static const newMember = ProfileStatusInfo._(
    label: 'New Member',
    scoreRange: '0-39',
    color: Color(0xFF6B7280),
    icon: Icons.eco,
    benefits: ['Basic listing', 'Standard support', 'Limited visibility'],
  );

  static const trusted = ProfileStatusInfo._(
    label: 'Trusted',
    scoreRange: '40-69',
    color: Color(0xFF10B981),
    icon: Icons.check_circle,
    benefits: ['Enhanced listing', 'Priority in search', 'Trust badge'],
  );

  static const verified = ProfileStatusInfo._(
    label: 'Verified',
    scoreRange: '70-89',
    color: Color(0xFF059669),
    icon: Icons.star,
    benefits: ['Featured placement', 'Advanced analytics', 'Verification mark'],
  );

  static const elite = ProfileStatusInfo._(
    label: 'Elite',
    scoreRange: '90-100',
    color: Color(0xFFF59E0B),
    icon: Icons.workspace_premium,
    benefits: ['Top placement', 'Dedicated support', 'Elite badge'],
  );
}

enum IdDocumentType {
  nationalId('National ID', Icons.badge),
  driverLicense('Driver\'s License', Icons.drive_eta),
  passport('Passport', Icons.flight),
  militaryId('Military ID', Icons.military_tech),
  studentId('Student ID', Icons.school),
  workPermit('Work Permit', Icons.work);

  final String label;
  final IconData icon;
  const IdDocumentType(this.label, this.icon);
}

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
  final String? nationalId;
  final String? nationalIdImageUrl;
  final IdDocumentType? idDocumentType;
  final bool isNationalIdVerified;
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
    this.nationalId,
    this.nationalIdImageUrl,
    this.idDocumentType,
    this.isNationalIdVerified = false,
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

  ProfileStatusInfo get statusInfo {
    final score = profileCompletionPercentage;
    if (score >= 90) {
      return ProfileStatusInfo.elite;
    } else if (score >= 70) {
      return ProfileStatusInfo.verified;
    } else if (score >= 40) {
      return ProfileStatusInfo.trusted;
    } else {
      return ProfileStatusInfo.newMember;
    }
  }

  int get profileCompletionPercentage {
    int score = 0;
    const int maxScore = 100;
    
    if (avatarUrl?.isNotEmpty ?? false) score += 15;
    if (nationalId?.isNotEmpty ?? false) score += 15;
    if (nationalIdImageUrl?.isNotEmpty ?? false) score += 10;
    if (idDocumentType != null) score += 5;
    if (isNationalIdVerified) score += 10;
    if (phoneNumber?.isNotEmpty ?? false) score += 10;
    if (email?.isNotEmpty ?? false) score += 10;
    if (bio?.isNotEmpty ?? false) score += 10;
    if (coverImageUrl?.isNotEmpty ?? false) score += 5;
    if (location?.isNotEmpty ?? false) score += 5;
    if (website?.isNotEmpty ?? false) score += 5;
    if (dateOfBirth != null) score += 5;
    if (interests.isNotEmpty) score += 5;
    
    return ((score / maxScore) * 100).round().clamp(0, 100);
  }

  List<ProfileCompletionItem> get incompleteItems {
    final items = <ProfileCompletionItem>[];
    
    if (!(avatarUrl?.isNotEmpty ?? false)) {
      items.add(const ProfileCompletionItem(
        field: 'avatar',
        label: 'Profile Picture',
        points: 15,
        icon: 'camera',
      ));
    }
    if (!(nationalId?.isNotEmpty ?? false)) {
      items.add(const ProfileCompletionItem(
        field: 'nationalId',
        label: 'National ID',
        points: 15,
        icon: 'badge',
      ));
    }
    if (!isNationalIdVerified && (nationalId?.isNotEmpty ?? false)) {
      items.add(const ProfileCompletionItem(
        field: 'verifyNationalId',
        label: 'Verify National ID',
        points: 10,
        icon: 'verified',
      ));
    }
    if (!(phoneNumber?.isNotEmpty ?? false)) {
      items.add(const ProfileCompletionItem(
        field: 'phone',
        label: 'Phone Number',
        points: 10,
        icon: 'phone',
      ));
    }
    if (!(email?.isNotEmpty ?? false)) {
      items.add(const ProfileCompletionItem(
        field: 'email',
        label: 'Email Address',
        points: 10,
        icon: 'email',
      ));
    }
    if (!(bio?.isNotEmpty ?? false)) {
      items.add(const ProfileCompletionItem(
        field: 'bio',
        label: 'Bio',
        points: 10,
        icon: 'edit',
      ));
    }
    if (!(coverImageUrl?.isNotEmpty ?? false)) {
      items.add(const ProfileCompletionItem(
        field: 'cover',
        label: 'Cover Image',
        points: 5,
        icon: 'image',
      ));
    }
    if (!(location?.isNotEmpty ?? false)) {
      items.add(const ProfileCompletionItem(
        field: 'location',
        label: 'Location',
        points: 5,
        icon: 'location',
      ));
    }
    if (!(website?.isNotEmpty ?? false)) {
      items.add(const ProfileCompletionItem(
        field: 'website',
        label: 'Website',
        points: 5,
        icon: 'link',
      ));
    }
    if (dateOfBirth == null) {
      items.add(const ProfileCompletionItem(
        field: 'dateOfBirth',
        label: 'Date of Birth',
        points: 5,
        icon: 'calendar',
      ));
    }
    if (interests.isEmpty) {
      items.add(const ProfileCompletionItem(
        field: 'interests',
        label: 'Interests (at least 3)',
        points: 5,
        icon: 'star',
      ));
    }
    return items;
  }


  UserProfile copyWith({
    String? id,
    String? username,
    String? displayName,
    Nullable<String>? email,
    Nullable<String>? phoneNumber,
    Nullable<String>? avatarUrl,
    Nullable<String>? coverImageUrl,
    Nullable<String>? bio,
    Nullable<String>? website,
    Nullable<String>? location,
    Nullable<DateTime>? dateOfBirth,
    Nullable<String>? nationalId,
    Nullable<String>? nationalIdImageUrl,
    Nullable<IdDocumentType>? idDocumentType,
    bool? isNationalIdVerified,
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
    Nullable<Map<String, String>>? socialLinks,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email != null ? email.value : this.email,
      phoneNumber: phoneNumber != null ? phoneNumber.value : this.phoneNumber,
      avatarUrl: avatarUrl != null ? avatarUrl.value : this.avatarUrl,
      coverImageUrl: coverImageUrl != null ? coverImageUrl.value : this.coverImageUrl,
      bio: bio != null ? bio.value : this.bio,
      website: website != null ? website.value : this.website,
      location: location != null ? location.value : this.location,
      dateOfBirth: dateOfBirth != null ? dateOfBirth.value : this.dateOfBirth,
      nationalId: nationalId != null ? nationalId.value : this.nationalId,
      nationalIdImageUrl: nationalIdImageUrl != null ? nationalIdImageUrl.value : this.nationalIdImageUrl,
      idDocumentType: idDocumentType != null ? idDocumentType.value : this.idDocumentType,
      isNationalIdVerified: isNationalIdVerified ?? this.isNationalIdVerified,
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
      socialLinks: socialLinks != null ? socialLinks.value : this.socialLinks,
    );
  }
}

class ProfileCompletionItem {
  final String field;
  final String label;
  final int points;
  final String icon;

  const ProfileCompletionItem({
    required this.field,
    required this.label,
    required this.points,
    required this.icon,
  });
}

class FollowUser {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final bool isVerified;
  final bool isFollowing;
  final String? bio;
  final int profileCompletionPercentage;

  const FollowUser({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.isVerified = false,
    this.isFollowing = false,
    this.bio,
    this.profileCompletionPercentage = 0,
  });

  FollowUser copyWith({
    String? id,
    String? username,
    String? displayName,
    String? avatarUrl,
    bool? isVerified,
    bool? isFollowing,
    String? bio,
    int? profileCompletionPercentage,
  }) {
    return FollowUser(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
      isFollowing: isFollowing ?? this.isFollowing,
      bio: bio ?? this.bio,
      profileCompletionPercentage: profileCompletionPercentage ?? this.profileCompletionPercentage,
    );
  }
}

