import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';

class AIToolsScreen extends StatefulWidget {
  const AIToolsScreen({super.key});

  @override
  State<AIToolsScreen> createState() => _AIToolsScreenState();
}

class _AIToolsScreenState extends State<AIToolsScreen> {
  int _selectedCategory = 0;
  final List<String> _categories = [
    'All Agents',
    'Productivity',
    'Creative',
    'Analytics'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: const UAxisDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _MarketplaceHeader(),
                      const _SearchBar(),
                      _CategoryFilters(
                        categories: _categories,
                        selectedIndex: _selectedCategory,
                        onSelected: (index) => setState(() => _selectedCategory = index),
                      ),
                      const _SortAndFilters(),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    const _AgentCard(
                      title: 'SmartWriter Pro',
                      badge: "Editor's Choice",
                      badgeColor: Color(0xFFFFB800),
                      description: 'AI-powered content creation for blogs, emails, and social media',
                      rating: '4.9',
                      users: '45,237 users',
                      successRate: '98%',
                      price: '\$29.99/month',
                      provider: 'by ContentLab AI',
                      iconColor: Color(0xFF3B82F6),
                      icon: Icons.edit_note,
                    ),
                    const _AgentCard(
                      title: 'DataInsight Engine',
                      badge: 'Trending',
                      badgeColor: Color(0xFF00D1FF),
                      description: 'Advanced analytics and predictive modeling for business intelligence',
                      rating: '4.8',
                      users: '23,456 users',
                      successRate: '96%',
                      price: '\$79.99/month',
                      provider: 'by Analytix Corp',
                      iconColor: Color(0xFF8B5CF6),
                      icon: Icons.bar_chart_rounded,
                    ),
                    const _AgentCard(
                      title: 'AutoFlow Assistant',
                      badge: 'Hot',
                      badgeColor: Color(0xFFEF4444),
                      description: 'Automate workflows and repetitive tasks across your tools',
                      rating: '4.7',
                      users: '34,891 users',
                      successRate: '94%',
                      price: 'Contact Us',
                      provider: 'by FlowMasters',
                      iconColor: Color(0xFFF59E0B),
                      icon: Icons.bolt_rounded,
                    ),
                    const _WorkflowSection(),
                    const _NewReleaseBanner(),
                    const SizedBox(height: 100),
                  ]),
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

class _MarketplaceHeader extends StatelessWidget {
  const _MarketplaceHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Marketplace',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Discover AI agents, tools, and workflows',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.3), size: 20),
            ),
            Expanded(
              child: TextField(
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search AI agents, tools, workflows...',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilters extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onSelected;

  const _CategoryFilters({
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final isSelected = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF00D1FF) : const Color(0xFF1A1A1F),
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected ? null : Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SortAndFilters extends StatelessWidget {
  const _SortAndFilters();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A1F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  Text(
                    'Most Popular',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  Icon(Icons.keyboard_arrow_down, color: Colors.white.withValues(alpha: 0.5), size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1F),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                Icon(Icons.tune, color: Colors.white.withValues(alpha: 0.5), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Filters',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AgentCard extends StatelessWidget {
  final String title;
  final String badge;
  final Color badgeColor;
  final String description;
  final String rating;
  final String users;
  final String successRate;
  final String price;
  final String provider;
  final Color iconColor;
  final IconData icon;

  const _AgentCard({
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.description,
    required this.rating,
    required this.users,
    required this.successRate,
    required this.price,
    required this.provider,
    required this.iconColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/agent-details', extra: {
          'title': title,
          'description': description,
          'price': price,
          'icon': icon,
          'iconColor': iconColor,
          'badge': badge,
          'badgeColor': badgeColor,
        });
      },
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 14),
              const SizedBox(width: 4),
              Text(rating, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 10),
              Icon(Icons.person_outline, color: Colors.white.withValues(alpha: 0.4), size: 14),
              const SizedBox(width: 4),
              Text(users, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11)),
              const SizedBox(width: 10),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(successRate, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            provider,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: price.split('/')[0],
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      if (price.contains('/'))
                        TextSpan(
                          text: '/${price.split('/')[1]}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                        ),
                    ],
                  ),
                ),
              ),
              _ActionButton(label: 'Try Free', isOutline: true, onPressed: () {}),
              const SizedBox(width: 8),
              _ActionButton(label: 'Subscribe', isOutline: false, onPressed: () {}),
            ],
          ),
        ],
      ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isOutline;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.isOutline,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: isOutline ? Colors.transparent : const Color(0xFF00D1FF),
        borderRadius: BorderRadius.circular(8),
        border: isOutline ? Border.all(color: Colors.white.withValues(alpha: 0.12)) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isOutline ? Colors.white : Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WorkflowSection extends StatelessWidget {
  const _WorkflowSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D1FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.hub_outlined, color: Color(0xFF00D1FF), size: 14),
              ),
              const SizedBox(width: 10),
              const Text(
                'Pre-built Workflows',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const _WorkflowCard(
          title: 'Social Media Manager',
          description: 'Auto-schedule, create, and optimize social posts',
          agents: '3 AI agents Included',
          status: 'Ready to use',
          icon: Icons.grid_view_rounded,
          iconColor: Color(0xFFEC4899),
        ),
        const _WorkflowCard(
          title: 'Email Campaign Builder',
          description: 'Design, send, and track email marketing campaigns',
          agents: '2 AI agents Included',
          status: 'Ready to use',
          icon: Icons.mail_outlined,
          iconColor: Color(0xFF8B5CF6),
        ),
        const _WorkflowCard(
          title: 'Sales Pipeline Optimizer',
          description: 'Automate lead scoring and follow-ups',
          agents: '4 AI agents Included',
          status: 'Ready to use',
          icon: Icons.track_changes_rounded,
          iconColor: Color(0xFFF59E0B),
        ),
      ],
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  final String title;
  final String description;
  final String agents;
  final String status;
  final IconData icon;
  final Color iconColor;

  const _WorkflowCard({
    required this.title,
    required this.description,
    required this.agents,
    required this.status,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      agents,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 10),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(color: Color(0xFF00D1FF), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status,
                      style: const TextStyle(color: Color(0xFF00D1FF), fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF00D1FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    child: Text(
                      'Install',
                      style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NewReleaseBanner extends StatelessWidget {
  const _NewReleaseBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0A1929), Color(0xFF0D2847)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF00D1FF).withValues(alpha: 0.15)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Opacity(
              opacity: 0.08,
              child: Icon(Icons.auto_awesome, size: 140, color: const Color(0xFF00D1FF)),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt, color: Color(0xFFFFB800), size: 14),
                  const SizedBox(width: 6),
                  const Text(
                    'NEW RELEASE',
                    style: TextStyle(
                      color: Color(0xFFFFB800),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Build Your Own AI Agent',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'No coding required. Train custom AI models for your specific needs.',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),
              Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(10),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: Text(
                          'Get Started Free',
                          style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
