import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../app/theme/theme_extensions.dart';

class BusinessLinksSheet extends StatefulWidget {
  final bool isOwner;
  final ScrollController? scrollController;

  const BusinessLinksSheet({
    super.key,
    required this.isOwner,
    this.scrollController,
  });

  static void show(BuildContext context, {required bool isOwner}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, controller) => BusinessLinksSheet(
          isOwner: isOwner,
          scrollController: controller,
        ),
      ),
    );
  }

  @override
  State<BusinessLinksSheet> createState() => _BusinessLinksSheetState();
}

class _BusinessLinksSheetState extends State<BusinessLinksSheet> {
  final List<Map<String, dynamic>> _links = [
    {
      'id': '1',
      'title': 'Official Website',
      'url': 'https://u-axis.com',
      'icon': Icons.language,
      'color': const Color(0xFF3B82F6),
    },
    {
      'id': '2',
      'title': 'Portfolio',
      'url': 'https://dribbble.com/uaxis',
      'icon': FontAwesomeIcons.dribbble,
      'color': const Color(0xFFEA4C89),
    },
    {
      'id': '3',
      'title': 'Book a Call',
      'url': 'https://calendly.com/uaxis',
      'icon': Icons.calendar_today_rounded,
      'color': const Color(0xFF10B981),
    },
  ];

  final _linkTypes = [
    {'title': 'Website', 'icon': Icons.language, 'color': const Color(0xFF3B82F6)},
    {'title': 'Portfolio', 'icon': FontAwesomeIcons.briefcase, 'color': const Color(0xFF8B5CF6)},
    {'title': 'Dribbble', 'icon': FontAwesomeIcons.dribbble, 'color': const Color(0xFFEA4C89)},
    {'title': 'Behance', 'icon': FontAwesomeIcons.behance, 'color': const Color(0xFF1769FF)},
    {'title': 'GitHub', 'icon': FontAwesomeIcons.github, 'color': const Color(0xFF333333)},
    {'title': 'LinkedIn', 'icon': FontAwesomeIcons.linkedinIn, 'color': const Color(0xFF0A66C2)},
    {'title': 'Book a Call', 'icon': Icons.calendar_today_rounded, 'color': const Color(0xFF10B981)},
    {'title': 'Shop', 'icon': Icons.shopping_bag_rounded, 'color': const Color(0xFFF59E0B)},
    {'title': 'Custom', 'icon': Icons.link_rounded, 'color': const Color(0xFF6B7280)},
  ];

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showAddLinkDialog() {
    String selectedType = 'Website';
    String title = '';
    String url = '';
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Add New Link',
                      style: TextStyle(
                        color: context.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close, color: context.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Link Type', style: TextStyle(color: context.onSurfaceVariant, fontSize: 14)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _linkTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final type = _linkTypes[index];
                      final isSelected = type['title'] == selectedType;
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() => selectedType = type['title'] as String);
                          if (title.isEmpty) {
                            title = type['title'] as String;
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 70,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (type['color'] as Color).withValues(alpha: 0.15)
                                : context.scaffoldBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? type['color'] as Color
                                  : context.dividerColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                type['icon'] as IconData,
                                color: type['color'] as Color,
                                size: 24,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                type['title'] as String,
                                style: TextStyle(
                                  color: context.onSurface,
                                  fontSize: 10,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. My Portfolio',
                    filled: true,
                    fillColor: context.scaffoldBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                  ),
                  style: TextStyle(color: context.onSurface),
                  onChanged: (v) => title = v,
                  validator: (v) => v?.isEmpty ?? true ? 'Title is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'URL',
                    hintText: 'https://example.com',
                    filled: true,
                    fillColor: context.scaffoldBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: context.dividerColor),
                    ),
                  ),
                  style: TextStyle(color: context.onSurface),
                  keyboardType: TextInputType.url,
                  onChanged: (v) => url = v,
                  validator: (v) {
                    if (v?.isEmpty ?? true) return 'URL is required';
                    if (!v!.startsWith('http://') && !v.startsWith('https://')) {
                      return 'URL must start with http:// or https://';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        final selectedTypeData = _linkTypes.firstWhere(
                          (t) => t['title'] == selectedType,
                          orElse: () => _linkTypes.last,
                        );
                        setState(() {
                          _links.add({
                            'id': DateTime.now().millisecondsSinceEpoch.toString(),
                            'title': title.isEmpty ? selectedType : title,
                            'url': url,
                            'icon': selectedTypeData['icon'],
                            'color': selectedTypeData['color'],
                          });
                        });
                        Navigator.pop(ctx);
                        HapticFeedback.mediumImpact();
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Link added successfully'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add Link', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditMenu(int index) {
    final link = _links[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: context.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.open_in_new, color: context.primaryColor),
              title: Text('Open Link', style: TextStyle(color: context.onSurface)),
              onTap: () {
                Navigator.pop(ctx);
                _launchUrl(link['url']);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy, color: context.iconColor),
              title: Text('Copy URL', style: TextStyle(color: context.onSurface)),
              onTap: () {
                Clipboard.setData(ClipboardData(text: link['url']));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('URL copied to clipboard'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              title: const Text('Delete Link', style: TextStyle(color: Color(0xFFEF4444))),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(index);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Link?', style: TextStyle(color: context.onSurface)),
        content: Text(
          'Are you sure you want to delete "${_links[index]['title']}"?',
          style: TextStyle(color: context.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: context.hintColor)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _links.removeAt(index));
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Link deleted'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
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
          Container(
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
                    Icon(
                      Icons.business_center_rounded,
                      color: context.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Business Links',
                      style: TextStyle(
                        color: context.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (widget.isOwner)
                      IconButton(
                        onPressed: _showAddLinkDialog,
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: context.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, color: context.primaryColor, size: 20),
                        ),
                      ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: context.onSurface),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _links.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.link_off_rounded,
                          size: 48,
                          color: context.hintColor.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No business links yet',
                          style: TextStyle(
                            color: context.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                        if (widget.isOwner) ...[
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showAddLinkDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Your First Link'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: _links.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final link = _links[index];
                      return _LinkCard(
                        title: link['title'],
                        url: link['url'],
                        icon: link['icon'],
                        color: link['color'],
                        onTap: () => _launchUrl(link['url']),
                        onEdit: widget.isOwner ? () => _showEditMenu(index) : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String title;
  final String url;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _LinkCard({
    required this.title,
    required this.url,
    required this.icon,
    required this.color,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: context.onSurface,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        url.replaceAll('https://', '').replaceAll('http://', ''),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(Icons.more_vert, color: context.hintColor),
                  )
                else
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: context.hintColor,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
