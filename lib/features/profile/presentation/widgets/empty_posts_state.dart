import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../app/theme/theme_extensions.dart';

class EmptyPostsState extends StatelessWidget {
  final VoidCallback? onCreatePost;

  const EmptyPostsState({super.key, this.onCreatePost});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
      sliver: SliverToBoxAdapter(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(
                FontAwesomeIcons.featherPointed,
                size: 40,
                color: context.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No posts yet',
              style: TextStyle(
                color: context.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your first moment with the world.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.onSurfaceVariant,
                fontSize: 14,
              ),
            ),
            if (onCreatePost != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onCreatePost,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Post'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
