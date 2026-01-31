import 'package:flutter/material.dart';
import '../models/trust_score.dart';

class TrustBadge extends StatelessWidget {
  final int score;
  final bool showScore;
  final bool compact;

  const TrustBadge({
    super.key,
    required this.score,
    this.showScore = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final trust = TrustScore(score);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: trust.backgroundColor,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              trust.icon,
              size: 12,
              color: trust.primaryColor,
            ),
            if (showScore) ...[
              const SizedBox(width: 4),
              Text(
                '$score%',
                style: TextStyle(
                  color: trust.primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: trust.backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: trust.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: trust.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              trust.icon,
              size: 14,
              color: trust.primaryColor,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                trust.levelName,
                style: TextStyle(
                  color: trust.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (showScore)
                Text(
                  'Trust Score: $score',
                  style: TextStyle(
                    color: trust.primaryColor.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class TrustLevelCard extends StatelessWidget {
  final TrustLevel level;
  final bool isSelected;

  const TrustLevelCard({
    super.key,
    required this.level,
    this.isSelected = false,
  });

  TrustScore get _trust {
    switch (level) {
      case TrustLevel.newMember:
        return const TrustScore(20);
      case TrustLevel.trusted:
        return const TrustScore(50);
      case TrustLevel.verified:
        return const TrustScore(80);
      case TrustLevel.elite:
        return const TrustScore(95);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trust = _trust;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? trust.primaryColor
              : Colors.white.withValues(alpha: 0.08),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: trust.backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              trust.icon,
              size: 22,
              color: trust.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            trust.levelName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trust.scoreRange,
            style: TextStyle(
              color: trust.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          ...trust.benefits.map((benefit) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.check,
                      size: 14,
                      color: trust.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        benefit,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class SearchResultCard extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final int trustScore;
  final double rating;
  final int reviewCount;
  final bool isVerified;

  const SearchResultCard({
    super.key,
    required this.name,
    this.imageUrl,
    required this.trustScore,
    required this.rating,
    required this.reviewCount,
    this.isVerified = false,
  });

  @override
  Widget build(BuildContext context) {
    final trust = TrustScore(trustScore);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141418),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: trust.isTopRanked
              ? trust.primaryColor.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                trust.isTopRanked ? Icons.emoji_events_outlined : Icons.person_outline,
                size: 14,
                color: trust.primaryColor,
              ),
              const SizedBox(width: 6),
              Text(
                trust.isTopRanked ? 'Top Ranked' : 'Lower Ranked',
                style: TextStyle(
                  color: trust.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(Trust Score: $trustScore)',
                style: TextStyle(
                  color: trust.primaryColor.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(12),
                  image: imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: imageUrl == null
                    ? Icon(
                        Icons.person,
                        color: Colors.white.withValues(alpha: 0.5),
                      )
                    : null,
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isVerified || trust.level == TrustLevel.verified || trust.level == TrustLevel.elite) ...[
                          const SizedBox(width: 6),
                          Icon(
                            Icons.verified,
                            size: 16,
                            color: trust.primaryColor,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          final filled = index < rating.floor();
                          final half = index == rating.floor() && rating % 1 >= 0.5;
                          return Icon(
                            filled
                                ? Icons.star
                                : half
                                    ? Icons.star_half
                                    : Icons.star_border,
                            size: 14,
                            color: const Color(0xFFFBBF24),
                          );
                        }),
                        const SizedBox(width: 6),
                        Text(
                          '($reviewCount reviews)',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            trust.searchPlacementDescription,
            style: TextStyle(
              color: trust.primaryColor.withValues(alpha: 0.8),
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class TrustLevelsGrid extends StatelessWidget {
  const TrustLevelsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trust Levels & Benefits',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
          children: const [
            TrustLevelCard(level: TrustLevel.newMember),
            TrustLevelCard(level: TrustLevel.trusted),
            TrustLevelCard(level: TrustLevel.verified),
            TrustLevelCard(level: TrustLevel.elite),
          ],
        ),
      ],
    );
  }
}

class SearchResultsRanking extends StatelessWidget {
  const SearchResultsRanking({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search Results Ranking',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: SearchResultCard(
                name: 'Premium Seller',
                trustScore: 95,
                rating: 4.5,
                reviewCount: 547,
                isVerified: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SearchResultCard(
                name: 'New Seller',
                trustScore: 42,
                rating: 3.0,
                reviewCount: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
