import '../../domain/entities/business.dart';
import '../../domain/repositories/business_repository.dart';

class BusinessRepositoryImpl implements BusinessRepository {
  final bool useMockData;

  BusinessRepositoryImpl({this.useMockData = true});

  @override
  Future<Business> getMyBusiness() async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      return _getMockMyBusiness();
    }
    throw UnimplementedError();
  }

  @override
  Future<Business?> getBusinessById(String businessId) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _getMockBusinesses().firstWhere(
        (b) => b.id == businessId,
        orElse: () => _getMockMyBusiness(),
      );
    }
    throw UnimplementedError();
  }

  @override
  Future<List<Business>> getBusinesses({
    int page = 1,
    int limit = 20,
    BusinessCategory? category,
    String? query,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 300));
      var businesses = _getMockBusinesses();
      
      if (category != null) {
        businesses = businesses.where((b) => b.category == category).toList();
      }
      
      if (query != null && query.isNotEmpty) {
        businesses = businesses.where((b) =>
          b.name.toLowerCase().contains(query.toLowerCase()) ||
          (b.description?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
      }
      
      return businesses;
    }
    throw UnimplementedError();
  }

  @override
  Future<Business> createBusiness({
    required String name,
    String? description,
    required BusinessCategory category,
    List<String>? subcategories,
  }) async {
    if (useMockData) {
      return Business(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        ownerId: 'currentUser',
        name: name,
        description: description,
        category: category,
        subcategories: subcategories ?? [],
        createdAt: DateTime.now(),
      );
    }
    throw UnimplementedError();
  }

  @override
  Future<Business> updateBusiness(String businessId, {
    String? name,
    String? description,
    String? website,
    String? email,
    String? phone,
    BusinessAddress? address,
    BusinessCategory? category,
    List<String>? subcategories,
    BusinessHours? hours,
    Map<String, String>? socialLinks,
  }) async {
    if (useMockData) {
      final business = await getBusinessById(businessId);
      return business!.copyWith(
        name: name,
        description: description,
        website: website,
        email: email,
        phone: phone,
        address: address,
        category: category,
        subcategories: subcategories,
        hours: hours,
        socialLinks: socialLinks,
      );
    }
    throw UnimplementedError();
  }

  @override
  Future<String> updateBusinessLogo(String businessId, String imagePath) async {
    if (useMockData) {
      return 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=200';
    }
    throw UnimplementedError();
  }

  @override
  Future<String> updateBusinessCover(String businessId, String imagePath) async {
    if (useMockData) {
      return 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800';
    }
    throw UnimplementedError();
  }

  @override
  Future<void> deleteBusiness(String businessId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<Business> followBusiness(String businessId) async {
    if (useMockData) {
      final business = await getBusinessById(businessId);
      return business!.copyWith(followersCount: business.followersCount + 1);
    }
    throw UnimplementedError();
  }

  @override
  Future<Business> unfollowBusiness(String businessId) async {
    if (useMockData) {
      final business = await getBusinessById(businessId);
      return business!.copyWith(followersCount: business.followersCount - 1);
    }
    throw UnimplementedError();
  }

  @override
  Future<List<Business>> getFollowedBusinesses({int page = 1, int limit = 20}) async {
    if (useMockData) {
      return _getMockBusinesses().take(3).toList();
    }
    throw UnimplementedError();
  }

  @override
  Future<List<BusinessReview>> getBusinessReviews(String businessId, {int page = 1, int limit = 20}) async {
    if (useMockData) {
      return _getMockReviews(businessId);
    }
    throw UnimplementedError();
  }

  @override
  Future<BusinessReview> addReview(String businessId, {
    required int rating,
    String? content,
    List<String>? photoUrls,
  }) async {
    if (useMockData) {
      return BusinessReview(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        businessId: businessId,
        reviewerId: 'currentUser',
        reviewerName: 'You',
        rating: rating,
        content: content,
        photoUrls: photoUrls ?? [],
        createdAt: DateTime.now(),
      );
    }
    throw UnimplementedError();
  }

  @override
  Future<void> deleteReview(String businessId, String reviewId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<BusinessReview> replyToReview(String businessId, String reviewId, String reply) async {
    throw UnimplementedError();
  }

  @override
  Future<void> markReviewHelpful(String reviewId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<void> unmarkReviewHelpful(String reviewId) async {
    if (useMockData) return;
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getBusinessAnalytics(String businessId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (useMockData) {
      return {
        'views': 1250,
        'uniqueVisitors': 890,
        'followers': 234,
        'orders': 45,
        'revenue': 12500.00,
        'topProducts': [
          {'name': 'Product A', 'sales': 25},
          {'name': 'Product B', 'sales': 15},
          {'name': 'Product C', 'sales': 5},
        ],
        'dailyViews': [120, 150, 180, 200, 170, 190, 240],
      };
    }
    throw UnimplementedError();
  }

  Business _getMockMyBusiness() {
    return Business(
      id: 'myBusiness',
      ownerId: 'currentUser',
      name: 'My Tech Store',
      description: 'Premium electronics and gadgets for tech enthusiasts. We offer the latest technology products at competitive prices.',
      logoUrl: 'https://images.unsplash.com/photo-1560179707-f14e90ef3623?w=200',
      coverImageUrl: 'https://images.unsplash.com/photo-1497366216548-37526070297c?w=800',
      website: 'https://mytechstore.com',
      email: 'contact@mytechstore.com',
      phone: '+1 (555) 123-4567',
      address: const BusinessAddress(
        street: '123 Tech Street',
        city: 'San Francisco',
        state: 'CA',
        country: 'USA',
        postalCode: '94105',
        latitude: 37.7749,
        longitude: -122.4194,
      ),
      category: BusinessCategory.technology,
      subcategories: ['Electronics', 'Gadgets', 'Accessories'],
      isVerified: true,
      rating: 4.8,
      reviewsCount: 156,
      followersCount: 2340,
      productsCount: 45,
      createdAt: DateTime(2023, 1, 15),
      socialLinks: {
        'twitter': 'mytechstore',
        'instagram': 'mytechstore',
        'facebook': 'mytechstore',
      },
    );
  }

  List<Business> _getMockBusinesses() {
    return [
      Business(
        id: 'biz1',
        ownerId: 'user1',
        name: 'Urban Coffee House',
        description: 'Artisan coffee and pastries in a cozy atmosphere',
        logoUrl: 'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?w=200',
        category: BusinessCategory.food,
        subcategories: ['Coffee', 'Bakery'],
        isVerified: true,
        rating: 4.6,
        reviewsCount: 234,
        followersCount: 1560,
        createdAt: DateTime(2022, 6, 10),
        address: const BusinessAddress(
          city: 'New York',
          state: 'NY',
          country: 'USA',
        ),
      ),
      Business(
        id: 'biz2',
        ownerId: 'user2',
        name: 'Fitness First Gym',
        description: 'State-of-the-art fitness center with personal training',
        logoUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=200',
        category: BusinessCategory.health,
        subcategories: ['Fitness', 'Personal Training'],
        rating: 4.5,
        reviewsCount: 89,
        followersCount: 890,
        createdAt: DateTime(2021, 3, 20),
        address: const BusinessAddress(
          city: 'Los Angeles',
          state: 'CA',
          country: 'USA',
        ),
      ),
      Business(
        id: 'biz3',
        ownerId: 'user3',
        name: 'Fashion Forward',
        description: 'Trendy clothing and accessories for all styles',
        logoUrl: 'https://images.unsplash.com/photo-1441984904996-e0b6ba687e04?w=200',
        category: BusinessCategory.retail,
        subcategories: ['Fashion', 'Clothing', 'Accessories'],
        isVerified: true,
        rating: 4.7,
        reviewsCount: 312,
        followersCount: 4500,
        productsCount: 120,
        createdAt: DateTime(2020, 11, 5),
        address: const BusinessAddress(
          city: 'Miami',
          state: 'FL',
          country: 'USA',
        ),
      ),
    ];
  }

  List<BusinessReview> _getMockReviews(String businessId) {
    return [
      BusinessReview(
        id: 'rev1',
        businessId: businessId,
        reviewerId: 'user4',
        reviewerName: 'Emily Davis',
        reviewerAvatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
        rating: 5,
        content: 'Excellent service and amazing products! Will definitely come back.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        helpfulCount: 12,
      ),
      BusinessReview(
        id: 'rev2',
        businessId: businessId,
        reviewerId: 'user5',
        reviewerName: 'Mike Chen',
        reviewerAvatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150',
        rating: 4,
        content: 'Great products, but delivery was a bit slow. Overall happy with my purchase.',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        helpfulCount: 8,
        ownerReply: 'Thank you for your feedback! We are working on improving our delivery times.',
        ownerReplyAt: DateTime.now().subtract(const Duration(days: 4)),
      ),
      BusinessReview(
        id: 'rev3',
        businessId: businessId,
        reviewerId: 'user6',
        reviewerName: 'Sarah Wilson',
        rating: 5,
        content: 'Best tech store in town! The staff is super helpful and knowledgeable.',
        photoUrls: [
          'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400',
        ],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        helpfulCount: 25,
      ),
    ];
  }
}
