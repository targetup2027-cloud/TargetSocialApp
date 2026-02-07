import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../../../core/motion/motion_system.dart';
import '../../../../core/widgets/animated_list_item.dart';

class SocialConnectionsSheet extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  
  const SocialConnectionsSheet({super.key, this.scrollController});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SocialConnectionsSheet(scrollController: scrollController);
          },
        );
      },
    );
  }

  @override
  ConsumerState<SocialConnectionsSheet> createState() => _SocialConnectionsSheetState();
}

class _SocialConnectionsSheetState extends ConsumerState<SocialConnectionsSheet> {
  // Mock state for connected platforms
  final Map<String, bool> _connected = {
    'Instagram': false,
    'Facebook': false,
    'YouTube': false,
    'LinkedIn': false,
    'X (Twitter)': false,
  };

  // Mock settings for each platform
  final Map<String, Map<String, dynamic>> _settings = {
    'Instagram': {
      'autoPublish': true,
      'postType': 'Post', // Post, Reel, Story
      'shareToFacebook': false,
    },
    'Facebook': {
      'autoPublish': true,
      'destination': 'Page', // Page, Group
      'selectedPage': 'My Awesome Page',
    },
    'YouTube': {
      'privacy': 'Public', // Public, Private, Unlisted
      'notifySubscribers': true,
      'autoShorts': false,
    },
    'LinkedIn': {
      'destination': 'Profile', // Profile, Company Page
      'autoPublish': true,
    },
    'X (Twitter)': {
      'autoPublish': true,
      'threadSupport': true,
    },
  };

  void _toggleConnection(String platform) {
    setState(() {
      final isConnected = _connected[platform] ?? false;
      if (!isConnected) {
        // Simulate connecting...
        _connected[platform] = true;
        HapticFeedback.mediumImpact();
      } else {
        // Confirm disconnect
        _showDisconnectDialog(platform);
      }
    });
  }

