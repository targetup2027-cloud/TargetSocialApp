import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/theme_extensions.dart';
import '../../../core/widgets/uaxis_drawer.dart';
import '../../../core/widgets/universe_back_button.dart';
import '../../../core/motion/motion_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/business.dart';
import '../application/business_controller.dart';
import 'business_detail_screen.dart';

class BusinessScreen extends ConsumerWidget {
  const BusinessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final businessesState = ref.watch(userBusinessesProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      drawer: const UAxisDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 56),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Business OS',
                        style: TextStyle(
                          color: context.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your businesses',
                        style: TextStyle(
                          color: context.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: businessesState.when(
                    data: (businesses) => ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: businesses.length + 1,
                      itemBuilder: (context, index) {
                        if (index == businesses.length) {
                          return const Column(
                            children: [
                              SizedBox(height: 24),
                              _AddBusinessButton(),
                              SizedBox(height: 32),
                            ],
                          );
                        }

                        final business = businesses[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _BusinessCard(business: business),
                        );
                      },
                    ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Color(0xFF10B981)),
                    ),
                    error: (e, s) => Center(
                      child: Text(
                        'Error loading businesses',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
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

class _BusinessCard extends StatelessWidget {
  final Business business;

  const _BusinessCard({required this.business});

  @override
  Widget build(BuildContext context) {
    final imageUrl = business.logoUrl ?? 'https://via.placeholder.com/150';
    final name = business.name;
    final isPremium = business.isVerified;
    final trustScore = business.profileCompletionPercentage;
    final products = business.productsCount;
    final revenue = '\$${(business.followersCount * 12.5).toStringAsFixed(0)}/mo';
    final views = '${(business.reviewsCount * 50 / 1000).toStringAsFixed(1)}K';
    final engagement = '${(business.rating * 1.5).toStringAsFixed(1)}%';
    final growth = '+24%';

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MotionPageRoute(
            page: BusinessDetailScreen(
              business: business,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.dividerColor,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: TextStyle(
                                color: context.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isPremium
                                  ? const Color(0xFF10B981).withValues(alpha: 0.15)
                                  : context.onSurface.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPremium ? 'premium' : 'free',
                              style: TextStyle(
                                color: isPremium
                                    ? const Color(0xFF10B981)
                                    : context.onSurface.withValues(alpha: 0.5),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981),
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 8,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$trustScore% Trust',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '  •  $products products  •  $revenue',
                              style: TextStyle(
                                color: context.hintColor,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _StatItem(label: 'Views', value: views),
                _StatItem(label: 'Engagement', value: engagement),
                _StatItem(label: 'Growth', value: growth, isPositive: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isPositive;

  const _StatItem({
    required this.label,
    required this.value,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.hintColor,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: isPositive ? const Color(0xFF10B981) : context.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddBusinessButton extends StatelessWidget {
  const _AddBusinessButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: context.dividerColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/create-business'),
          borderRadius: BorderRadius.circular(26),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  size: 20,
                  color: context.onSurface.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  'Add New Business',
                  style: TextStyle(
                    color: context.onSurface.withValues(alpha: 0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
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
