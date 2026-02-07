import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/motion/motion_system.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../../profile/application/profile_controller.dart';
import '../../social/application/posts_controller.dart';
import '../../social/application/current_user_provider.dart';
import '../../social/widgets/post_card.dart';
import '../../social/models/post_data.dart';
import '../../social/domain/entities/post.dart';
import '../../social/presentation/comments_sheet.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'People', 'Posts', 'Places'];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounceTimer;

  final List<_TrendingItem> _trendingItems = [
    _TrendingItem(
      title: 'Dubai Marina Sunset Views',
      author: 'Sarah Anderson',
      likes: '125K',
      views: '2.4M',
      duration: '2:34',
      isVerified: true,
      imageUrl: 'https://picsum.photos/seed/dubai/800/450',
      avatarUrl: 'https://i.pravatar.cc/150?img=1',
    ),
    _TrendingItem(
      title: 'Minimalist Interior Design',
      author: 'Alex Chen',
      likes: '45K',
      views: '890K',
      duration: '5:12',
      isVerified: false,
      imageUrl: 'https://picsum.photos/seed/interior/800/450',
      avatarUrl: 'https://i.pravatar.cc/150?img=3',
    ),
    _TrendingItem(
      title: 'Tokyo Night Life',
      author: 'Yuki Tanaka',
      likes: '89K',
      views: '1.2M',
      duration: '3:45',
      isVerified: true,
      imageUrl: 'https://picsum.photos/seed/tokyo/800/450',
      avatarUrl: 'https://i.pravatar.cc/150?img=5',
    ),
    _TrendingItem(
      title: 'Mountain Adventures',
      author: 'Mike Ross',
      likes: '67K',
      views: '1.5M',
      duration: '4:20',
      isVerified: true,
      imageUrl: 'https://picsum.photos/seed/mountain/800/450',
      avatarUrl: 'https://i.pravatar.cc/150?img=8',
    ),
    _TrendingItem(
      title: 'Street Food Tour',
      author: 'Lisa Wong',
      likes: '92K',
      views: '2.1M',
      duration: '6:45',
      isVerified: true,
      imageUrl: 'https://picsum.photos/seed/food/800/450',
      avatarUrl: 'https://i.pravatar.cc/150?img=10',
    ),
  ];

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
      drawer: const UAxisDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    'Discover',
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.dividerColor,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      style: TextStyle(color: context.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search people, posts...',
                        hintStyle: TextStyle(
                          color: context.hintColor,
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: context.hintColor,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedFilter == index;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedFilter = index),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF3B82F6)
                                  : context.cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : context.dividerColor,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                if (index == 0)
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 14,
                                    color: isSelected ? Colors.white : context.iconColor,
                                  ),
                                if (index == 1)
                                  Icon(
                                    Icons.people_outline,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : context.iconColor,
                                  ),
                                if (index == 2)
                                  Icon(
                                    Icons.article_outlined,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : context.iconColor,
                                  ),
                                if (index == 3)
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : context.iconColor,
                                  ),
                                if (index > 0) const SizedBox(width: 4),
                                Text(
                                  _filters[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : context.onSurface,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),

                if (_searchQuery.isEmpty && _selectedFilter == 0)
                  _buildTrendingContent()
                else if (_selectedFilter == 1)
                  _buildPeopleOnlyContent()
                else if (_selectedFilter == 2)
                  _buildPostsOnlyContent()
                else if (_selectedFilter == 3)
                  _buildPlacesContent()
                else
                  _buildSearchResults(),
              ],
            ),
          ),

          Builder(
            builder: (context) => SideMenuToggle(
              onTap: () => Scaffold.of(context).openDrawer(),
            ),
          ),

          const UniverseBackButton(),
        ],
      ),
    );
  }

  Widget _buildPeopleOnlyContent() {
    return Expanded(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Color(0xFF3B82F6), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    _searchQuery.isEmpty ? 'Suggested People' : 'People',
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildPeopleList(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildPostsOnlyContent() {
    return Expanded(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              child: Row(
                children: [
                  const Icon(Icons.article, color: Color(0xFF3B82F6), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    _searchQuery.isEmpty ? 'Trending Posts' : 'Posts',
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildPostsList(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildPlacesContent() {
    final places = [
      {'name': 'The Coffee House', 'type': 'Cafe', 'distance': '0.3 km', 'rating': 4.8, 'image': 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=400'},
      {'name': 'Central Park', 'type': 'Park', 'distance': '0.7 km', 'rating': 4.9, 'image': 'https://images.unsplash.com/photo-1568515387631-8b650bbcdb90?w=400'},
      {'name': 'Tech Hub Co-working', 'type': 'Workspace', 'distance': '1.2 km', 'rating': 4.6, 'image': 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=400'},
      {'name': 'Fitness First Gym', 'type': 'Gym', 'distance': '1.5 km', 'rating': 4.5, 'image': 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=400'},
      {'name': 'Art Gallery Museum', 'type': 'Museum', 'distance': '2.0 km', 'rating': 4.7, 'image': 'https://images.unsplash.com/photo-1554907984-15263bfd63bd?w=400'},
    ];
    
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.dividerColor),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: Image.network(
                    place['image'] as String,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100,
                      height: 100,
                      color: context.dividerColor,
                      child: Icon(Icons.location_on, color: context.hintColor),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name'] as String,
                          style: TextStyle(
                            color: context.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                place['type'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF3B82F6),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.location_on_outlined, size: 14, color: context.hintColor),
                            const SizedBox(width: 2),
                            Text(place['distance'] as String, style: TextStyle(color: context.hintColor, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Color(0xFFFBBF24)),
                            const SizedBox(width: 4),
                            Text(
                              '${place['rating']}',
                              style: TextStyle(
                                color: context.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.hintColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingContent() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: Color(0xFF3B82F6),
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trending Now',
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: _trendingItems.length,
              itemBuilder: (context, index) {
                return AnimatedListItem(
                  index: index,
                  child: HoverScaleCard(
                    child: _TrendingCard(item: _trendingItems[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    final showPeople = _selectedFilter == 0 || _selectedFilter == 1;
    final showPosts = _selectedFilter == 0 || _selectedFilter == 2;

    return Expanded(
      child: CustomScrollView(
        slivers: [
          if (showPeople) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Text(
                  'People',
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildPeopleList(),
          ],
          if (showPosts) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Text(
                  'Posts',
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            _buildPostsList(),
          ],
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildPeopleList() {
    final pState = _searchQuery.isEmpty
        ? ref.watch(suggestedUsersProvider)
        : ref.watch(searchUsersProvider(_searchQuery));
    return pState.when(
      data: (users) {
        if (users.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No people found.',
                style: TextStyle(color: context.onSurfaceVariant),
              ),
            ),
          );
        }
        
        final sortedUsers = List.from(users)
          ..sort((a, b) => b.profileCompletionPercentage.compareTo(a.profileCompletionPercentage));
        
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final user = sortedUsers[index];
              final trustScore = user.profileCompletionPercentage;
              final isHighTrust = trustScore >= 70;
              final isTopRanked = trustScore >= 90;
              
              return AnimatedListItem(
                index: index,
                child: GestureDetector(
                  onTap: () => context.push('/user/${user.id}'),
                  child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isTopRanked 
                        ? const Color(0xFF0D2818)
                        : isHighTrust
                            ? const Color(0xFF0F172A)
                            : context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isTopRanked 
                          ? const Color(0xFF10B981)
                          : isHighTrust
                              ? const Color(0xFF3B82F6).withValues(alpha: 0.5)
                              : context.dividerColor,
                      width: isTopRanked ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: user.avatarUrl != null 
                                ? NetworkImage(user.avatarUrl!) 
                                : null,
                            backgroundColor: context.dividerColor,
                            child: user.avatarUrl == null
                                ? Icon(Icons.person, color: context.iconColor)
                                : null,
                          ),
                          if (isHighTrust)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isTopRanked 
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF10B981),
                                  border: Border.all(color: context.scaffoldBg, width: 2),
                                ),
                                child: Icon(
                                  isTopRanked ? Icons.star : Icons.check,
                                  size: 8,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
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
                                    user.displayName,
                                    style: TextStyle(
                                      color: context.onSurface,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (user.isVerified || isHighTrust) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.verified,
                                    size: 14,
                                    color: isTopRanked 
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF3B82F6),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '@${user.username}',
                              style: TextStyle(
                                color: context.onSurfaceVariant,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isTopRanked 
                                  ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                                  : isHighTrust
                                      ? const Color(0xFF10B981).withValues(alpha: 0.2)
                                      : context.dividerColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$trustScore',
                              style: TextStyle(
                                color: isTopRanked 
                                    ? const Color(0xFFF59E0B)
                                    : isHighTrust
                                        ? const Color(0xFF10B981)
                                        : context.hintColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isTopRanked 
                                ? 'Elite'
                                : isHighTrust 
                                    ? 'Verified' 
                                    : trustScore >= 40 
                                        ? 'Trusted'
                                        : 'New',
                            style: TextStyle(
                              color: context.hintColor,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ),
              );
            },
            childCount: sortedUsers.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => SliverToBoxAdapter(child: Text('Error: $err')),
    );
  }

  Widget _buildPostsList() {
    final pState = _searchQuery.isEmpty
        ? ref.watch(discoverFeedProvider(1))
        : ref.watch(searchPostsProvider(_searchQuery));
    return pState.when(
      data: (posts) {
        if (posts.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'No posts found.',
                style: TextStyle(color: context.onSurfaceVariant),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = posts[index];
              final currentUserId = ref.read(currentUserIdProvider);
              return AnimatedListItem(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: PostCard(
                    post: _mapPostToPostData(post),
                    isOwner: post.authorId == currentUserId,
                    onReact: (type) => ref.read(postsControllerProvider.notifier).reactToPost(post.id, type),
                    onComment: () => CommentsSheet.show(context, post.id),
                    onMoreOptions: () => _showPostOptions(context, post),
                    onTapPost: () {},
                    onAuthorTap: () => context.push('/user/${post.authorId}'),
                  ),
                ),
              );
            },
            childCount: posts.length,
          ),
        );
      },
      loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
      error: (err, stack) => SliverToBoxAdapter(child: Text('Error: $err')),
    );
  }

  void _showPostOptions(BuildContext context, Post post) {
    final currentUserId = ref.read(currentUserIdProvider);
    final isOwner = post.authorId == currentUserId;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.hintColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(Icons.bookmark_border, color: context.iconColor),
                title: Text('Save Post', style: TextStyle(color: context.onSurface)),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(postsControllerProvider.notifier).toggleBookmark(post.id);
                },
              ),
              ListTile(
                leading: Icon(Icons.person_outline, color: context.iconColor),
                title: Text('View Profile', style: TextStyle(color: context.onSurface)),
                onTap: () {
                  Navigator.pop(ctx);
                  context.push('/user/${post.authorId}');
                },
              ),
              if (isOwner) ...[
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: Color(0xFF3B82F6)),
                  title: const Text('Edit Post', style: TextStyle(color: Color(0xFF3B82F6))),
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push('/edit-post', extra: post);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                  title: const Text('Delete Post', style: TextStyle(color: Color(0xFFEF4444))),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref.read(postsControllerProvider.notifier).deletePost(post.id);
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.flag_outlined, color: Color(0xFFEF4444)),
                  title: const Text('Report Post', style: TextStyle(color: Color(0xFFEF4444))),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  PostData _mapPostToPostData(Post post) {
    return PostData.fromPost(post);
  }
}

class _TrendingItem {
  final String title;
  final String author;
  final String likes;
  final String views;
  final String duration;
  final bool isVerified;
  final String imageUrl;
  final String avatarUrl;

  const _TrendingItem({
    required this.title,
    required this.author,
    required this.likes,
    required this.views,
    required this.duration,
    required this.isVerified,
    required this.imageUrl,
    required this.avatarUrl,
  });
}

class _TrendingCard extends StatelessWidget {
  final _TrendingItem item;

  const _TrendingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          context.dividerColor.withValues(alpha: 0.5),
                          context.dividerColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.hintColor,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: context.dividerColor,
                    ),
                    child: Icon(Icons.broken_image, color: context.hintColor, size: 48),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.6),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

              Positioned(
                left: 12,
                bottom: 12,
                child: Row(
                  children: [
                    _StatBadge(icon: Icons.favorite_outline, value: item.likes),
                    const SizedBox(width: 8),
                    _StatBadge(icon: Icons.visibility_outlined, value: item.views),
                  ],
                ),
              ),

              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.duration,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF3B82F6),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: item.avatarUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: context.dividerColor,
                      child: Icon(Icons.person, color: context.hintColor, size: 20),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: context.dividerColor,
                      child: Icon(Icons.person, color: context.hintColor, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: context.onSurface,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          item.author,
                          style: TextStyle(
                            color: context.onSurfaceVariant,
                            fontSize: 13,
                          ),
                        ),
                        if (item.isVerified) ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF3B82F6),
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;

  const _StatBadge({
    required this.icon,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
