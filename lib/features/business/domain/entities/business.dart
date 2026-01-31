class Business {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? website;
  final String? email;
  final String? phone;
  final BusinessAddress? address;
  final BusinessCategory category;
  final List<String> subcategories;
  final BusinessHours? hours;
  final bool isVerified;
  final bool isActive;
  final double rating;
  final int reviewsCount;
  final int followersCount;
  final int productsCount;
  final DateTime createdAt;
  final Map<String, String>? socialLinks;

  const Business({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.website,
    this.email,
    this.phone,
    this.address,
    required this.category,
    this.subcategories = const [],
    this.hours,
    this.isVerified = false,
    this.isActive = true,
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.followersCount = 0,
    this.productsCount = 0,
    required this.createdAt,
    this.socialLinks,
  });

  Business copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? description,
    String? logoUrl,
    String? coverImageUrl,
    String? website,
    String? email,
    String? phone,
    BusinessAddress? address,
    BusinessCategory? category,
    List<String>? subcategories,
    BusinessHours? hours,
    bool? isVerified,
    bool? isActive,
    double? rating,
    int? reviewsCount,
    int? followersCount,
    int? productsCount,
    DateTime? createdAt,
    Map<String, String>? socialLinks,
  }) {
    return Business(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      website: website ?? this.website,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      category: category ?? this.category,
      subcategories: subcategories ?? this.subcategories,
      hours: hours ?? this.hours,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      followersCount: followersCount ?? this.followersCount,
      productsCount: productsCount ?? this.productsCount,
      createdAt: createdAt ?? this.createdAt,
      socialLinks: socialLinks ?? this.socialLinks,
    );
  }
}

class BusinessAddress {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final double? latitude;
  final double? longitude;

  const BusinessAddress({
    this.street,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.latitude,
    this.longitude,
  });

  String get formattedAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) parts.add(street!);
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (state != null && state!.isNotEmpty) parts.add(state!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.join(', ');
  }
}

enum BusinessCategory {
  retail,
  food,
  services,
  technology,
  health,
  education,
  entertainment,
  other,
}

class BusinessHours {
  final Map<String, DayHours> schedule;

  const BusinessHours({required this.schedule});

  bool get isOpenNow {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final dayHours = schedule[dayName];
    if (dayHours == null || dayHours.isClosed) return false;

    final currentMinutes = now.hour * 60 + now.minute;
    return currentMinutes >= dayHours.openMinutes && currentMinutes <= dayHours.closeMinutes;
  }

  String _getDayName(int weekday) {
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    return days[weekday - 1];
  }
}

class DayHours {
  final bool isClosed;
  final int openMinutes;
  final int closeMinutes;

  const DayHours({
    this.isClosed = false,
    this.openMinutes = 540,
    this.closeMinutes = 1080,
  });

  String get openTime => _formatTime(openMinutes);
  String get closeTime => _formatTime(closeMinutes);

  String _formatTime(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    final period = hours >= 12 ? 'PM' : 'AM';
    final displayHours = hours > 12 ? hours - 12 : (hours == 0 ? 12 : hours);
    return '$displayHours:${mins.toString().padLeft(2, '0')} $period';
  }
}

class BusinessReview {
  final String id;
  final String businessId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatarUrl;
  final int rating;
  final String? content;
  final List<String> photoUrls;
  final DateTime createdAt;
  final String? ownerReply;
  final DateTime? ownerReplyAt;
  final int helpfulCount;
  final bool isHelpful;

  const BusinessReview({
    required this.id,
    required this.businessId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatarUrl,
    required this.rating,
    this.content,
    this.photoUrls = const [],
    required this.createdAt,
    this.ownerReply,
    this.ownerReplyAt,
    this.helpfulCount = 0,
    this.isHelpful = false,
  });
}