  void _showDisconnectDialog(String platform) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('Disconnect $platform?', style: TextStyle(color: context.onSurface)),
        content: Text(
          'Are you sure you want to disconnect $platform? Scheduled posts for this platform will not be published.',
          style: TextStyle(color: context.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.hintColor)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _connected[platform] = false);
              Navigator.pop(ctx);
            },
            child: const Text('Disconnect', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.scaffoldBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              children: [
                _buildSectionHeader('Active Platforms'),
                const SizedBox(height: 12),
                _buildPlatformItem(
                  'Instagram',
                  Icons.camera_alt_outlined,
                  const [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCAF45)],
                  _buildInstagramSettings,
                ),
                const SizedBox(height: 16),
                _buildPlatformItem(
                  'Facebook',
                  Icons.facebook,
                  const [Color(0xFF1877F2), Color(0xFF1877F2)],
                  _buildFacebookSettings,
                ),
                const SizedBox(height: 16),
                _buildPlatformItem(
                  'YouTube',
                  Icons.play_arrow_rounded,
                  const [Color(0xFFFF0000), Color(0xFFCC0000)],
                  _buildYouTubeSettings,
                ),
                const SizedBox(height: 16),
                _buildPlatformItem(
                  'LinkedIn',
                  Icons.business,
                  const [Color(0xFF0A66C2), Color(0xFF0077B5)],
                  _buildLinkedInSettings,
                ),
                const SizedBox(height: 16),
                _buildPlatformItem(
                  'X (Twitter)',
                  Icons.close, // Using close icon as X logo proxy or custom svg
                  const [Colors.black, Colors.black87],
                  _buildTwitterSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.dividerColor)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.hintColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Auto-Publish Settings',
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: context.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your automated workflow and platform-specific configurations.',
            style: TextStyle(color: context.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: context.hintColor,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildPlatformItem(
    String name,
    IconData icon,
    List<Color> gradientColors,
    Widget Function() buildSettings,
  ) {
    final isConnected = _connected[name] ?? false;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isConnected ? context.primaryColor.withValues(alpha: 0.3) : context.dividerColor,
          width: isConnected ? 1.5 : 1,
        ),
        boxShadow: isConnected
            ? [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          color: context.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isConnected ? const Color(0xFF10B981) : context.hintColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isConnected ? 'Connected as @username' : 'Not connected',
                            style: TextStyle(
                              color: isConnected ? const Color(0xFF10B981) : context.hintColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: isConnected,
                  onChanged: (_) => _toggleConnection(name),
                  activeColor: const Color(0xFF10B981),
                ),
              ],
            ),
          ),
          if (isConnected) _buildExpandedSettings(buildSettings),
        ],
      ),
    );
  }

  Widget _buildExpandedSettings(Widget Function() contentBuilder) {
    return Container(
      decoration: BoxDecoration(
        color: context.scaffoldBg.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
        border: Border(top: BorderSide(color: context.dividerColor)),
      ),
      padding: const EdgeInsets.all(16),
      child: contentBuilder(),
    );
  }

  // --- Platform Specific Settings Builders ---

  Widget _buildInstagramSettings() {
    final settings = _settings['Instagram']!;
    return Column(
      children: [
        _buildSettingRow(
          'Auto-Publish',
          'Automatically publish posts without manual approval',
          settings['autoPublish'],
          (val) => setState(() => settings['autoPublish'] = val),
        ),
        const SizedBox(height: 16),
        _buildDropdownSetting(
          'Default Post Type',
          settings['postType'],
          ['Post', 'Reel', 'Story'],
          (val) => setState(() => settings['postType'] = val),
        ),
        const SizedBox(height: 16),
        _buildSettingRow(
          'Cross-post to Facebook',
          'Share posts automatically to linked FB Page',
          settings['shareToFacebook'],
          (val) => setState(() => settings['shareToFacebook'] = val),
        ),
      ],
    );
  }

  Widget _buildFacebookSettings() {
    final settings = _settings['Facebook']!;
    return Column(
      children: [
        _buildDropdownSetting(
          'Destination',
          settings['destination'],
          ['Page', 'Group'],
          (val) => setState(() => settings['destination'] = val),
        ),
        const SizedBox(height: 12),
        if (settings['destination'] == 'Page')
          _buildDropdownSetting(
            'Select Page',
            settings['selectedPage'],
            ['My Awesome Page', 'Tech Blog', 'Photography Studio'],
            (val) => setState(() => settings['selectedPage'] = val),
          ),
      ],
    );
  }

  Widget _buildYouTubeSettings() {
    final settings = _settings['YouTube']!;
    return Column(
      children: [
        _buildDropdownSetting(
          'Default Privacy',
          settings['privacy'],
          ['Public', 'Private', 'Unlisted'],
          (val) => setState(() => settings['privacy'] = val),
        ),
        const SizedBox(height: 16),
        _buildSettingRow(
          'Notify Subscribers',
          'Send notification to subscribers on publish',
          settings['notifySubscribers'],
          (val) => setState(() => settings['notifySubscribers'] = val),
        ),
        const SizedBox(height: 16),
        _buildSettingRow(
          'Auto-Shorts',
          'Convert short videos (<60s) to Shorts automatically',
          settings['autoShorts'],
          (val) => setState(() => settings['autoShorts'] = val),
        ),
      ],
    );
  }

  Widget _buildLinkedInSettings() {
    final settings = _settings['LinkedIn']!;
    return Column(
      children: [
        _buildDropdownSetting(
          'Post As',
          settings['destination'],
          ['Profile', 'Company Page'],
          (val) => setState(() => settings['destination'] = val),
        ),
        const SizedBox(height: 16),
        _buildSettingRow(
          'Auto-Publish',
          'Skip review for LinkedIn posts',
          settings['autoPublish'],
          (val) => setState(() => settings['autoPublish'] = val),
        ),
      ],
    );
  }

  Widget _buildTwitterSettings() {
    final settings = _settings['X (Twitter)']!;
    return Column(
      children: [
        _buildSettingRow(
          'Thread Support',
          'Automatically split long posts into threads',
          settings['threadSupport'],
          (val) => setState(() => settings['threadSupport'] = val),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildSettingRow(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: context.onSurfaceVariant, fontSize: 11)),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: context.primaryColor,
        ),
      ],
    );
  }

  Widget _buildDropdownSetting(String title, String currentValue, List<String> options, Function(String?) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: context.onSurface, fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.dividerColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: onChanged,
              style: TextStyle(color: context.onSurface, fontSize: 13),
              icon: Icon(Icons.arrow_drop_down, color: context.iconColor),
              isDense: true,
              dropdownColor: context.cardColor,
            ),
          ),
        ),
      ],
    );
  }
}
