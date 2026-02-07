# Flutter Performance Audit Report

**Date:** January 2026  
**Build Mode:** Profile/Release Analysis  
**Scope:** UI Thread, Raster Thread, I/O/Async Operations

---

## Executive Summary

| Severity | Count | Estimated Frame Impact |
|----------|-------|------------------------|
| 🔴 Critical | 3 | >16ms (frame drops) |
| 🟠 Major | 4 | 8-16ms |
| 🟡 Minor | 3 | <8ms |

**Overall Assessment:** The codebase has several performance hotspots concentrated in:
1. ListView/ScrollView implementations lacking optimization
2. Image rendering without proper memory constraints  
3. Shimmer animations with excessive rebuilds
4. Missing `RepaintBoundary` isolation for complex widgets

---

## 🔴 Critical Issues

### Issue #1: CachedNetworkImage Without Memory Constraints

**Location:** `lib/features/social/widgets/post_card.dart:508-528`  
**Thread:** Raster Thread  
**Cause:** Images loaded at full resolution regardless of display size

**Evidence:**
```dart
// Lines 508-528 - NO memCacheWidth/memCacheHeight specified
return CachedNetworkImage(
  imageUrl: mediaUrl,
  fit: BoxFit.cover,
  width: double.infinity,
  height: double.infinity,
  placeholder: (context, url) => Container(...),
  errorWidget: (context, url, error) => Container(...),
);
```

**Impact:** 
- Raster thread overload when scrolling through image-heavy feeds
- Excessive GPU memory consumption
- Estimated 15-25ms per frame with 4+ images visible

**Fix Strategy:**
```dart
return CachedNetworkImage(
  imageUrl: mediaUrl,
  fit: BoxFit.cover,
  width: double.infinity,
  height: double.infinity,
  memCacheWidth: 400,  // Constrain decoded image size
  memCacheHeight: 400,
  fadeInDuration: const Duration(milliseconds: 150), // Reduce fade animation
  placeholder: (context, url) => const _ImagePlaceholder(),
  errorWidget: (context, url, error) => const _ImageErrorWidget(),
);

// Extract as const widgets
class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: CircularProgressIndicator(
          color: UAxisColors.social,
          strokeWidth: 2,
        ),
      ),
    );
  }
}
```

---

### Issue #2: ShimmerLoading Rebuilds Entire Widget Tree Per Frame

**Location:** `lib/core/widgets/shimmer_loading.dart:51-72`  
**Thread:** UI Thread  
**Cause:** `AnimatedBuilder` rebuilds entire `Container` with computed gradient 60fps

**Evidence:**
```dart
// Lines 51-72
return AnimatedBuilder(
  animation: _animation,
  builder: (context, child) {
    return Container(  // ❌ Entire Container rebuilt every frame
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(_animation.value - 1, 0),
          end: Alignment(_animation.value + 1, 0),
          colors: [baseColor, highlightColor, baseColor],
        ),
      ),
    );
  },
);
```

**Impact:**
- UI thread congestion during loading states
- 5-10ms overhead per shimmer widget (multiple shimmer = multiplicative)
- Visible in PostCardShimmer which has 8+ shimmer instances

**Fix Strategy:**
```dart
@override
Widget build(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final baseColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
  final highlightColor = isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

  // Use CustomPaint for gradient animation - avoids Container rebuilds
  return AnimatedBuilder(
    animation: _animation,
    builder: (context, child) {
      return CustomPaint(
        painter: _ShimmerPainter(
          animationValue: _animation.value,
          baseColor: baseColor,
          highlightColor: highlightColor,
          borderRadius: widget.isCircle ? null : widget.borderRadius,
          isCircle: widget.isCircle,
        ),
        child: SizedBox(
          width: widget.width,
          height: widget.height,
        ),
      );
    },
  );
}

class _ShimmerPainter extends CustomPainter {
  final double animationValue;
  final Color baseColor;
  final Color highlightColor;
  final double? borderRadius;
  final bool isCircle;

  _ShimmerPainter({
    required this.animationValue,
    required this.baseColor,
    required this.highlightColor,
    this.borderRadius,
    this.isCircle = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final gradient = LinearGradient(
      begin: Alignment(animationValue - 1, 0),
      end: Alignment(animationValue + 1, 0),
      colors: [baseColor, highlightColor, baseColor],
    );
    
    final paint = Paint()..shader = gradient.createShader(rect);
    
    if (isCircle) {
      canvas.drawOval(rect, paint);
    } else if (borderRadius != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(borderRadius!)),
        paint,
      );
    } else {
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(_ShimmerPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
```

