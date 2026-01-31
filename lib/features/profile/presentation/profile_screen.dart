import 'package:flutter/material.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Posts', 'Media', 'About', 'Connections'];

  bool _instagramConnected = true;
  bool _youtubeConnected = false;
  bool _facebookConnected = false;
  bool _linkedinConnected = true;

  String _phonePrivacy = 'Private';
  String _emailPrivacy = 'Friends Only';
  String _locationPrivacy = 'Public';
  String _websitePrivacy = 'Public';
  String _businessLinksPrivacy = 'Public';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        drawer: UAxisDrawer(),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCoverAndAvatar(),
                      _buildProfileInfo(),
                      _buildTrustScore(),
                      _buildStats(),
                      _buildCreatePostButton(),
                      _buildConnections(),
                      const SizedBox(height: 24),
                      _buildConnectedPlatforms(),
                      const SizedBox(height: 24),
                      _buildPrivacyControls(),
                      const SizedBox(height: 24),
                      _buildTabBar(),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildPostCard(),
                      childCount: 1,
                    ),
                  ),
                ),
              ],
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

  Widget _buildCoverAndAvatar() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 160,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1573164713988-8665fc963095?w=800&h=400&fit=crop',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 50,
          right: 16,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit, size: 12, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Edit Cover',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: 20,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0A0A0A), width: 4),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400&h=400&fit=crop&crop=faces',
                    ),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3B82F6),
                    border: Border.all(color: const Color(0xFF0A0A0A), width: 2),
                  ),
                  child: const Icon(Icons.check, size: 14, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1F2937),
                      border: Border.all(color: const Color(0xFF0A0A0A), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Sarah Anderson',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: Icon(
                  Icons.edit,
                  size: 16,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            '@sarahanderson',
            style: TextStyle(
              color: Color(0xFF3B82F6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Designer • Entrepreneur • Creator',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('✨ ', style: TextStyle(fontSize: 14)),
              Text(
                'Building beautiful digital experiences',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: Color(0xFFEC4899)),
              const SizedBox(width: 4),
              Text(
                'Dubai, UAE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustScore() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF101014),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      value: 0.87,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                  const Text(
                    '87%',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
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
                    children: const [
                      Icon(Icons.verified_outlined, size: 16, color: Color(0xFF8B5CF6)),
                      SizedBox(width: 6),
                      Text(
                        'Trust Score',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Complete your profile to increase trust',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Complete Profile →',
                    style: TextStyle(
                      color: Color(0xFF8B5CF6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: const [
          _StatColumn(value: '45,237', label: 'Followers'),
          _StatColumn(value: '892', label: 'Following'),
          _StatColumn(value: '234', label: 'Friends'),
        ],
      ),
    );
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
            onTap: () {},
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
              const Text(
                'Connections',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'See All',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 14,
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
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                              'https://i.pravatar.cc/100?img=${index + 10}',
                            ),
                            fit: BoxFit.cover,
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

  Widget _buildConnectedPlatforms() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connected Social Platforms',
            style: TextStyle(
              color: Colors.white,
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
            subtitle: _instagramConnected ? 'Connected' : 'Not connected',
            isConnected: _instagramConnected,
            onChanged: (v) => setState(() => _instagramConnected = v),
          ),

          _PlatformTile(
            icon: FontAwesomeIcons.youtube,
            iconColor: Colors.white,
            iconDecoration: const BoxDecoration(
              color: Color(0xFFFF0000),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            name: 'YouTube',
            subtitle: _youtubeConnected ? 'Connected' : 'Not connected',
            isConnected: _youtubeConnected,
            onChanged: (v) => setState(() => _youtubeConnected = v),
          ),

          _PlatformTile(
            icon: FontAwesomeIcons.facebookF,
            iconColor: Colors.white,
            iconDecoration: const BoxDecoration(
              color: Color(0xFF1877F2),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            name: 'Facebook',
            subtitle: _facebookConnected ? 'Connected' : 'Not connected',
            isConnected: _facebookConnected,
            onChanged: (v) => setState(() => _facebookConnected = v),
          ),

          _PlatformTile(
            icon: FontAwesomeIcons.linkedinIn,
            iconColor: Colors.white,
            iconDecoration: const BoxDecoration(
              color: Color(0xFF0A66C2),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            name: 'LinkedIn',
            subtitle: _linkedinConnected ? 'Connected' : 'Not connected',
            isConnected: _linkedinConnected,
            onChanged: (v) => setState(() => _linkedinConnected = v),
          ),

          const SizedBox(height: 16),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: Center(
              child: Text(
                'Manage Connections',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Privacy Controls',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.lock_outline,
                size: 16,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _PrivacyRow(
            label: 'Phone Number',
            value: _phonePrivacy,
            isPurple: _phonePrivacy == 'Private',
            onChanged: (v) => setState(() => _phonePrivacy = v),
          ),
          _PrivacyRow(
            label: 'Email Address',
            value: _emailPrivacy,
            isPurple: _emailPrivacy == 'Friends Only',
            onChanged: (v) => setState(() => _emailPrivacy = v),
          ),
          _PrivacyRow(
            label: 'Location',
            value: _locationPrivacy,
            isPurple: false,
            onChanged: (v) => setState(() => _locationPrivacy = v),
          ),
          _PrivacyRow(
            label: 'Website',
            value: _websitePrivacy,
            isPurple: false,
            onChanged: (v) => setState(() => _websitePrivacy = v),
          ),
          _PrivacyRow(
            label: 'Business Links',
            value: _businessLinksPrivacy,
            isPurple: false,
            onChanged: (v) => setState(() => _businessLinksPrivacy = v),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final isSelected = _selectedTab == index;
            return GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Padding(
                padding: const EdgeInsets.only(right: 24),
                child: Column(
                  children: [
                    Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF3B82F6)
                            : Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 2,
                      width: 40,
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildPostCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1558171813-4c088753af8f?w=600&h=400&fit=crop',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '1,234',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '89',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.more_horiz,
                      size: 20,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'New design system launching soon! 🎨 ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '2h ago',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final BoxDecoration? iconDecoration;
  final String name;
  final String subtitle;
  final bool isConnected;
  final ValueChanged<bool> onChanged;

  const _PlatformTile({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.subtitle,
    required this.isConnected,
    required this.onChanged,
    this.iconDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final decoration = iconDecoration ??
        BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: decoration,
            child: Center(
              child: FaIcon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isConnected,
            onChanged: onChanged,
            activeTrackColor: const Color(0xFF3B82F6),
          ),
        ],
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isPurple;
  final ValueChanged<String> onChanged;

  const _PrivacyRow({
    required this.label,
    required this.value,
    required this.isPurple,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isPurple
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isPurple
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: isPurple
                        ? const Color(0xFF8B5CF6)
                        : Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: isPurple
                      ? const Color(0xFF8B5CF6)
                      : Colors.white.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
