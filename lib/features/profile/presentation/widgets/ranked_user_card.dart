import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/theme_extensions.dart';
import '../../domain/entities/user_profile.dart';

class RankedUserCard extends StatelessWidget {
  final UserProfile user;
  final int reviewCount;
  final double rating;
  final bool isTopRanked;
  final VoidCallback? onTap;

  const RankedUserCard({
    super.key,
    required this.user,
    this.reviewCount = 0,
    this.rating = 0.0,
    this.isTopRanked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final trustScore = user.profileCompletionPercentage;
    final isHighTrust = trustScore >= 70;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isTopRanked 
              ? const Color(0xFF0D2818)
              : context.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isTopRanked 
                ? const Color(0xFF10B981)
                : context.dividerColor,
            width: isTopRanked ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isTopRanked) ...[
                  const Icon(
                    Icons.emoji_events_outlined,
                    color: Color(0xFF10B981),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  isTopRanked 
                      ? 'Top Ranked (Trust Score: $trustScore)'
                      : 'Lower Ranked (Trust Score: $trustScore)',
                  style: TextStyle(
                    color: isTopRanked 
                        ? const Color(0xFF10B981)
                        : context.hintColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.dividerColor,
                    image: user.avatarUrl != null
                        ? DecorationImage(
                            image: NetworkImage(user.avatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: user.avatarUrl == null
                      ? Icon(Icons.person, color: context.hintColor)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isHighTrust ? 'Premium Seller' : user.displayName,
                            style: TextStyle(
                              color: context.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (user.isVerified || isHighTrust) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF10B981),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            return Icon(
                              index < rating.floor() 
                                  ? Icons.star 
                                  : Icons.star_border,
                              color: const Color(0xFFF59E0B),
                              size: 14,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '($reviewCount reviews)',
                            style: TextStyle(
                              color: const Color(0xFF3B82F6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isTopRanked
                  ? 'Appears first in search, featured placement, maximum visibility'
                  : 'Standard listing, appears lower in results, building trust',
              style: TextStyle(
                color: context.hintColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResultsRanking extends StatelessWidget {
  final List<UserProfile> users;

  const SearchResultsRanking({
    super.key,
    required this.users,
  });

  @override
  Widget build(BuildContext context) {
    final sortedUsers = List<UserProfile>.from(users)
      ..sort((a, b) => b.profileCompletionPercentage.compareTo(a.profileCompletionPercentage));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Search Results Ranking',
            style: TextStyle(
              color: context.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: sortedUsers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = sortedUsers[index];
            final isTop = user.profileCompletionPercentage >= 70;
            return RankedUserCard(
              user: user,
              isTopRanked: isTop,
              rating: isTop ? 5.0 : 3.0,
              reviewCount: isTop ? 547 : 12,
              onTap: () => context.push('/user/${user.id}'),
            );
          },
        ),
      ],
    );
  }
}

class TrustScoreExplanation extends StatelessWidget {
  const TrustScoreExplanation({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'كيف يعمل نظام الترتيب؟',
            style: TextStyle(
              color: context.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _buildExplanationRow(
            context,
            icon: Icons.verified,
            color: const Color(0xFF10B981),
            title: 'الحسابات الموثقة (70+ نقطة)',
            description: 'تظهر أولاً في نتائج البحث مع placement مميز',
          ),
          const SizedBox(height: 12),
          _buildExplanationRow(
            context,
            icon: Icons.star,
            color: const Color(0xFFF59E0B),
            title: 'التقييمات والمراجعات',
            description: 'تؤثر على ترتيب الحساب في نتائج البحث',
          ),
          const SizedBox(height: 12),
          _buildExplanationRow(
            context,
            icon: Icons.badge,
            color: const Color(0xFF3B82F6),
            title: 'إثبات الهوية',
            description: 'الرقم القومي يرفع Trust Score بـ 15+ نقطة',
          ),
          const SizedBox(height: 12),
          _buildExplanationRow(
            context,
            icon: Icons.trending_up,
            color: const Color(0xFF8B5CF6),
            title: 'النشاط المستمر',
            description: 'التفاعل والنشر يحسن من ترتيبك',
          ),
        ],
      ),
    );
  }

  Widget _buildExplanationRow(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: context.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  color: context.hintColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
