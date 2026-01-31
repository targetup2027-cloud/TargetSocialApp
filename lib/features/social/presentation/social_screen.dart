import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/motion/motion_system.dart';
import '../domain/entities/post.dart';
import '../application/posts_controller.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  final List<String> _tabs = ['For You', 'Following', 'Trending'];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(postsControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() async {
    await ref.read(postsControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the posts list state
    final postsAsyncValue = ref.watch(postsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      drawer: UAxisDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Text(
                    'Social',
                    style: TextStyle(
                      color: Colors.white,
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
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 14),
                        Icon(
                          Icons.search,
                          color: Colors.white.withValues(alpha: 0.4),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Search posts, people, businesses...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      final isSelected = _selectedTab == index;
                      return Padding(
                        padding: EdgeInsets.only(right: index < _tabs.length - 1 ? 24 : 0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedTab = index);
                            // Switch feed type based on tab (if implemented in controller)
                            if (index == 0) ref.read(postsControllerProvider.notifier).loadFeed();
                            // For now we just reload feed, but ideally we'd have loadFollowing() etc.
                          },
                          child: Column(
                            children: [
                              Text(
                                _tabs[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white.withValues(alpha: 0.5),
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 8),
                              AnimatedContainer(
                                duration: MotionTokens.quick,
                                curve: MotionTokens.entrance,
                                height: 2,
                                width: isSelected ? 24 : 0,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEC4899),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    color: const Color(0xFFEC4899),
                    backgroundColor: const Color(0xFF1A1A1A),
                    child: postsAsyncValue.when(
                      data: (posts) {
                        if (posts.isEmpty) {
                          return Center(
                            child: Text(
                              'No posts yet',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            ),
                          );
                        }
                        return ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            return PostCard(post: posts[index]);
                          },
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFEC4899)),
                      ),
                      error: (error, stack) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Error loading posts',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextButton(
                              onPressed: _refresh,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
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
}

class PostCard extends ConsumerWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(number >= 10000 ? 0 : 1)}K';
    }
    return number.toString();
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can use local state for immediate feedback on like/bookmark if needed, 
    // but here we'll rely on the provider updates which should be fast enough with mock data.
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6366F1),
                      const Color(0xFFEC4899),
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0D0D0D),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A1A1A),
                      image: post.authorAvatarUrl != null 
                          ? DecorationImage(
                              image: NetworkImage(post.authorAvatarUrl!),
                              fit: BoxFit.cover,
                            ) 
                          : null,
                    ),
                    child: post.authorAvatarUrl == null 
                        ? Icon(
                            Icons.person,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 20,
                          ) 
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          post.authorName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (post.authorIsVerified) ...[
                          const SizedBox(width: 4),
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF3B82F6),
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          '@${post.authorUsername}',
                          style: TextStyle(
                            color: const Color(0xFFEC4899),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          ' • ${_getTimeAgo(post.createdAt)}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.more_horiz,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (post.content != null) ...[
            Text(
              post.content!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (post.mediaUrls.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  image: DecorationImage(
                    image: NetworkImage(post.mediaUrls.first),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (post.mediaUrls.isEmpty && post.content == null) 
             // Fallback for empty post (shouldn't happen)
             const SizedBox.shrink(),

          Row(
            children: [
              _ActionButton(
                icon: post.isLiked ? Icons.favorite : Icons.favorite_outline,
                label: _formatNumber(post.likesCount),
                color: post.isLiked ? const Color(0xFFEF4444) : null,
                onTap: () {
                   ref.read(postsControllerProvider.notifier).toggleLike(post.id);
                },
              ),
              const SizedBox(width: 20),
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                label: _formatNumber(post.commentsCount),
                onTap: () {},
              ),
              const SizedBox(width: 20),
              _ActionButton(
                icon: Icons.share_outlined,
                label: _formatNumber(post.sharesCount),
                onTap: () {},
              ),
              const Spacer(),
              _ActionButton(
                 icon: post.isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                 label: '',
                 color: post.isBookmarked ? const Color(0xFFEC4899) : null,
                 onTap: () {
                   ref.read(postsControllerProvider.notifier).toggleBookmark(post.id);
                 },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Colors.white.withValues(alpha: 0.5),
            size: 20,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color ?? Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
