class Nullable<T> {
  final T? value;
  const Nullable(this.value);
}

class Business {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? coverImageUrl;
  final String? videoUrl;
  final String? horizontalVideoUrl;
  final List<String> galleryImageUrls;
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
  final String? commercialRegistration;
  final String? taxNumber;
  final int? foundingYear;

  const Business({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    this.logoUrl,
    this.coverImageUrl,
    this.videoUrl,
    this.horizontalVideoUrl,
    this.galleryImageUrls = const [],
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
    this.commercialRegistration,
    this.taxNumber,
    this.foundingYear,
  });

  Business copyWith({
    String? id,
    String? ownerId,
    String? name,
    Nullable<String>? description,
    Nullable<String>? logoUrl,
    Nullable<String>? coverImageUrl,
    Nullable<String>? videoUrl,
    Nullable<String>? horizontalVideoUrl,
    List<String>? galleryImageUrls,
    Nullable<String>? website,
    Nullable<String>? email,
    Nullable<String>? phone,
    Nullable<BusinessAddress>? address,
    BusinessCategory? category,
    List<String>? subcategories,
    Nullable<BusinessHours>? hours,
    bool? isVerified,
    bool? isActive,
    double? rating,
    int? reviewsCount,
    int? followersCount,
    int? productsCount,
    DateTime? createdAt,
    Nullable<Map<String, String>>? socialLinks,
    Nullable<String>? commercialRegistration,
    Nullable<String>? taxNumber,
    Nullable<int>? foundingYear,
  }) {
    return Business(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      description: description != null ? description.value : this.description,
      logoUrl: logoUrl != null ? logoUrl.value : this.logoUrl,
      coverImageUrl: coverImageUrl != null ? coverImageUrl.value : this.coverImageUrl,
      videoUrl: videoUrl != null ? videoUrl.value : this.videoUrl,
      horizontalVideoUrl: horizontalVideoUrl != null ? horizontalVideoUrl.value : this.horizontalVideoUrl,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      website: website != null ? website.value : this.website,
      email: email != null ? email.value : this.email,
      phone: phone != null ? phone.value : this.phone,
      address: address != null ? address.value : this.address,
      category: category ?? this.category,
      subcategories: subcategories ?? this.subcategories,
      hours: hours != null ? hours.value : this.hours,
      isVerified: isVerified ?? this.isVerified,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      followersCount: followersCount ?? this.followersCount,
      productsCount: productsCount ?? this.productsCount,
      createdAt: createdAt ?? this.createdAt,
      socialLinks: socialLinks != null ? socialLinks.value : this.socialLinks,
      commercialRegistration: commercialRegistration != null ? commercialRegistration.value : this.commercialRegistration,
      taxNumber: taxNumber != null ? taxNumber.value : this.taxNumber,
      foundingYear: foundingYear != null ? foundingYear.value : this.foundingYear,
    );
  }

  int get profileCompletionPercentage {
    int score = 0;
    const int totalFields = 15;

    if (name.isNotEmpty) score++;
    if (description != null && description!.isNotEmpty) score++;
    if (logoUrl != null && logoUrl!.isNotEmpty) score++;
    if (coverImageUrl != null && coverImageUrl!.isNotEmpty) score++;
    if (email != null && email!.isNotEmpty) score++;
    if (phone != null && phone!.isNotEmpty) score++;
    if (website != null && website!.isNotEmpty) score++;
    if (address != null && address!.formattedAddress.isNotEmpty) score++;
    if (hours != null) score++;
    if (subcategories.isNotEmpty) score++;
    if (socialLinks != null && socialLinks!.isNotEmpty) score++;
    if (productsCount > 0) score++;
    if (commercialRegistration != null && commercialRegistration!.isNotEmpty) score++;
    if (taxNumber != null && taxNumber!.isNotEmpty) score++;
    if (foundingYear != null) score++;

    return ((score / totalFields) * 100).round();
  }

  String get completionLevel {
    final percentage = profileCompletionPercentage;
    if (percentage >= 90) return 'Excellent';
    if (percentage >= 70) return 'Good';
    if (percentage >= 50) return 'Fair';
    if (percentage >= 30) return 'Basic';
    return 'Incomplete';
  }

  List<String> get missingFields {
    final missing = <String>[];
    if (description == null || description!.isEmpty) missing.add('Description');
    if (logoUrl == null || logoUrl!.isEmpty) missing.add('Logo');
    if (coverImageUrl == null || coverImageUrl!.isEmpty) missing.add('Cover Image');
    if (email == null || email!.isEmpty) missing.add('Email');
    if (phone == null || phone!.isEmpty) missing.add('Phone');
    if (website == null || website!.isEmpty) missing.add('Website');
    if (address == null || address!.formattedAddress.isEmpty) missing.add('Address');
    if (hours == null) missing.add('Business Hours');
    if (subcategories.isEmpty) missing.add('Subcategories');
    if (socialLinks == null || socialLinks!.isEmpty) missing.add('Social Links');
    if (productsCount == 0) missing.add('Products');
    if (commercialRegistration == null || commercialRegistration!.isEmpty) missing.add('Commercial Registration');
    if (taxNumber == null || taxNumber!.isEmpty) missing.add('Tax Number');
    if (foundingYear == null) missing.add('Founding Year');
    return missing;
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
