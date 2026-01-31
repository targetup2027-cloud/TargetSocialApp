import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/motion/motion_system.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _language = 'English';
  String _appearance = 'Dark';
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      drawer: UAxisDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'LANGUAGE',
                    children: [
                      _SettingsItem(
                        icon: Icons.translate,
                        label: 'Language',
                        value: _language,
                        onTap: () => _showLanguageDialog(),
                      ),
                      _SettingsItem(
                        icon: Icons.dark_mode_outlined,
                        label: 'Appearance',
                        value: _appearance,
                        onTap: () => _showAppearanceDialog(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'PRIVACY & SECURITY',
                    children: [
                      _SettingsItem(
                        icon: Icons.shield_outlined,
                        label: 'Privacy Settings',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        value: _notificationsOn ? 'On' : 'Off',
                        onTap: () => setState(() => _notificationsOn = !_notificationsOn),
                      ),
                      _SettingsItem(
                        icon: Icons.credit_card_outlined,
                        label: 'Subscription',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    title: 'SUPPORT',
                    children: [
                      _SettingsItem(
                        icon: Icons.help_outline,
                        label: 'Help Center',
                        onTap: () {},
                      ),
                      _SettingsItem(
                        icon: Icons.replay_outlined,
                        label: 'Replay Tutorial',
                        onTap: () => context.push('/onboarding-overlay'),
                      ),
                      _SettingsItem(
                        icon: Icons.info_outline,
                        label: 'About U-AXIS',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _SignOutButton(onTap: () => context.go('/login')),
                  ),
                ],
              ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your preferences',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            title,
            style: TextStyle(
              color: const Color(0xFF8B5CF6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101014),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  void _showLanguageDialog() {
    showMotionModal(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF101014),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Select Language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ...['English', 'العربية', 'Español', 'Français'].map((lang) {
                  return ListTile(
                    title: Text(
                      lang,
                      style: TextStyle(
                        color: _language == lang ? const Color(0xFF8B5CF6) : Colors.white,
                      ),
                    ),
                    trailing: _language == lang
                        ? const Icon(Icons.check, color: Color(0xFF8B5CF6))
                        : null,
                    onTap: () {
                      setState(() => _language = lang);
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAppearanceDialog() {
    showMotionModal(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF101014),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Select Appearance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                ...['Dark', 'Light', 'System'].map((mode) {
                  return ListTile(
                    title: Text(
                      mode,
                      style: TextStyle(
                        color: _appearance == mode ? const Color(0xFF8B5CF6) : Colors.white,
                      ),
                    ),
                    trailing: _appearance == mode
                        ? const Icon(Icons.check, color: Color(0xFF8B5CF6))
                        : null,
                    onTap: () {
                      setState(() => _appearance = mode);
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.logout,
                  size: 22,
                  color: const Color(0xFFEF4444),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
