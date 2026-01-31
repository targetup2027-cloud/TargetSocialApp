import 'package:flutter/material.dart';

enum TrustLevel {
  newMember,
  trusted,
  verified,
  elite,
}

class TrustScore {
  final int score;

  const TrustScore(this.score);

  TrustLevel get level {
    if (score >= 90) return TrustLevel.elite;
    if (score >= 70) return TrustLevel.verified;
    if (score >= 40) return TrustLevel.trusted;
    return TrustLevel.newMember;
  }

  String get levelName {
    switch (level) {
      case TrustLevel.newMember:
        return 'New Member';
      case TrustLevel.trusted:
        return 'Trusted';
      case TrustLevel.verified:
        return 'Verified';
      case TrustLevel.elite:
        return 'Elite';
    }
  }

  String get scoreRange {
    switch (level) {
      case TrustLevel.newMember:
        return 'Score: 0-39';
      case TrustLevel.trusted:
        return 'Score: 40-69';
      case TrustLevel.verified:
        return 'Score: 70-89';
      case TrustLevel.elite:
        return 'Score: 90-100';
    }
  }

  List<String> get benefits {
    switch (level) {
      case TrustLevel.newMember:
        return [
          'Basic listing',
          'Standard support',
          'Limited visibility',
        ];
      case TrustLevel.trusted:
        return [
          'Enhanced listing',
          'Priority in search',
          'Trust badge',
        ];
      case TrustLevel.verified:
        return [
          'Featured placement',
          'Advanced analytics',
          'Verification mark',
        ];
      case TrustLevel.elite:
        return [
          'Top placement',
          'Dedicated support',
          'Elite badge',
        ];
    }
  }

  String get searchPlacementDescription {
    switch (level) {
      case TrustLevel.newMember:
        return 'Standard listing, appears lower in results, building trust';
      case TrustLevel.trusted:
        return 'Enhanced visibility, appears in priority search results';
      case TrustLevel.verified:
        return 'Featured placement, high visibility in search results';
      case TrustLevel.elite:
        return 'Appears first in search, featured placement, maximum visibility';
    }
  }

  Color get primaryColor {
    switch (level) {
      case TrustLevel.newMember:
        return const Color(0xFF10B981);
      case TrustLevel.trusted:
        return const Color(0xFF6B7280);
      case TrustLevel.verified:
        return const Color(0xFFFBBF24);
      case TrustLevel.elite:
        return const Color(0xFFF59E0B);
    }
  }

  Color get backgroundColor {
    switch (level) {
      case TrustLevel.newMember:
        return const Color(0xFF10B981).withValues(alpha: 0.15);
      case TrustLevel.trusted:
        return const Color(0xFF374151);
      case TrustLevel.verified:
        return const Color(0xFFFBBF24).withValues(alpha: 0.15);
      case TrustLevel.elite:
        return const Color(0xFFF59E0B).withValues(alpha: 0.15);
    }
  }

  IconData get icon {
    switch (level) {
      case TrustLevel.newMember:
        return Icons.eco_outlined;
      case TrustLevel.trusted:
        return Icons.check;
      case TrustLevel.verified:
        return Icons.star;
      case TrustLevel.elite:
        return Icons.workspace_premium;
    }
  }

  bool get isTopRanked => score >= 70;
}