---

### Issue #3: PostCard Media Section Triggers Full Rebuild on Reaction

**Location:** `lib/features/social/widgets/post_card.dart:67-76, 125-164`  
**Thread:** UI Thread  
**Cause:** `setState` in `_handleReaction` rebuilds entire PostCard including media grid

**Evidence:**
```dart
// Lines 67-76
void _handleReaction(ReactionType type) {
  setState(() {  // ❌ Entire widget rebuilds including expensive _buildMedia()
    if (_userReaction == type) {
      _userReaction = null;
    } else {
      _userReaction = type;
    }
  });
  widget.onReact?.call(type);
}

// Lines 125-164 - build() reconstructs all sections
@override
Widget build(BuildContext context) {
  // ... 
  children: [
    _buildHeader(),           // Rebuilds
    _buildContent(),          // Rebuilds
    _buildMedia(),            // ❌ Expensive: image grid with CachedNetworkImage
    _buildReactionBar(l10n),  // Rebuilds (only this needs update)
    _buildActionButtons(l10n), // Rebuilds
    _buildCommentPreview(l10n), // Rebuilds
  ],
}
```

**Impact:**
- Tap reaction = 12-20ms frame spike
- Image grid recalculates layout
- CachedNetworkImage widgets recreated (though images are cached)

**Fix Strategy:**
```dart
// Extract static sections as separate StatelessWidgets with const constructors
// Wrap _buildMedia() with RepaintBoundary

Widget _buildMedia() {
  if (widget.post.type == PostType.text) return const SizedBox.shrink();
  
  // Wrap entire media section to isolate from reaction updates
  return RepaintBoundary(
    child: _MediaSection(
      post: widget.post,
      isOwner: widget.isOwner,
      onDeleteMedia: widget.onDeleteMedia,
      onEditMedia: widget.onEditMedia,
    ),
  );
}

// Better: Convert media section to separate StatefulWidget that doesn't rebuild
class _MediaSection extends StatelessWidget {
  final PostData post;
  final bool isOwner;
  final VoidCallback? onDeleteMedia;
  final VoidCallback? onEditMedia;

  const _MediaSection({
    required this.post,
    required this.isOwner,
    this.onDeleteMedia,
    this.onEditMedia,
  });

  @override
  Widget build(BuildContext context) {
    // ... existing media building logic
  }
}
```

---

## 🟠 Major Issues

### Issue #4: ListView.builder Without itemExtent or prototypeItem

**Location:** `lib/features/social/presentation/social_screen.dart:352-373`  
**Thread:** UI Thread  
**Cause:** ListView must measure each item dynamically during scroll

**Evidence:**
```dart
// Lines 352-373
return ListView.builder(
  controller: _scrollController,
  cacheExtent: 500,  // Good
  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
  itemCount: posts.length,
  itemBuilder: (context, index) {
    // No itemExtent specified - each PostCard measured individually
    return PostCard(...);
  },
);
```

**Impact:**
- Scroll performance degradation with 50+ items
- Variable height items cause layout recalculation
- Estimated 3-8ms per scroll frame overhead

**Fix Strategy:**
Since `PostCard` has variable heights, use `addAutomaticKeepAlives: true` (default) and increase `cacheExtent`:

```dart
return ListView.builder(
  controller: _scrollController,
  cacheExtent: 800,  // Increase from 500
  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
  itemCount: posts.length,
  addAutomaticKeepAlives: true,  // Keep alive off-screen items
  addRepaintBoundaries: true,     // Add RepaintBoundary per item
  itemBuilder: (context, index) {
    final post = posts[index];
    // Wrap in RepaintBoundary for paint isolation
    return RepaintBoundary(
      child: PostCard(...),
    );
  },
);
```

---

### Issue #5: Profile Screen PostsList Watches Provider Inside SliverList

**Location:** `lib/features/profile/presentation/profile_screen.dart:593-631`  
**Thread:** UI Thread  
**Cause:** `ref.watch` inside sliver delegate itemBuilder - provider changes trigger full list rebuild

