import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../entities/business.dart';

abstract class BusinessRepository {
  Future<List<Business>> getMyBusinesses();
  Future<Business> getMyBusiness();
  
  Future<Business?> getBusinessById(String businessId);
  
  Future<List<Business>> getBusinesses({
    int page = 1,
    int limit = 20,
    BusinessCategory? category,
    String? query,
    double? latitude,
    double? longitude,
    double? radiusKm,
  });
  
  Future<Business> createBusiness({
    required String name,
    String? description,
    required BusinessCategory category,
    List<String>? subcategories,
    String? email,
    String? phone,
    String? website,
    String? address,
    String? commercialRegistration,
    String? taxNumber,
    int? foundingYear,
    Uint8List? logoBytes,
    Uint8List? coverBytes,
    List<XFile>? imageFiles,
    XFile? verticalVideo,
    XFile? horizontalVideo,
  });
  
  Future<Business> updateBusiness(String businessId, {
    String? name,
    Nullable<String>? description,
    Nullable<String>? website,
    Nullable<String>? email,
    Nullable<String>? phone,
    Nullable<BusinessAddress>? address,
    BusinessCategory? category,
    List<String>? subcategories,
    Nullable<BusinessHours>? hours,
    Nullable<Map<String, String>>? socialLinks,
    Nullable<String>? commercialRegistration,
    Nullable<String>? taxNumber,
    Nullable<int>? foundingYear,
    Uint8List? logoBytes,
    Uint8List? coverBytes,
    List<XFile>? imageFiles,
    XFile? verticalVideo,
    XFile? horizontalVideo,
  });
  
  Future<String> updateBusinessLogo(String businessId, String imagePath);
  
  Future<String> updateBusinessCover(String businessId, String imagePath);
  
  Future<void> deleteBusiness(String businessId);
  
  Future<Business> followBusiness(String businessId);
  
  Future<Business> unfollowBusiness(String businessId);
  
  Future<List<Business>> getFollowedBusinesses({int page = 1, int limit = 20});
  
  Future<List<BusinessReview>> getBusinessReviews(String businessId, {int page = 1, int limit = 20});
  
  Future<BusinessReview> addReview(String businessId, {
    required int rating,
    String? content,
    List<String>? photoUrls,
  });
  
  Future<void> deleteReview(String businessId, String reviewId);
  
  Future<BusinessReview> replyToReview(String businessId, String reviewId, String reply);
  
  Future<void> markReviewHelpful(String reviewId);
  
  Future<void> unmarkReviewHelpful(String reviewId);
  
  Future<Map<String, dynamic>> getBusinessAnalytics(String businessId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}
