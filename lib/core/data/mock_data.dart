import '../../features/profile/domain/entities/user_profile.dart';

class MockData {
  static final UserProfile currentUser = UserProfile(
    id: 'currentUser',
    username: 'yazan_codes',
    displayName: 'Yazan Al-Rashid',
    email: 'yazan@uaxis.app',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    coverImageUrl: 'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=1200',
    bio: 'Flutter Developer 🚀 | Building the future of social apps | U-AXIS creator',
    website: 'https://uaxis.app',
    location: 'Dubai, UAE',
    phoneNumber: null,
    nationalId: null,
    isVerified: true,
    followersCount: 2847,
    followingCount: 412,
    postsCount: 156,
    createdAt: DateTime(2024, 6, 15),
    interests: ['Flutter', 'UI/UX', 'Tech', 'Startups'],
    socialLinks: null,
  );

  static final List<FollowUser> followers = [
    const FollowUser(
      id: 'user1',
      username: 'layla_design',
      displayName: 'Layla Ahmed',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      isVerified: true,
      isFollowing: true,
      bio: 'Senior UI Designer @Google',
    ),
    const FollowUser(
      id: 'user2',
      username: 'omar_tech',
      displayName: 'Omar Hassan',
      avatarUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150',
      isVerified: false,
      isFollowing: false,
      bio: 'Full Stack Developer',
    ),
    const FollowUser(
      id: 'user3',
      username: 'sara_flutter',
      displayName: 'Sara Mahmoud',
      avatarUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150',
      isVerified: true,
      isFollowing: true,
      bio: 'Flutter GDE | Speaker',
    ),
    const FollowUser(
      id: 'user4',
      username: 'ahmed_dev',
      displayName: 'Ahmed Khaled',
      avatarUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      isVerified: false,
      isFollowing: true,
      bio: 'Mobile Lead @Meta',
    ),
  ];

  static final List<FollowUser> following = [
    const FollowUser(
      id: 'user5',
      username: 'nour_pm',
      displayName: 'Nour Ali',
      avatarUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150',
      isVerified: true,
      isFollowing: true,
      bio: 'Product Manager | Startup Advisor',
    ),
    const FollowUser(
      id: 'user6',
      username: 'maya_ui',
      displayName: 'Maya Ibrahim',
      avatarUrl: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?w=150',
      isVerified: false,
      isFollowing: true,
      bio: 'UX Lead | Design Systems',
    ),
    const FollowUser(
      id: 'user7',
      username: 'flutter_official',
      displayName: 'Flutter',
      avatarUrl: 'https://storage.googleapis.com/cms-storage-bucket/4fd0db61df0567c0f352.png',
      isVerified: true,
      isFollowing: true,
      bio: 'Build apps for any screen',
    ),
  ];

  static final List<FollowUser> suggestedUsers = [
    const FollowUser(
      id: 'user8',
      username: 'tech_founder',
      displayName: 'Karim Startup',
      avatarUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?w=150',
      isVerified: true,
      isFollowing: false,
      bio: 'Founded 3 unicorns 🦄',
    ),
    const FollowUser(
      id: 'user9',
      username: 'ai_daily',
      displayName: 'AI Daily',
      avatarUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=150',
      isVerified: true,
      isFollowing: false,
      bio: 'Your daily dose of AI news',
    ),
  ];
}