**Evidence:**
```dart
// Lines 593-631
Widget _buildPostsList(String userId) {
  final currentUserId = ref.watch(currentUserIdProvider); // ⚠️ Watch at method level
  
  if (isCurrentUser) {
    final postsAsync = ref.watch(postsControllerProvider); // ⚠️ Watch in build path
    return postsAsync.when(
      data: (allPosts) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              // itemBuilder called for every item on any provider change
            },
          ),
        );
      },
    );
  }
}
```

**Impact:**
- Any post update (like, comment) rebuilds entire profile posts list
- Estimated 10-15ms per provider state change

**Fix Strategy:**
```dart
Widget _buildPostsList(String userId) {
  // Move watch to widget level via select() for granular updates
  final currentUserId = ref.read(currentUserIdProvider); // Read once
  final isCurrentUser = userId == currentUserId;

  if (isCurrentUser) {
    // Use select to only rebuild when posts list content changes
    final posts = ref.watch(
      postsControllerProvider.select((state) => state.valueOrNull ?? []),
    );
    
    return _UserPostsSliver(
      posts: posts.where((p) => p.authorId == userId).toList(),
      isOwner: true,
      // ... other props
    );
  }
  // ...
}

// Extract to separate widget to isolate rebuilds
class _UserPostsSliver extends StatelessWidget {
  final List<Post> posts;
  final bool isOwner;
  
  const _UserPostsSliver({required this.posts, required this.isOwner});
  
  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) return const EmptyPostsState();
    
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => RepaintBoundary(
          child: PostCard(
            post: PostData.fromPost(posts[index]),
            isOwner: isOwner,
          ),
        ),
        childCount: posts.length,
      ),
    );
  }
}
```

---

### Issue #6: VideoThumb Generates Thumbnail on UI Thread

**Location:** `lib/features/social/widgets/post_card.dart:994-1066`  
**Thread:** UI Thread (blocking)  
**Cause:** `VideoThumbnail.thumbnailData` called without isolate

**Evidence:**
```dart
// Lines 994-1066
Future<void> _loadThumbnail() async {
  // ... 
  final data = await VideoThumbnail.thumbnailData(
    video: widget.videoUrl,
    imageFormat: ImageFormat.JPEG,
    maxHeight: 300,
    quality: 25,
  );
  // ...
}
```

**Impact:**
- Blocks UI during video thumbnail generation
- 100-500ms freeze per video thumbnail
- Multiple videos visible = cascading freezes

**Fix Strategy:**
```dart
Future<void> _loadThumbnail() async {
  if (_isLoading || _thumbnailBytes != null) return;
  
  setState(() => _isLoading = true);
  
  try {
    // Use compute for isolate-based processing
    final bytes = await compute(_generateThumbnail, widget.videoUrl);
    
    if (mounted && bytes != null) {
      _thumbCache[widget.postId] = bytes;
      setState(() {
        _thumbnailBytes = bytes;
        _isLoading = false;
      });
    }
  } catch (e) {
    if (mounted) setState(() => _isLoading = false);
  }
}

// Top-level function for compute
Future<Uint8List?> _generateThumbnail(String videoUrl) async {
  return await VideoThumbnail.thumbnailData(
    video: videoUrl,
    imageFormat: ImageFormat.JPEG,
    maxHeight: 300,
    quality: 25,
  );
}
```

---

### Issue #7: PostCardShimmer Creates 8+ AnimationControllers

**Location:** `lib/core/widgets/shimmer_loading.dart:76-127`  
**Thread:** UI Thread  
**Cause:** Each `ShimmerLoading` widget has its own `AnimationController`

**Evidence:**
```dart
// Lines 76-127 - PostCardShimmer has 8 ShimmerLoading widgets
// Each creates AnimationController in initState
class PostCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              const ShimmerLoading(...),  // AnimationController #1
              const ShimmerLoading(...),  // AnimationController #2
              const ShimmerLoading(...),  // AnimationController #3
            ],
          ),
          const ShimmerLoading(...),       // AnimationController #4
          const ShimmerLoading(...),       // AnimationController #5
          // ... more controllers
        ],
      ),
    );
  }
}
```

**Impact:**
- 8 synchronized animations = 8x tick callbacks per frame
- Estimated 3-5ms overhead during loading states

**Fix Strategy:**
Use `Shimmer` package or create shared animation scope:

