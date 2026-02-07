import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/privacy_controls_controller.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../../profile/presentation/widgets/business_links_sheet.dart';

class PrivacyControlsContent extends ConsumerWidget {
  const PrivacyControlsContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(privacyControlsProvider);
    final controller = ref.read(privacyControlsProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      // Ensure height is reasonable or constrained if needed
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Privacy Controls',
                  style: TextStyle(
                    color: context.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.lock_outline, size: 16, color: context.subtleIconColor),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _PrivacyRow(
            label: 'Phone Number',
            value: state.phoneNumber,
            onChanged: (val) {
              controller.updatePrivacy(phoneNumber: val);
              _showFeedback(context, 'Phone visibility updated');
            },
          ),
          _PrivacyRow(
            label: 'Email Address',
            value: state.email,
            onChanged: (val) {
              controller.updatePrivacy(email: val);
              _showFeedback(context, 'Email visibility updated');
            },
          ),
          _PrivacyRow(
            label: 'Location', // Could be 'Profile Location' per UX feedback
            value: state.location,
            onChanged: (val) {
              controller.updatePrivacy(location: val);
              _showFeedback(context, 'Location visibility updated');
            },
          ),
          _PrivacyRow(
            label: 'Website',
            value: state.website,
            onChanged: (val) {
              controller.updatePrivacy(website: val);
              _showFeedback(context, 'Website visibility updated');
            },
          ),
          _BusinessLinksRow(
            value: state.businessLinks,
            onPrivacyChanged: (val) {
              controller.updatePrivacy(businessLinks: val);
              _showFeedback(context, 'Business Links visibility updated');
            },
            onManageLinks: () {
              BusinessLinksSheet.show(context, isOwner: true);
            },
          ),
        ],
      ),
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _PrivacyRow extends StatelessWidget {
  final String label;
  final PrivacyLevel value;
  final ValueChanged<PrivacyLevel> onChanged;

  const _PrivacyRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.onSurface,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          _PrivacyDropdown(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _BusinessLinksRow extends StatelessWidget {
  final PrivacyLevel value;
  final ValueChanged<PrivacyLevel> onPrivacyChanged;
  final VoidCallback onManageLinks;

  const _BusinessLinksRow({
    required this.value,
    required this.onPrivacyChanged,
    required this.onManageLinks,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Navigation Trigger
          InkWell(
            onTap: onManageLinks,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Row(
                children: [
                  Icon(Icons.chevron_right, size: 20, color: context.subtleIconColor),
                  const SizedBox(width: 8),
                  Text(
                    'Business Links',
                    style: TextStyle(
                      color: context.onSurface,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Privacy Control
          _PrivacyDropdown(value: value, onChanged: onPrivacyChanged),
        ],
      ),
    );
  }
}

class _PrivacyDropdown extends StatelessWidget {
  final PrivacyLevel value;
  final ValueChanged<PrivacyLevel> onChanged;

  const _PrivacyDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: _getBgColor(context),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Theme(
        // Remove underline
        data: Theme.of(context).copyWith(
          canvasColor: context.cardColor, 
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<PrivacyLevel>(
            value: value,
            icon: Icon(Icons.keyboard_arrow_down, size: 16, color: _getTextColor(context)),
            style: TextStyle(
              color: _getTextColor(context),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            onChanged: (val) {
              if (val != null) onChanged(val);
            },
            items: PrivacyLevel.values.map((level) {
              return DropdownMenuItem(
                value: level,
                child: Text(_getLabel(level)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  String _getLabel(PrivacyLevel level) {
    switch (level) {
      case PrivacyLevel.public:
        return 'Public';
      case PrivacyLevel.friendsOnly:
        return 'Friends Only';
      case PrivacyLevel.private:
        return 'Private';
    }
  }

  Color _getBgColor(BuildContext context) {
    return const Color(0xFF1E1B2E);
  }

  Color _getTextColor(BuildContext context) {
    return const Color(0xFFA78BFA);
  }
}
