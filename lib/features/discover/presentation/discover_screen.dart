import 'package:flutter/material.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/motion/motion_system.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  int _selectedFilter = 0;
  final List<String> _filters = ['All', 'People', 'Places', 'Trending'];

  final List<_TrendingItem> _trendingItems = [
    _TrendingItem(
      title: 'Dubai Marina Sunset Views',
      author: 'Sarah Anderson',
      likes: '125K',
      views: '2.4M',
      duration: '2:34',
      isVerified: true,
    ),
    _TrendingItem(
      title: 'Minimalist Interior Design',
      author: 'Alex Chen',
      likes: '45K',
      views: '890K',
      duration: '5:12',
      isVerified: false,
    ),
    _TrendingItem(
      title: 'Tokyo Night Life',
      author: 'Yuki Tanaka',
      likes: '89K',
      views: '1.2M',
      duration: '3:45',
      isVerified: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
                    'Discover',
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
                          'Search everything...',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                                  : const Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.white.withValues(alpha: 0.1),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                if (index == 0)
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                if (index == 1)
                                  Icon(
                                    Icons.people_outline,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.6),
                                  ),
                                if (index == 2)
                                  Icon(
                                    Icons.location_on_outlined,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.6),
                                  ),
                                if (index == 3)
                                  Icon(
                                    Icons.trending_up,
                                    size: 14,
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.6),
                                  ),
                                if (index > 0) const SizedBox(width: 4),
                                Text(
                                  _filters[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white.withValues(alpha: 0.6),
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

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: const Color(0xFF3B82F6),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Trending Now',
                        style: TextStyle(
                          color: Colors.white,
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
                      return HoverScaleCard(
                        child: _TrendingCard(item: _trendingItems[index]),
                      );
                    },
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

class _TrendingItem {
  final String title;
  final String author;
  final String likes;
  final String views;
  final String duration;
  final bool isVerified;

  const _TrendingItem({
    required this.title,
    required this.author,
    required this.likes,
    required this.views,
    required this.duration,
    required this.isVerified,
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
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF2A2A4A),
                      const Color(0xFF1A1A2E),
                    ],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
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
                    style: TextStyle(
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
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6366F1),
                      const Color(0xFFAB5CF6),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 18,
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
                        color: Colors.white,
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
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                        ),
                        if (item.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            color: const Color(0xFF3B82F6),
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