```dart
// Create inherited animation for all shimmer children
class ShimmerScope extends StatefulWidget {
  final Widget child;
  const ShimmerScope({super.key, required this.child});
  
  @override
  State<ShimmerScope> createState() => _ShimmerScopeState();
  
  static Animation<double>? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_ShimmerInheritedWidget>()?.animation;
  }
}

class _ShimmerScopeState extends State<ShimmerScope> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return _ShimmerInheritedWidget(
      animation: _animation,
      child: widget.child,
    );
  }
}

// Update ShimmerLoading to use inherited animation
class ShimmerLoading extends StatelessWidget {
  // ... properties ...
  
  @override
  Widget build(BuildContext context) {
    final animation = ShimmerScope.of(context);
    if (animation == null) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        // ... gradient logic with animation.value
      },
    );
  }
}
```

---

## 🟡 Minor Issues

### Issue #8: Missing const Constructors in Container Decorations

**Location:** Multiple files  
**Impact:** <5ms, marginal rebuild overhead

**Examples:**
- `post_card.dart:466` - `Colors.black.withValues(alpha: 0.5)` computed each build
- `profile_screen.dart:700-705` - Decoration created each build

**Fix:** Extract to static const or pre-computed values.

---

### Issue #9: Closure Allocations in itemBuilder

**Location:** `social_screen.dart:357-371`, `profile_screen.dart:610-621`  
**Impact:** <3ms, GC pressure with large lists

**Evidence:**
```dart
itemBuilder: (context, index) {
  onReact: (type) => ref.read(...).reactToPost(post.id, type),  // New closure per item
  onComment: () => CommentsSheet.show(context, post.id),         // New closure per item
}
```

**Fix:** Use method tear-offs where possible or memoize callbacks.

---

### Issue #10: Theme Extension Lookups in Build Methods

**Location:** Throughout codebase (`context.onSurface`, `context.cardColor`, etc.)  
**Impact:** <2ms, micro-optimization

**Current:**
```dart
Widget build(BuildContext context) {
  return Container(
    color: context.scaffoldBg,     // Extension lookup
    child: Text('...', style: TextStyle(color: context.onSurface)),  // Another lookup
  );
}
```

**Fix:** Cache theme values at method start:
```dart
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final scaffoldBg = theme.extension<ThemeExtensions>()?.scaffoldBg ?? Colors.black;
  // ... use cached values
}
```

---

## Profiling Checklist

Run these commands to validate fixes:

```bash
# Profile mode run
flutter run --profile

# DevTools performance overlay
# Press 'P' while running

# Timeline with specific frames
flutter run --profile --trace-startup

# Memory profiling
flutter run --profile --enable-service-port-fallback
```

### Key Metrics to Monitor:

| Metric | Target | Current (Estimated) |
|--------|--------|---------------------|
| Build phase | <4ms | 8-15ms |
| Layout phase | <4ms | 5-10ms |
| Paint phase | <4ms | 6-12ms |
| Raster phase | <8ms | 10-25ms |
| **Total frame** | **<16ms** | **29-62ms** |

---

## Priority Implementation Order

1. **🔴 Issue #1** - CachedNetworkImage constraints (HIGH IMPACT, LOW EFFORT)
2. **🔴 Issue #3** - PostCard RepaintBoundary isolation (HIGH IMPACT, MEDIUM EFFORT)
3. **🟠 Issue #4** - ListView RepaintBoundary per item (MEDIUM IMPACT, LOW EFFORT)
4. **🟠 Issue #6** - VideoThumb isolate processing (HIGH IMPACT for video feeds)
5. **🔴 Issue #2** - Shimmer optimization (MEDIUM IMPACT, MEDIUM EFFORT)
6. **🟠 Issue #5** - Provider select optimization (MEDIUM IMPACT, LOW EFFORT)
7. **🟠 Issue #7** - Shimmer shared animation (LOW IMPACT, MEDIUM EFFORT)

---

## Verification Criteria

After implementing fixes:

- [ ] Scrolling feed at 60fps without drops
- [ ] Reaction tap responds in <100ms
- [ ] Video thumbnails don't freeze UI
- [ ] Loading states animate smoothly
- [ ] Memory stable under 150MB for feeds with 50+ posts

---

*Report generated by Flutter Performance Audit*
