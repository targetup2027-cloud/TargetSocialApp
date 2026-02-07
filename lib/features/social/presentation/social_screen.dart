import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/widgets/animated_tab_bar.dart';
import '../../../core/motion/motion_system.dart';
import '../../../core/widgets/animated_list_item.dart';
import '../domain/entities/post.dart';
import '../application/posts_controller.dart';
import '../application/current_user_provider.dart';
import '../models/post_data.dart';
import 'post_detail_screen.dart';
import '../widgets/post_card.dart';
import 'comments_sheet.dart';
import 'create_post_screen.dart';

class SocialScreen extends ConsumerStatefulWidget {
  const SocialScreen({super.key});

  @override
  ConsumerState<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends ConsumerState<SocialScreen> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;
  final List<String> _tabs = ['For You', 'Following', 'Trending'];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
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

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _searchQuery = query;
        });
      }
    });
    // Force rebuild to show/hide search UI immediately based on text controller
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    final postsAsyncValue = ref.watch(postsControllerProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
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
                      color: context.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: TextStyle(color: context.onSurface),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: context.cardColor,
                      hintText: 'Search posts, people, businesses...',
                      hintStyle: TextStyle(color: context.hintColor, fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: context.hintColor, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              color: context.hintColor,
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: context.dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: const Color(0xFF8B5CF6)),
                      ),
                    ),
                  ),
                ),
                if (_searchQuery.isEmpty) ...[
                  const SizedBox(height: 12),
                  AnimatedTabBar(
                    tabs: _tabs,
                    selectedIndex: _selectedTab,
                    onTabChanged: (index) {
                      setState(() => _selectedTab = index);
                      ref.read(postsControllerProvider.notifier).changeTab(index);
                    },
                    activeColor: context.onSurface,
                    indicatorColor: const Color(0xFFEC4899),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    spacing: 24,
                  ),
                ],
                Expanded(
                  child: _searchController.text.isNotEmpty
                      ? _buildSearchResults()
                      : _buildFeed(postsAsyncValue),
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
          Positioned(
            bottom: 30,
            right: 20,
            child: OpenContainerWrapper(
              openBuilder: const CreatePostScreen(),
              closedShape: const CircleBorder(),
              closedColor: Colors.transparent,
              openColor: context.scaffoldBg,
              closedElevation: 0,
              openElevation: 0,
              transitionDuration: const Duration(milliseconds: 500),
              closedBuilder: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
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
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.hintColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (isOwner) ...[
              ListTile(
                leading: Icon(Icons.edit_outlined, color: context.onSurface),
                title: Text('Edit post', style: TextStyle(color: context.onSurface)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/edit-post', extra: post);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                title: const Text('Delete post', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                   Navigator.pop(sheetContext);
                   _confirmDelete(context, post);
                },
              ),
            ] else ...[
               ListTile(
                leading: const Icon(Icons.report_gmailerrorred_outlined, color: Color(0xFFEF4444)),
                title: const Text('Report post', style: TextStyle(color: Color(0xFFEF4444))),
                onTap: () {
                   Navigator.pop(sheetContext);
                   ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post reported')),
                    );
                },
              ),
               ListTile(
                leading: Icon(Icons.not_interested, color: context.onSurface),
                title: Text('Not interested', style: TextStyle(color: context.onSurface)),
                onTap: () {
                   Navigator.pop(sheetContext);
                },
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final searchResults = ref.watch(searchPostsProvider(_searchQuery));

    return searchResults.when(
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Text(
              'No results found',
              style: TextStyle(color: context.hintColor),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          cacheExtent: 800,
          addRepaintBoundaries: true,
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            final currentUserId = ref.read(currentUserIdProvider);
            return AnimatedListItem(
              index: index,
              child: RepaintBoundary(
                child: PostCard(
                  post: PostData.fromPost(post),
                  isOwner: post.authorId == currentUserId,
                  onReact: (type) => ref.read(postsControllerProvider.notifier).reactToPost(post.id, type),
                  onComment: () => CommentsSheet.show(context, post.id),
                  onMoreOptions: () => _showPostOptions(context, post),
                  onTapPost: () {},
                  onAuthorTap: () => context.push('/user/${post.authorId}'),
                  onDeleteMedia: () => ref.read(postsControllerProvider.notifier).deletePost(post.id),
                  onEditMedia: () => context.push('/edit-post', extra: post),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFEC4899))),
      error: (e, _) => Center(
        child: Text('Error: $e', style: TextStyle(color: context.onSurface)),
      ),
    );
  }

  Widget _buildFeed(AsyncValue<List<Post>> postsAsyncValue) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: const Color(0xFFEC4899),
      backgroundColor: context.cardColor,
      child: postsAsyncValue.when(
        data: (posts) {
          if (posts.isEmpty) {
            return Center(
              child: Text(
                'No posts yet',
                style: TextStyle(color: context.hintColor),
              ),
            );
          }
          return ListView.builder(
            controller: _scrollController,
            cacheExtent: 800,
            addRepaintBoundaries: true,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final currentUserId = ref.read(currentUserIdProvider);
              final postData = PostData.fromPost(post);
              return AnimatedListItem(
                index: index,
                child: OpenContainerWrapper(
                  closedColor: context.cardColor,
                  openColor: context.scaffoldBg,
                  closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  openBuilder: PostDetailScreen(postData: postData),
                  closedBuilder: PostCard(
                    post: postData,
                    isOwner: post.authorId == currentUserId,
                    onReact: (type) =>
                        ref.read(postsControllerProvider.notifier).reactToPost(post.id, type),
                    onComment: () => CommentsSheet.show(context, post.id),
                    onMoreOptions: () => _showPostOptions(context, post),
                    onTapPost: null, // Handled by OpenContainer
                    onAuthorTap: () => context.push('/user/${post.authorId}'),
                    onDeleteMedia: () => ref.read(postsControllerProvider.notifier).deletePost(post.id),
                    onEditMedia: () => context.push('/edit-post', extra: post),
                  ),
                ),
              );
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
                style: TextStyle(color: context.onSurface),
              ),
              TextButton(
                onPressed: _refresh,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Post post) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('Delete Post', style: TextStyle(color: context.onSurface)),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(color: context.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: context.hintColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(postsControllerProvider.notifier).deletePost(post.id);
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }
}


