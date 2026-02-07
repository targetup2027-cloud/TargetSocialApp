import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme_controller.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/motion/motion_system.dart';
import '../../business/domain/entities/business_plan.dart';
import '../../ai_hub/application/ai_controller.dart';
import 'widgets/privacy_controls_content.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _language = 'English';
  bool _notificationsOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.scaffoldBg,
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
                        value: _getAppearanceLabel(ref.watch(themeControllerProvider)),
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
                        onTap: () => _showPrivacySettings(),
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
                        onTap: () => _showSubscriptionInfo(),
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
                        onTap: () => _showHelpCenter(),
                      ),
                      _SettingsItem(
                        icon: Icons.replay_outlined,
                        label: 'Replay Tutorial',
                        onTap: () => context.push('/onboarding-overlay'),
                      ),
                      _SettingsItem(
                        icon: Icons.info_outline,
                        label: 'About U-AXIS',
                        onTap: () => _showAboutDialog(),
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
          Text(
            'Settings',
            style: TextStyle(
              color: context.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Manage your preferences',
            style: TextStyle(
              color: context.hintColor,
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
              color: context.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.dividerColor,
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
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.dividerColor,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Select Language',
                    style: TextStyle(
                      color: context.onSurface,
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
                          color: _language == lang ? const Color(0xFF8B5CF6) : context.onSurface,
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
          ),
        );
      },
    );
  }

  String _getAppearanceLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.system:
        return 'System';
    }
  }

  ThemeMode _getThemeModeFromLabel(String label) {
    switch (label) {
      case 'Dark':
        return ThemeMode.dark;
      case 'Light':
        return ThemeMode.light;
      case 'System':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  void _showAppearanceDialog() {
    final currentMode = ref.read(themeControllerProvider);
    showMotionModal(
      context: context,
      builder: (dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.dividerColor,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Select Appearance',
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...['Dark', 'Light', 'System'].map((mode) {
                    final isSelected = _getAppearanceLabel(currentMode) == mode;
                    return ListTile(
                      title: Text(
                        mode,
                        style: TextStyle(
                          color: isSelected ? const Color(0xFF8B5CF6) : context.onSurface,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFF8B5CF6))
                          : null,
                      onTap: () {
                        ref.read(themeControllerProvider.notifier).setThemeMode(_getThemeModeFromLabel(mode));
                        Navigator.pop(dialogContext);
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showPrivacySettings() {
    showMotionModal(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.dividerColor,
                ),
              ),
              child: const PrivacyControlsContent(),
            ),
          ),
        );
      },
    );
  }

  void _showSubscriptionInfo() {
    showMotionModal(
      context: context,
      builder: (modalContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(modalContext).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: modalContext.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: modalContext.dividerColor,
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBusinessPlanSection(modalContext),
                    const SizedBox(height: 28),
                    _buildAiSubscriptionsSection(modalContext),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBusinessPlanSection(BuildContext modalContext) {
    const currentPlan = BusinessPlan.free;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
                ),
              ),
              child: const Icon(Icons.business_center, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Business Plan',
                  style: TextStyle(
                    color: modalContext.hintColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${currentPlan.name} Plan',
                  style: TextStyle(
                    color: modalContext.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  color: Color(0xFF22C55E),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: modalContext.scaffoldBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: modalContext.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentPlan.mediaLimitText,
                    style: TextStyle(
                      color: modalContext.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${currentPlan.price}/${currentPlan.billingCycle}',
                    style: TextStyle(
                      color: const Color(0xFF8B5CF6),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: currentPlan.features.take(3).map((feature) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: const Color(0xFF22C55E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        feature,
                        style: TextStyle(
                          color: modalContext.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.pop(modalContext);
            context.push('/business-plans');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Upgrade Business Plan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAiSubscriptionsSection(BuildContext modalContext) {
    final aiSubscriptions = ref.watch(mySubscriptionsProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [const Color(0xFF06B6D4), const Color(0xFF8B5CF6)],
                ),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'AI Agent Subscriptions',
              style: TextStyle(
                color: modalContext.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        aiSubscriptions.when(
          data: (subscriptions) {
            if (subscriptions.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: modalContext.scaffoldBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: modalContext.dividerColor),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.smart_toy_outlined,
                      size: 40,
                      color: modalContext.hintColor,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No AI Subscriptions',
                      style: TextStyle(
                        color: modalContext.onSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore AI agents to boost your productivity',
                      style: TextStyle(
                        color: modalContext.hintColor,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            
            return Column(
              children: subscriptions.map((sub) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: modalContext.scaffoldBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: modalContext.dividerColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.smart_toy,
                          size: 20,
                          color: Color(0xFF8B5CF6),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub.planName,
                              style: TextStyle(
                                color: modalContext.onSurface,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Expires ${_formatDate(sub.endDate)}',
                              style: TextStyle(
                                color: modalContext.hintColor,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$${sub.price.toStringAsFixed(2)}/mo',
                            style: TextStyle(
                              color: const Color(0xFF8B5CF6),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (sub.messagesLimit != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${sub.messagesUsed}/${sub.messagesLimit} msgs',
                              style: TextStyle(
                                color: modalContext.hintColor,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
          loading: () => Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(
                color: const Color(0xFF8B5CF6),
                strokeWidth: 2,
              ),
            ),
          ),
          error: (_, __) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Failed to load subscriptions',
              style: TextStyle(
                color: const Color(0xFFEF4444),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            Navigator.pop(modalContext);
            context.push('/ai-hub');
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF8B5CF6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'Explore AI Agents',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showHelpCenter() {
    showMotionModal(
      context: context,
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: context.dividerColor,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Help Center',
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: Icon(Icons.question_answer_outlined, color: context.subtleIconColor),
                    title: Text('FAQs', style: TextStyle(color: context.onSurface)),
                    trailing: Icon(Icons.chevron_right, color: context.hintColor),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening FAQs...')),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.email_outlined, color: context.subtleIconColor),
                    title: Text('Contact Support', style: TextStyle(color: context.onSurface)),
                    trailing: Icon(Icons.chevron_right, color: context.hintColor),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening email...')),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined, color: context.subtleIconColor),
                    title: Text('Send Feedback', style: TextStyle(color: context.onSurface)),
                    trailing: Icon(Icons.chevron_right, color: context.hintColor),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Opening feedback form...')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAboutDialog() {
    showMotionModal(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.dividerColor,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'U-AXIS',
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: context.hintColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'The next-generation social commerce platform connecting creators, businesses, and communities.',
                  style: TextStyle(
                    color: context.onSurfaceVariant,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Text(
                  '© 2026 U-AXIS. All rights reserved.',
                  style: TextStyle(
                    color: context.hintColor,
                    fontSize: 12,
                  ),
                ),
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
                color: context.subtleIconColor,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 15,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    color: context.hintColor,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: context.hintColor,
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
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.dividerColor,
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
