import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/uaxis_theme.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../core/motion/motion_system.dart';
import '../application/profile_controller.dart';
import '../domain/entities/user_profile.dart';
import '../../social/application/posts_controller.dart';
import '../../social/widgets/post_card.dart';
import '../../social/models/post_data.dart';
import '../../social/presentation/comments_sheet.dart';
import '../../messages/presentation/chat_detail_screen.dart';
import 'widgets/business_links_sheet.dart';

class VisitorProfileScreen extends ConsumerStatefulWidget {
  final String userId;

  const VisitorProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<VisitorProfileScreen> createState() => _VisitorProfileScreenState();
}

class _VisitorProfileScreenState extends ConsumerState<VisitorProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showMediaViewer(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.9),
      builder: (ctx) => Stack(
        children: [
          InteractiveViewer(
            child: Center(
              child: Hero(
                tag: imageUrl,
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.broken_image,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 64,
                  ),
                ),
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
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFollow() {
    HapticFeedback.mediumImpact();
    final currentProfile = ref.read(userProfileControllerProvider(widget.userId)).valueOrNull;
    final wasFollowing = currentProfile?.isFollowing ?? false;
    ref.read(userProfileControllerProvider(widget.userId).notifier).toggleFollow();
    
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(!wasFollowing ? 'Now following' : 'Unfollowed'),
        backgroundColor: !wasFollowing ? const Color(0xFF10B981) : const Color(0xFF6B7280),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _openMessages(UserProfile profile) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MotionPageRoute(
        page: ChatDetailScreen(
          userName: profile.displayName,
          userAvatar: profile.avatarUrl ?? 'https://i.pravatar.cc/150?u=${widget.userId}',
          conversationId: 'new_${widget.userId}',
          peerUserId: widget.userId,
        ),
      ),
    );
  }

  void _showMoreMenu(UserProfile profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.block, color: Color(0xFFEF4444)),
              title: Text('Block ${profile.displayName}',
                  style: TextStyle(color: context.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _showBlockConfirmation(profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined, color: Color(0xFFF59E0B)),
              title: Text('Report ${profile.displayName}',
                  style: TextStyle(color: context.onSurface)),
              onTap: () {
                Navigator.pop(context);
                _showReportDialog(profile);
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: context.iconColor),
              title: Text('Share Profile', style: TextStyle(color: context.onSurface)),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: 'https://uaxis.app/user/${widget.userId}'));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Profile link copied'),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showBlockConfirmation(UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Block ${profile.displayName}?',
            style: TextStyle(color: context.onSurface)),
        content: Text(
          'They won\'t be able to find your profile, posts, or message you.',
          style: TextStyle(color: context.hintColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: context.hintColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (!mounted) return;
              ScaffoldMessenger.of(this.context).showSnackBar(
                SnackBar(
                  content: Text('${profile.displayName} has been blocked'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) this.context.pop();
              });
            },
            child: const Text('Block', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Report ${profile.displayName}',
            style: TextStyle(color: context.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ReportOption(label: 'Spam', onTap: () => _submitReport(context, 'Spam')),
            _ReportOption(label: 'Harassment', onTap: () => _submitReport(context, 'Harassment')),
            _ReportOption(label: 'Fake Account', onTap: () => _submitReport(context, 'Fake Account')),
            _ReportOption(label: 'Other', onTap: () => _submitReport(context, 'Other')),
          ],
        ),
      ),
    );
  }

  void _submitReport(BuildContext dialogContext, String reason) {
    Navigator.pop(dialogContext);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Report submitted. Thank you.'),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileControllerProvider(widget.userId));

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      body: profileAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error),
        data: (profile) => _buildProfileContent(profile),
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: context.scaffoldBg,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    UAxisColors.social.withValues(alpha: 0.3),
                    UAxisColors.social.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Row(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: context.dividerColor,
                            border: Border.all(color: context.cardColor, width: 4),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 120,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 80,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            color: context.cardColor,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? const Color(0xFF1C1C2E) 
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(5, (index) {
                      if (index.isOdd) {
                        return Container(
                          width: 1,
                          height: 32,
                          color: Theme.of(context).dividerColor,
                        );
                      }
                      return Column(
                        children: [
                          Container(
                            width: 40,
                            height: 18,
                            decoration: BoxDecoration(
                              color: context.dividerColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 50,
                            height: 12,
                            decoration: BoxDecoration(
                              color: context.dividerColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: context.dividerColor,
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 100,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.dividerColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 56,
                      height: 44,
                      decoration: BoxDecoration(
                        color: context.dividerColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(color: UAxisColors.social),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: context.scaffoldBg,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.onSurface),
            onPressed: () => context.pop(),
          ),
          title: Text('Profile', style: TextStyle(color: context.onSurface)),
        ),
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: context.hintColor),
                  const SizedBox(height: 16),
                  Text(
                    'User not found',
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This profile may have been removed or is unavailable.',
                    style: TextStyle(color: context.hintColor, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TapScaleButton(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: UAxisColors.social,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileContent(UserProfile profile) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: context.scaffoldBg,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
              ),
              onPressed: () => _showMoreMenu(profile),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: _buildCoverAndAvatar(profile),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildProfileInfo(profile),
        ),
        SliverPersistentHeader(
          delegate: _SliverTabBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: UAxisColors.social,
              unselectedLabelColor: context.hintColor,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              indicator: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: UAxisColors.social,
                    width: 3,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: UAxisColors.social.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Posts'),
                Tab(text: 'Media'),
                Tab(text: 'About'),
                Tab(text: 'Connections'),
              ],
            ),
            context.cardColor,
          ),
          pinned: true,
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPostsTab(profile),
          _buildMediaTab(profile),
          _buildAboutTab(profile),
          _buildConnectionsTab(profile),
        ],
      ),
    );
  }

  Widget _buildCoverAndAvatar(UserProfile profile) {
    return Stack(
      children: [
        // Cover image - tappable
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _showMediaViewer(profile.coverImageUrl),
            child: profile.coverImageUrl != null && profile.coverImageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: profile.coverImageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            UAxisColors.social,
                            UAxisColors.social.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            UAxisColors.social,
                            UAxisColors.social.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          UAxisColors.social,
                          UAxisColors.social.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: Row(
            children: [
              // Avatar - tappable
              GestureDetector(
                onTap: () {
                  final avatarUrl = profile.avatarUrl?.startsWith('http') == true
                      ? profile.avatarUrl
                      : 'https://i.pravatar.cc/150?u=${profile.username}';
                  _showMediaViewer(avatarUrl);
                },
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: context.cardColor, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: UAxisColors.social.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: profile.avatarUrl!.startsWith('http')
                                ? profile.avatarUrl!
                                : 'https://i.pravatar.cc/150?u=${profile.username}',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => _buildAvatarPlaceholder(),
                            errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
                          )
                        : _buildAvatarPlaceholder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (profile.isVerified) ...[
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Color(0xFF3B82F6), size: 20),
                      ],
                    ],
                  ),
                  Text(
                    '@${profile.username}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: context.dividerColor,
      child: Icon(Icons.person, color: context.hintColor, size: 40),
    );
  }

  Widget _buildProfileInfo(UserProfile profile) {
    final completionPercent = profile.profileCompletionPercentage;
    final status = profile.statusInfo;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            Text(
              profile.bio!,
              style: TextStyle(color: context.onSurface, fontSize: 14, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1C1C2E)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: status.color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: status.color.withValues(alpha: 0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: CircularProgressIndicator(
                          value: completionPercent / 100,
                          strokeWidth: 5,
                          backgroundColor: context.dividerColor.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(status.color),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '$completionPercent%',
                        style: TextStyle(
                          color: status.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  status.color.withValues(alpha: 0.2),
                                  status.color.withValues(alpha: 0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: status.color.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(status.icon, color: status.color, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  status.label.toUpperCase(),
                                  style: TextStyle(
                                    color: status.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Profile Credibility Score',
                        style: TextStyle(
                          color: context.hintColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.verified_user,
                  color: status.color,
                  size: 24,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? const Color(0xFF1C1C2E) 
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white.withValues(alpha: 0.1) 
                    : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat('Posts', profile.postsCount, onTap: () {
                  _tabController.animateTo(0);
                }),
                Container(
                  width: 1,
                  height: 32,
                  color: Theme.of(context).dividerColor,
                ),
                _buildStat('Followers', profile.followersCount, onTap: () {
                  _showFollowersList(profile.id, true);
                }),
                Container(
                  width: 1,
                  height: 32,
                  color: Theme.of(context).dividerColor,
                ),
                _buildStat('Following', profile.followingCount, onTap: () {
                  _showFollowersList(profile.id, false);
                }),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TapScaleButton(
                  onTap: _toggleFollow,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: profile.isFollowing
                          ? null
                          : const LinearGradient(
                              colors: [Color(0xFFEC4899), Color(0xFFAB5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      color: profile.isFollowing ? context.dividerColor : null,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: profile.isFollowing
                          ? null
                          : [
                              BoxShadow(
                                color: UAxisColors.social.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        profile.isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: profile.isFollowing ? context.onSurface : Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TapScaleButton(
                onTap: () => _openMessages(profile),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Message',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TapScaleButton(
                onTap: () => _showMoreMenu(profile),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF1A1A1A)
                        : context.scaffoldBg,
                    border: Border.all(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: 0.1)
                          : context.dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(Icons.more_horiz, color: context.onSurface, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TapScaleButton(
            onTap: () => BusinessLinksSheet.show(context, isOwner: false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? const Color(0xFF1C1C2E) 
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withValues(alpha: 0.1) 
                      : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: context.primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.business_center_rounded, 
                      color: context.primaryColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Business Links',
                          style: TextStyle(
                            color: context.onSurface,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Website, Portfolio & Booking',
                          style: TextStyle(
                            color: context.hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: context.dividerColor.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_forward_ios_rounded, 
                      color: context.onSurfaceVariant, size: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, int count, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            Text(
              _formatNumber(count),
              style: TextStyle(
                color: context.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: context.hintColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showFollowersList(String userId, bool isFollowers) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => _VisitorFollowListSheet(
          userId: userId,
          isFollowers: isFollowers,
          scrollController: scrollController,
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildLoadingTab() {
    return const SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: UAxisColors.social),
        ),
      ),
    );
  }

  Widget _buildErrorTab(String message, VoidCallback onRetry) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: context.hintColor),
              const SizedBox(height: 16),
              Text(message, style: TextStyle(color: context.hintColor)),
              const SizedBox(height: 16),
              TapScaleButton(
                onTap: onRetry,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: UAxisColors.social,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostsTab(UserProfile profile) {
    final postsAsync = ref.watch(userPostsProvider(widget.userId));

    return postsAsync.when(
      loading: () => _buildLoadingTab(),
      error: (error, stack) => _buildErrorTab(
        'Failed to load posts',
        () => ref.invalidate(userPostsProvider(widget.userId)),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.article_outlined,
            title: 'No posts yet',
            subtitle: '${profile.displayName} hasn\'t posted anything yet.',
          );
        }
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return PostCard(
                      key: ValueKey(post.id),
                      post: PostData.fromPost(post),
                      onReact: (type) {
                        ref.read(postsControllerProvider.notifier).reactToPost(post.id, type);
                      },
                      onComment: () {
                        CommentsSheet.show(context, post.id);
                      },
                      onSave: () {
                        ref.read(postsControllerProvider.notifier).toggleBookmark(post.id);
                      },
                    );
                  },
                  childCount: posts.length,
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      },
    );
  }

  Widget _buildMediaTab(UserProfile profile) {
    final postsAsync = ref.watch(userPostsProvider(widget.userId));

    return postsAsync.when(
      loading: () => _buildLoadingTab(),
      error: (error, stack) => _buildErrorTab(
        'Failed to load media',
        () => ref.invalidate(userPostsProvider(widget.userId)),
      ),
      data: (posts) {
        final mediaPosts = posts.where((p) => p.mediaUrls.isNotEmpty).toList();
        if (mediaPosts.isEmpty) {
          return _buildEmptyState(
            icon: Icons.photo_library_outlined,
            title: 'No media yet',
            subtitle: '${profile.displayName} hasn\'t shared any photos or videos.',
          );
        }
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(4),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = mediaPosts[index];
                    final mediaUrl = post.mediaUrls.first;
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            backgroundColor: Colors.transparent,
                            insetPadding: EdgeInsets.zero,
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(color: Colors.black87),
                                ),
                                Center(
                                  child: CachedNetworkImage(
                                    imageUrl: mediaUrl.startsWith('http')
                                        ? mediaUrl
                                        : 'https://picsum.photos/seed/${post.id}/800/800',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Positioned(
                                  top: 48,
                                  right: 16,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: mediaUrl.startsWith('http')
                            ? mediaUrl
                            : 'https://picsum.photos/seed/${post.id}/300/300',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(color: context.dividerColor),
                        errorWidget: (context, url, error) => Container(
                          color: context.dividerColor,
                          child: Icon(Icons.broken_image, color: context.hintColor),
                        ),
                      ),
                    );
                  },
                  childCount: mediaPosts.length,
                ),
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        );
      },
    );
  }

  Widget _buildAboutTab(UserProfile profile) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildAboutSection(
          title: 'Basic Info',
          children: [
            if (profile.location != null && profile.location!.isNotEmpty)
              _buildAboutItem(Icons.location_on, 'Location', profile.location!),
            if (profile.website != null && profile.website!.isNotEmpty)
              _buildAboutItem(Icons.link, 'Website', profile.website!),
            _buildAboutItem(Icons.calendar_today, 'Joined',
                '${profile.createdAt.month}/${profile.createdAt.year}'),
          ],
        ),
        if (profile.interests.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildAboutSection(
            title: 'Interests',
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.interests.map((interest) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: UAxisColors.social.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      interest,
                      style: const TextStyle(
                        color: UAxisColors.social,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
        if (profile.socialLinks != null && profile.socialLinks!.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildAboutSection(
            title: 'Social Links',
            children: profile.socialLinks!.entries.map((entry) {
              return _buildAboutItem(_getSocialIcon(entry.key), entry.key, entry.value);
            }).toList(),
          ),
        ],
        if (profile.location == null &&
            profile.website == null &&
            profile.interests.isEmpty &&
            (profile.socialLinks == null || profile.socialLinks!.isEmpty))
          _buildEmptyState(
            icon: Icons.info_outline,
            title: 'No information available',
            subtitle: 'This user hasn\'t added any profile information yet.',
          ),
      ],
    );
  }

  IconData _getSocialIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'twitter':
      case 'x':
        return Icons.alternate_email;
      case 'instagram':
        return Icons.camera_alt;
      case 'linkedin':
        return Icons.work;
      case 'github':
        return Icons.code;
      case 'youtube':
        return Icons.play_circle;
      default:
        return Icons.link;
    }
  }

  Widget _buildAboutSection({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildAboutItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.hintColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: context.hintColor, fontSize: 12)),
                Text(
                  value,
                  style: TextStyle(color: context.onSurface, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionsTab(UserProfile profile) {
    final followersAsync = ref.watch(followersControllerProvider(widget.userId));

    return followersAsync.when(
      loading: () => _buildLoadingTab(),
      error: (error, stack) => _buildErrorTab(
        'Failed to load connections',
        () => ref.read(followersControllerProvider(widget.userId).notifier).loadList(),
      ),
      data: (followers) {
        if (followers.isEmpty) {
          return _buildEmptyState(
            icon: Icons.people_outline,
            title: 'No connections yet',
            subtitle: '${profile.displayName} doesn\'t have any connections.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: followers.length,
          itemBuilder: (context, index) {
            final follower = followers[index];
            return Container(
              key: ValueKey(follower.id),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.dividerColor),
              ),
              child: GestureDetector(
                onTap: () => context.push('/user/${follower.id}'),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: context.dividerColor,
                      ),
                      child: ClipOval(
                        child: follower.avatarUrl != null
                            ? CachedNetworkImage(
                                imageUrl: follower.avatarUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Icon(
                                  Icons.person,
                                  color: context.hintColor,
                                ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.person,
                                  color: context.hintColor,
                                ),
                              )
                            : Icon(Icons.person, color: context.hintColor),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  follower.displayName,
                                  style: TextStyle(
                                    color: context.onSurface,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (follower.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.verified,
                                    color: Color(0xFF3B82F6), size: 14),
                              ],
                            ],
                          ),
                          Text(
                            '@${follower.username}',
                            style: TextStyle(color: context.hintColor, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    TapScaleButton(
                      onTap: () {
                        ref.read(followersControllerProvider(widget.userId).notifier).toggleFollow(follower.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(follower.isFollowing
                                ? 'Unfollowed ${follower.displayName}'
                                : 'Now following ${follower.displayName}'),
                            backgroundColor: const Color(0xFF10B981),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: follower.isFollowing
                              ? context.dividerColor
                              : UAxisColors.social,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          follower.isFollowing ? 'Following' : 'Follow',
                          style: TextStyle(
                            color: follower.isFollowing
                                ? context.onSurface
                                : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 300,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 64, color: context.hintColor),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: TextStyle(color: context.hintColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _SliverTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || backgroundColor != oldDelegate.backgroundColor;
  }
}

class _ReportOption extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ReportOption({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(Icons.radio_button_unchecked, color: context.hintColor, size: 20),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(color: context.onSurface, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}

class _VisitorFollowListSheet extends ConsumerStatefulWidget {
  final String userId;
  final bool isFollowers;
  final ScrollController scrollController;

  const _VisitorFollowListSheet({
    required this.userId,
    required this.isFollowers,
    required this.scrollController,
  });

  @override
  ConsumerState<_VisitorFollowListSheet> createState() => _VisitorFollowListSheetState();
}

class _VisitorFollowListSheetState extends ConsumerState<_VisitorFollowListSheet> {
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
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: user.avatarUrl != null
                            ? CachedNetworkImageProvider(user.avatarUrl!)
                            : null,
                        backgroundColor: context.dividerColor,
                        child: user.avatarUrl == null
                            ? Icon(Icons.person, color: context.hintColor)
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
                            const Icon(Icons.verified, size: 16, color: Color(0xFF3B82F6)),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '@${user.username}',
                        style: TextStyle(color: context.hintColor, fontSize: 13),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/profile/${user.id}');
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: UAxisColors.social),
            ),
            error: (e, s) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: context.hintColor),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load',
                    style: TextStyle(color: context.hintColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
