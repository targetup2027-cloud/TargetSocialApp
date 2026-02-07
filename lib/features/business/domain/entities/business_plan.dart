enum BusinessPlanType {
  free,
  starter,
  premium,
  enterprise,
}

class BusinessPlan {
  final BusinessPlanType type;
  final String name;
  final String price;
  final String billingCycle;
  final int maxVideos;
  final int maxImages;
  final int maxDurationMinutes;
  final List<String> features;
  final bool isPopular;

  const BusinessPlan({
    required this.type,
    required this.name,
    required this.price,
    required this.billingCycle,
    required this.maxVideos,
    required this.maxImages,
    required this.maxDurationMinutes,
    required this.features,
    this.isPopular = false,
  });

  static const free = BusinessPlan(
    type: BusinessPlanType.free,
    name: 'Free',
    price: '\$0',
    billingCycle: 'forever',
    maxVideos: 2,
    maxImages: 5,
    maxDurationMinutes: 1,
    features: [
      '2 promotional videos',
      '5 product images',
      '1 min max video duration',
      'Basic analytics',
      'Standard support',
    ],
  );

  static const starter = BusinessPlan(
    type: BusinessPlanType.starter,
    name: 'Starter',
    price: '\$9.99',
    billingCycle: 'month',
    maxVideos: 5,
    maxImages: 15,
    maxDurationMinutes: 3,
    features: [
      '5 promotional videos',
      '15 product images',
      '3 min max video duration',
      'Enhanced analytics',
      'Priority support',
      'Trust badge boost',
    ],
    isPopular: true,
  );

  static const premium = BusinessPlan(
    type: BusinessPlanType.premium,
    name: 'Premium',
    price: '\$29.99',
    billingCycle: 'month',
    maxVideos: 15,
    maxImages: 50,
    maxDurationMinutes: 10,
    features: [
      '15 promotional videos',
      '50 product images',
      '10 min max video duration',
      'Advanced analytics',
      'Priority support',
      'Featured placement',
      'Custom branding',
    ],
  );

  static const enterprise = BusinessPlan(
    type: BusinessPlanType.enterprise,
    name: 'Enterprise',
    price: '\$99.99',
    billingCycle: 'month',
    maxVideos: -1,
    maxImages: -1,
    maxDurationMinutes: 60,
    features: [
      'Unlimited videos',
      'Unlimited images',
      '60 min max video duration',
      'Full analytics suite',
      'Dedicated support',
      'Top placement',
      'Custom branding',
      'API access',
    ],
  );

  static const List<BusinessPlan> allPlans = [free, starter, premium, enterprise];

  String get mediaLimitText {
    if (maxVideos == -1 && maxImages == -1) {
      return 'Unlimited';
    }
    return '$maxVideos videos + $maxImages images';
  }
}
