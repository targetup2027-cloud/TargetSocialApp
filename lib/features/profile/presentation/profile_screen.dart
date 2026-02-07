import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../settings/presentation/widgets/privacy_controls_content.dart';
import 'widgets/profile_skeleton.dart';
import 'widgets/empty_posts_state.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/widgets/animated_tab_bar.dart';
import '../../../core/widgets/animated_list_item.dart';

import 'widgets/social_connections_sheet.dart';
import 'widgets/business_links_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../domain/entities/user_profile.dart';
import '../application/profile_controller.dart';
import '../../social/application/posts_controller.dart';
import '../../social/models/post_data.dart';
import '../../social/widgets/post_card.dart';
import '../../social/presentation/comments_sheet.dart';
import '../../social/domain/entities/post.dart';
import '../../social/application/current_user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Posts', 'Saved', 'Media', 'About', 'Connections'];

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.hintColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Change Profile Photo',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: Color(0xFF8B5CF6)),
              ),
              title: Text('Take Photo', style: TextStyle(color: context.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpdateAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library, color: Color(0xFF3B82F6)),
              ),
              title: Text('Choose from Gallery', style: TextStyle(color: context.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpdateAvatar(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpdateAvatar(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null && mounted) {
        final croppedFile = await _cropImage(image.path, isAvatar: true);
        if (croppedFile != null && mounted) {
          await ref.read(profileControllerProvider.notifier).updateAvatar(croppedFile.path);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile picture updated!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update avatar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCoverPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.hintColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Change Cover Photo',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt, color: Color(0xFF8B5CF6)),
              ),
              title: Text('Take Photo', style: TextStyle(color: context.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpdateCover(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library, color: Color(0xFF3B82F6)),
              ),
              title: Text('Choose from Gallery', style: TextStyle(color: context.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpdateCover(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpdateCover(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        final croppedFile = await _cropImage(image.path, isAvatar: false);
        if (croppedFile != null && mounted) {
          await ref.read(profileControllerProvider.notifier).updateCoverImage(croppedFile.path);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cover photo updated!'),
                backgroundColor: Color(0xFF10B981),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update cover: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<CroppedFile?> _cropImage(String sourcePath, {required bool isAvatar}) async {
    if (kIsWeb) {
      return CroppedFile(sourcePath);
    }
    return await ImageCropper().cropImage(
      sourcePath: sourcePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: isAvatar ? 'Edit Avatar' : 'Edit Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          backgroundColor: Colors.black,
          initAspectRatio: isAvatar ? CropAspectRatioPreset.square : CropAspectRatioPreset.original,
          lockAspectRatio: isAvatar,
          activeControlsWidgetColor: const Color(0xFF8B5CF6),
        ),
        IOSUiSettings(
          title: isAvatar ? 'Edit Avatar' : 'Edit Image',
          doneButtonTitle: 'Done',
          cancelButtonTitle: 'Cancel',
          aspectRatioLockEnabled: isAvatar,
          aspectRatioPickerButtonHidden: isAvatar,
          resetAspectRatioEnabled: !isAvatar,
        ),
      ],
    );
  }

  void _showMediaViewer(BuildContext context, String? imageUrl) {
    if (imageUrl == null) return;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (context) => Stack(
        children: [
          InteractiveViewer(
            child: Center(
              child: Hero(
                tag: imageUrl,
                child: _getImageProvider(imageUrl) is NetworkImage 
                    ? Image.network(imageUrl, fit: BoxFit.contain)
                    : Image.file(File(imageUrl), fit: BoxFit.contain),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);


    return Scaffold(
        backgroundColor: context.scaffoldBg,
        drawer: const UAxisDrawer(),
        body: Stack(
          children: [
            profileAsync.when(
              data: (profile) => _buildProfileContent(context, profile),
              loading: () => const ProfileSkeleton(),
              error: (err, stack) => Center(child: Text('Error loading profile: $err', style: TextStyle(color: context.onSurface))),
            ),
            const UniverseBackButton(),
            Builder(
              builder: (context) => SideMenuToggle(
                onTap: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ],
        ),
      );
  }



  ImageProvider _getImageProvider(String url) {
    if (url.startsWith('http')) {
      return NetworkImage(url);
    }
    return FileImage(File(url));
  }

  Widget _buildProfileContent(BuildContext context, UserProfile profile) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(profileControllerProvider.notifier).loadCurrentUser(forceRefresh: true);
      },
      color: const Color(0xFF3B82F6),
      backgroundColor: context.cardColor,
      child: CustomScrollView(
        slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: context.scaffoldBg,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: RepaintBoundary(
              child: _buildCoverAndAvatar(profile),
            ),
            collapseMode: CollapseMode.pin,
          ),
        ),
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60), // Space for Avatar in new layout
                _buildProfileInfo(profile),
                _buildTrustScore(profile),
                _buildStats(profile),
                _buildCreatePostButton(),
                _buildConnections(),
                const SizedBox(height: 24),
                _buildConnectedPlatforms(profile),
                const SizedBox(height: 24),
                _buildPrivacyControls(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabBarDelegate(
            child: _buildTabBar(),
            color: context.scaffoldBg,
          ),
        ),
        _buildAnimatedTabContent(profile),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
      ),
    );
  }

  Widget _buildAnimatedTabContent(UserProfile profile) {
    // Return sliver content directly - no SliverToBoxAdapter wrapper needed
    switch (_selectedTab) {
      case 0:
        return _buildPostsList(profile.id);
      case 1:
        return _buildSavedPostsSliver();
      case 2:
        return _buildMediaList(profile.id);
      case 3:
        return _buildAboutSection(profile);
      case 4:
        return _buildConnectionsList(profile.id);
      default:
        return _buildPostsList(profile.id);
    }
  }

  Widget _buildSavedPostsSliver() {
    final savedPostsAsync = ref.watch(bookmarkedPostsProvider);
    return savedPostsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 64,
                    color: context.hintColor.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved posts yet',
                    style: TextStyle(
                      color: context.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon on any post to save it here',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.hintColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = posts[index];
                return AnimatedListItem(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: PostCard(
                      post: _mapPostToData(post),
                      isOwner: post.authorId == ref.read(currentUserIdProvider),
                      onReact: (type) => ref.read(postsControllerProvider.notifier).reactToPost(post.id, type),
                      onComment: () => CommentsSheet.show(context, post.id),
                      onSave: () {
                        ref.read(postsControllerProvider.notifier).toggleBookmark(post.id);
                        ref.invalidate(bookmarkedPostsProvider);
                      },
                      onAuthorTap: () => context.push('/user/${post.authorId}'),
                      onTapPost: () => context.push('/post/${post.id}'),
                    ),
                  ),
                );
              },
              childCount: posts.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'Error loading saved posts',
            style: TextStyle(color: context.onSurface),
          ),
        ),
      ),
    );
  }


  Widget _buildMediaList(String userId) {
    final userPostsAsync = ref.watch(userPostsProvider(userId));
    return userPostsAsync.when(
      data: (posts) {
        final mediaPosts = posts
            .where((p) => (p.mediaUrls.isNotEmpty || p.mediaType == 'video') && 
                         (p.mediaType != 'video' || p.mediaUrls.isNotEmpty))
            .toList();

        if (mediaPosts.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.perm_media_outlined,
                      size: 48, color: context.hintColor.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No media yet',
                      style: TextStyle(color: context.onSurfaceVariant)),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(2),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = mediaPosts[index];
                if (post.mediaUrls.isEmpty) return const SizedBox.shrink();
                
                final url = post.mediaUrls.first;
                final isVideo = post.mediaType == 'video';
                
                return AnimatedListItem(
                  index: index,
                  child: GestureDetector(
                    onTap: () {
                      if (isVideo) {
                        _showMediaViewer(context, url);
                      } else {
                        _showMediaViewer(context, url);
                      }
                    },
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            image: DecorationImage(
                              image: _getImageProvider(url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (isVideo)
                          Container(
                            color: Colors.black.withValues(alpha: 0.3),
                            child: const Center(
                              child: Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
              childCount: mediaPosts.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _buildAboutSection(UserProfile profile) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _buildAboutItem('Bio', profile.bio ?? 'No bio'),
          _buildAboutItem('Location', profile.location ?? 'Unknown'),
          _buildAboutItem('Joined', 'January 2025'), // Placeholder
        ]),
      ),
    );
  }

  Widget _buildAboutItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: context.onSurface,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsList(String userId) {
    // Placeholder for connections list
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 48, color: context.hintColor.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text('No connections yet',
                style: TextStyle(color: context.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  PostData _mapPostToData(Post post) {
    final reactions = <PostReaction>[
      if (post.likesCount > 0)
        PostReaction(type: ReactionType.like, count: post.likesCount),
    ];

    PostType type = PostType.text;
    if (post.mediaType == 'video') {
      type = PostType.video;
    } else if (post.mediaUrls.isNotEmpty) {
      type = PostType.image;
    }

    return PostData(
      id: post.id,
      authorId: post.authorId,
      userName: post.authorName,
      userAvatar: post.authorAvatarUrl ?? '',
      handle: post.authorUsername,
      timeAgo: _getTimeAgo(post.createdAt),
      isVerified: post.authorIsVerified,
      content: post.content ?? '',
      type: type,
      mediaUrl: post.mediaUrls.isNotEmpty ? post.mediaUrls.first : null,
      reactions: reactions,
      commentCount: post.commentsCount,
      shareCount: post.sharesCount,
      topComments: [],
      userReaction: post.userReaction,
      isSaved: post.isBookmarked,
    );
  }
  
  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 7) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildPostsList(String userId) {
    final currentUserId = ref.read(currentUserIdProvider);
    final isCurrentUser = userId == currentUserId;
    
    if (isCurrentUser) {
      final postsAsync = ref.watch(postsControllerProvider);
      return postsAsync.when(
        data: (allPosts) {
          final userPosts = allPosts.where((p) => p.authorId == userId).toList();
          if (userPosts.isEmpty) {
            return EmptyPostsState(
              onCreatePost: () => context.push('/create-post'),
            );
          }
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = userPosts[index];
                  return AnimatedListItem(
                    index: index,
                    child: RepaintBoundary(
                      child: PostCard(
                        post: _mapPostToData(post),
                        isOwner: true,
                        onReact: (type) => ref.read(postsControllerProvider.notifier).reactToPost(post.id, type),
                        onComment: () => CommentsSheet.show(context, post.id),
                        onSave: () {
                          ref.read(postsControllerProvider.notifier).toggleBookmark(post.id);
                          ref.invalidate(bookmarkedPostsProvider);
                        },
                        onMoreOptions: () => _showPostOptions(context, post),
                        onDeleteMedia: () => ref.read(postsControllerProvider.notifier).deletePost(post.id),
                        onEditMedia: () => context.push('/create-post', extra: post),
                      ),
                    ),
                  );
                },
                childCount: userPosts.length,
              ),
            ),
          );
        },
        loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
        error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error: $e', style: TextStyle(color: context.onSurface)))),
      );
    }

    final userPostsAsync = ref.watch(userPostsProvider(userId));
    return userPostsAsync.when(
      data: (posts) {
        if (posts.isEmpty) {
          return EmptyPostsState(
            onCreatePost: () => context.push('/create-post'),
          );
        }
        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = posts[index];
                return AnimatedListItem(
                  index: index,
                  child: RepaintBoundary(
                    child: PostCard(
                      post: _mapPostToData(post),
                      isOwner: false,
                      onReact: (type) => ref.read(postsControllerProvider.notifier).reactToPost(post.id, type),
                      onComment: () => CommentsSheet.show(context, post.id),
                      onSave: () {
                        ref.read(postsControllerProvider.notifier).toggleBookmark(post.id);
                        ref.invalidate(bookmarkedPostsProvider);
                      },
                      onMoreOptions: () => _showPostOptions(context, post),
                    ),
                  ),
                );
              },
              childCount: posts.length,
            ),
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (e, s) => SliverToBoxAdapter(child: Center(child: Text('Error: $e', style: TextStyle(color: context.onSurface)))),
    );
  }

  Widget _buildCoverAndAvatar(UserProfile profile) {
    return SizedBox(
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: GestureDetector(
              onTap: () => _showMediaViewer(context, profile.coverImageUrl),
              child: Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                  image: profile.coverImageUrl != null
                      ? DecorationImage(
                          image: _getImageProvider(profile.coverImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
            ),
          ),
          Positioned(
            top: 116, // 160 (cover height) - 32 (button size) - 12 (margin)
            right: 16,
            child: GestureDetector(
              onTap: () => _showCoverPicker(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 20,
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => _showMediaViewer(context, profile.avatarUrl),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: context.scaffoldBg, width: 4),
                      color: context.cardColor,
                      image: profile.avatarUrl != null
                          ? DecorationImage(
                              image: _getImageProvider(profile.avatarUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: profile.avatarUrl == null
                        ? Icon(Icons.person, color: context.iconColor, size: 40)
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showAvatarPicker(),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                        border: Border.all(color: context.scaffoldBg, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(UserProfile profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  profile.displayName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              if (profile.isVerified)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF3B82F6),
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/edit-profile'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(
                      color: context.onSurface.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 14,
                    color: context.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '@${profile.username}',
            style: const TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.bio ?? 'No bio yet.',
            style: TextStyle(
              color: context.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          // Placeholder for "Magic" or custom status
          Row(
            children: [
              const Text('✨ ', style: TextStyle(fontSize: 14)),
              Flexible(
                child: Text(
                  'Building beautiful digital experiences', 
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          if (profile.location != null)
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Color(0xFFEC4899)),
                const SizedBox(width: 4),
                Text(
                  profile.location!,
                  style: TextStyle(
                    color: context.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTrustScore(UserProfile profile) {
    final completionPercent = profile.profileCompletionPercentage;
    final incompleteItems = profile.incompleteItems;
    final status = profile.statusInfo;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: status.color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: status.color.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Indicator with Glow
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: status.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: completionPercent / 100,
                      strokeWidth: 6,
                      backgroundColor: context.dividerColor.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(status.color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$completionPercent%',
                        style: TextStyle(
                          color: status.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            
            // Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge and Label
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                status.color.withValues(alpha: 0.2),
                                status.color.withValues(alpha: 0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: status.color.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(status.icon, color: status.color, size: 14),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  status.label.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: status.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'Score: ${status.scoreRange}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.hintColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    status.benefits.first,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      color: context.onSurface.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (incompleteItems.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => context.push('/edit-profile'),
                      child: Row(
                        children: [
                          Text(
                            'Complete Profile',
                            style: TextStyle(
                              color: status.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, size: 14, color: status.color),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }









  Widget _buildStats(UserProfile profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _StatColumn(
            value: _formatNumber(profile.followersCount),
            label: 'Followers',
            onTap: () => _showFollowersList(context, profile.id, true),
          ),
          _StatColumn(
            value: _formatNumber(profile.followingCount),
            label: 'Following',
            onTap: () => _showFollowersList(context, profile.id, false),
          ),
          _StatColumn(
            value: _formatNumber(profile.postsCount),
            label: 'Posts',
            onTap: () {
              setState(() => _selectedTab = 0);
              // Optional: Scroll to posts section
            },
          ),
        ],
      ),
    );
  }

  void _showFollowersList(BuildContext context, String userId, bool isFollowers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _FollowListSheet(
          userId: userId,
          isFollowers: isFollowers,
          scrollController: scrollController,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number/1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number/1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  Widget _buildCreatePostButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.push('/create-post'),
            borderRadius: BorderRadius.circular(24),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.edit, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Create Post',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConnections() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Connections',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _selectedTab = 4);
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              itemBuilder: (context, index) {
                final counts = ['12', '8', '15', '5', '10', '7'];
                // Mocks for connections avatar
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.dividerColor,
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://picsum.photos/seed/user${index + 10}/100/100',
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color((0xFF8B5CF6 + index * 0x111111) | 0xFF000000),
                                    Color((0xFFEC4899 + index * 0x080808) | 0xFF000000),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            counts[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedPlatforms(UserProfile profile) {
    bool isInstagram = profile.socialLinks?.containsKey('instagram') ?? false;
    bool isYoutube = profile.socialLinks?.containsKey('youtube') ?? false;
    bool isFacebook = profile.socialLinks?.containsKey('facebook') ?? false;
    bool isLinkedin = profile.socialLinks?.containsKey('linkedin') ?? false;

    void updateSocial(String key, bool isConnected) {
      final newLinks = Map<String, String>.from(profile.socialLinks ?? {});
      if (isConnected) {
        newLinks[key] = key;
      } else {
        newLinks.remove(key);
      }
      ref.read(profileControllerProvider.notifier).updateProfile(socialLinks: Nullable(newLinks));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connected Social Platforms',
            style: TextStyle(
              color: context.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          _PlatformTile(
            icon: FontAwesomeIcons.instagram,
            iconColor: Colors.white,
            iconDecoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF58529),
                  Color(0xFFDD2A7B),
                  Color(0xFF8134AF),
                ],
              ),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            name: 'Instagram',
            subtitle: isInstagram ? 'Connected' : 'Not connected',
            isConnected: isInstagram,
            onChanged: (v) => updateSocial('instagram', v),
          ),

          _PlatformTile(
            icon: FontAwesomeIcons.youtube,
            iconColor: Colors.white,
            iconDecoration: const BoxDecoration(
              color: Color(0xFFFF0000),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            name: 'YouTube',
            subtitle: isYoutube ? 'Connected' : 'Not connected',
            isConnected: isYoutube,
            onChanged: (v) => updateSocial('youtube', v),
          ),

          _PlatformTile(
            icon: FontAwesomeIcons.facebookF,
            iconColor: Colors.white,
            iconDecoration: const BoxDecoration(
              color: Color(0xFF1877F2),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            name: 'Facebook',
            subtitle: isFacebook ? 'Connected' : 'Not connected',
            isConnected: isFacebook,
            onChanged: (v) => updateSocial('facebook', v),
          ),

          _PlatformTile(
            icon: FontAwesomeIcons.linkedinIn,
            iconColor: Colors.white,
            iconDecoration: const BoxDecoration(
              color: Color(0xFF0A66C2),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            name: 'LinkedIn',
            subtitle: isLinkedin ? 'Connected' : 'Not connected',
            isConnected: isLinkedin,
            onChanged: (v) => updateSocial('linkedin', v),
          ),

          const SizedBox(height: 16),
          
          GestureDetector(
            onTap: () => BusinessLinksSheet.show(context, isOwner: true),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.dividerColor),
                 boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business_center_outlined, 
                          color: context.primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Business Links',
                          style: TextStyle(
                            color: context.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, 
                      color: context.hintColor, size: 14),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              SocialConnectionsSheet.show(context);
            },
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: context.dividerColor,
                ),
              ),
              child: Center(
                child: Text(
                  'Manage Connections',
                  style: TextStyle(
                    color: context.onSurface.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyControls() {
    return const PrivacyControlsContent();
  }

  Widget _buildTabBar() {
    return AnimatedTabBar(
      tabs: _tabs,
      selectedIndex: _selectedTab,
      onTabChanged: (index) => setState(() => _selectedTab = index),
      activeColor: const Color(0xFF3B82F6),
      indicatorColor: const Color(0xFF3B82F6),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      spacing: 8,
    );
  }
  void _showPostOptions(BuildContext context, Post post) {
    final currentUserId = ref.read(currentUserIdProvider);
    final isOwner = post.authorId == currentUserId;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.hintColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (isOwner) ...[
              /*
              // Temporarily disabled until setCommentsEnabled is implemented
              if (post.commentsEnabled)
                ListTile(
                  leading: Icon(Icons.comments_disabled_outlined, color: context.iconColor),
                  title: Text('Turn off comments', style: TextStyle(color: context.onSurface)),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(postsControllerProvider.notifier)
                        .setCommentsEnabled(postId: post.id, enabled: false);
                  },
                )
              else
                ListTile(
                  leading: Icon(Icons.comment_outlined, color: context.iconColor),
                  title: Text('Turn on comments', style: TextStyle(color: context.onSurface)),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(postsControllerProvider.notifier)
                        .setCommentsEnabled(postId: post.id, enabled: true);
                  },
                ),
                */
              ListTile(
                leading: Icon(Icons.edit_outlined, color: context.iconColor),
                title: Text('Edit post', style: TextStyle(color: context.onSurface)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/edit-post', extra: post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                title: const Text('Delete post', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                   Navigator.pop(context);
                   _confirmDelete(context, post);
                },
              ),
            ] else ...[
               ListTile(
                leading: const Icon(Icons.report_gmailerrorred_outlined, color: Color(0xFFEF4444)),
                title: const Text('Report post', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                   Navigator.pop(context);
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post reported')),
                    );
                },
              ),
               ListTile(
                leading: const Icon(Icons.not_interested, color: Colors.white),
                title: Text('Not interested', style: TextStyle(color: context.onSurface)),
                onTap: () {
                   Navigator.pop(context);
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Post post) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.cardColor,
          title: Text('Delete Post', style: TextStyle(color: context.onSurface)),
          content: Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
            style: TextStyle(color: context.onSurfaceVariant),
          ),
          actions: [
            TextButton(
               onPressed: () => Navigator.pop(context),
               child: Text('Cancel', style: TextStyle(color: context.hintColor)),
            ),
             TextButton(
               onPressed: () {
                  Navigator.pop(context);
                  ref.read(postsControllerProvider.notifier).deletePost(post.id);
               },
               child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
            ),
          ],
        ),
      );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatColumn({
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: context.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: context.hintColor,
              fontSize: 13,
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final BoxDecoration iconDecoration;
  final String name;
  final String subtitle;
  final bool isConnected;
  final ValueChanged<bool> onChanged;

  const _PlatformTile({
    required this.icon,
    required this.iconColor,
    required this.iconDecoration,
    required this.name,
    required this.subtitle,
    required this.isConnected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: iconDecoration,
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isConnected
                        ? const Color(0xFF10B981)
                        : context.hintColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isConnected,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF3B82F6),
            activeTrackColor: const Color(0xFF3B82F6).withValues(alpha: 0.2),
            inactiveThumbColor: context.hintColor,
            inactiveTrackColor: context.dividerColor,
          ),
        ],
      ),
    );
  }
}



class _FollowListSheet extends ConsumerStatefulWidget {
  final String userId;
  final bool isFollowers;
  final ScrollController scrollController;

  const _FollowListSheet({
    required this.userId,
    required this.isFollowers,
    required this.scrollController,
  });

  @override
  ConsumerState<_FollowListSheet> createState() => _FollowListSheetState();
}

class _FollowListSheetState extends ConsumerState<_FollowListSheet> {
  @override
  Widget build(BuildContext context) {
    final provider = widget.isFollowers
        ? followersControllerProvider(widget.userId)
        : followingControllerProvider(widget.userId);
    final usersAsync = ref.watch(provider);

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12, bottom: 8),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: context.hintColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.isFollowers ? 'Followers' : 'Following',
            style: TextStyle(
              color: context.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: usersAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return Center(
                  child: Text(
                    widget.isFollowers
                        ? 'No followers yet'
                        : 'Not following anyone',
                    style: TextStyle(color: context.hintColor),
                  ),
                );
              }
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  if (scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200) {
                    final notifier = widget.isFollowers
                        ? ref.read(followersControllerProvider(widget.userId).notifier)
                        : ref.read(followingControllerProvider(widget.userId).notifier);
                    notifier.loadMore();
                  }
                  return false;
                },
                child: ListView.separated(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.avatarUrl != null
                            ? NetworkImage(user.avatarUrl!)
                            : null,
                        child: user.avatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              user.displayName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (user.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle,
                                size: 14, color: Color(0xFF3B82F6)),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '@${user.username}',
                        style: TextStyle(color: context.hintColor),
                      ),
                      trailing: user.id != ref.read(currentUserIdProvider)
                          ? TextButton(
                              onPressed: () {
                                final notifier = widget.isFollowers
                                    ? ref.read(followersControllerProvider(
                                            widget.userId)
                                        .notifier)
                                    : ref.read(followingControllerProvider(
                                            widget.userId)
                                        .notifier);
                                notifier.toggleFollow(user.id);
                              },
                              child: Text(
                                user.isFollowing ? 'Unfollow' : 'Follow',
                                style: TextStyle(
                                  color: user.isFollowing
                                      ? context.hintColor
                                      : const Color(0xFF3B82F6),
                                ),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(
                child: Text('Error: $e',
                    style: TextStyle(color: context.onSurface))),
          ),
        ),
      ],
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color color;

  _StickyTabBarDelegate({
    required this.child,
    required this.color,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: color,
      child: child,
    );
  }

  @override
  double get maxExtent => 48; // Adjust based on your tab bar height

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _StickyTabBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.color != color;
  }
}

