import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/business.dart';
import '../domain/repositories/business_repository.dart';
import '../data/repositories/business_repository_impl.dart';

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl(useMockData: true);
});

final myBusinessProvider = FutureProvider<Business>((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getMyBusiness();
});

final businessByIdProvider = FutureProvider.family<Business?, String>((ref, id) async {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinessById(id);
});

final businessesProvider = FutureProvider.family<List<Business>, BusinessSearchParams>((ref, params) async {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinesses(
    page: params.page,
    category: params.category,
    query: params.query,
  );
});

final businessReviewsProvider = FutureProvider.family<List<BusinessReview>, String>((ref, businessId) async {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinessReviews(businessId);
});

final followedBusinessesProvider = FutureProvider<List<Business>>((ref) async {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getFollowedBusinesses();
});

final businessAnalyticsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, businessId) async {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.getBusinessAnalytics(businessId);
});

class BusinessSearchParams {
  final int page;
  final BusinessCategory? category;
  final String? query;

  const BusinessSearchParams({
    this.page = 1,
    this.category,
    this.query,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessSearchParams &&
          page == other.page &&
          category == other.category &&
          query == other.query;

  @override
  int get hashCode => Object.hash(page, category, query);
}

class MyBusinessController extends StateNotifier<AsyncValue<Business>> {
  final BusinessRepository _repository;

  MyBusinessController(this._repository) : super(const AsyncValue.loading()) {
    loadBusiness();
  }

  Future<void> loadBusiness() async {
    state = const AsyncValue.loading();
    try {
      final business = await _repository.getMyBusiness();
      state = AsyncValue.data(business);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateBusiness({
    String? name,
    String? description,
    String? website,
    String? email,
    String? phone,
  }) async {
    final currentBusiness = state.valueOrNull;
    if (currentBusiness == null) return;

    try {
      final updatedBusiness = await _repository.updateBusiness(
        currentBusiness.id,
        name: name,
        description: description,
        website: website,
        email: email,
        phone: phone,
      );
      state = AsyncValue.data(updatedBusiness);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateLogo(String imagePath) async {
    final currentBusiness = state.valueOrNull;
    if (currentBusiness == null) return;

    try {
      final newLogoUrl = await _repository.updateBusinessLogo(currentBusiness.id, imagePath);
      state = AsyncValue.data(currentBusiness.copyWith(logoUrl: newLogoUrl));
    } catch (e) {
      
    }
  }

  Future<void> updateCover(String imagePath) async {
    final currentBusiness = state.valueOrNull;
    if (currentBusiness == null) return;

    try {
      final newCoverUrl = await _repository.updateBusinessCover(currentBusiness.id, imagePath);
      state = AsyncValue.data(currentBusiness.copyWith(coverImageUrl: newCoverUrl));
    } catch (e) {
      
    }
  }
}

final myBusinessControllerProvider = StateNotifierProvider<MyBusinessController, AsyncValue<Business>>((ref) {
  final repository = ref.watch(businessRepositoryProvider);
  return MyBusinessController(repository);
});

class BusinessProfileController extends StateNotifier<AsyncValue<Business>> {
  final BusinessRepository _repository;
  final String businessId;

  BusinessProfileController(this._repository, this.businessId) : super(const AsyncValue.loading()) {
    loadBusiness();
  }

  Future<void> loadBusiness() async {
    state = const AsyncValue.loading();
    try {
      final business = await _repository.getBusinessById(businessId);
      if (business != null) {
        state = AsyncValue.data(business);
      } else {
        state = AsyncValue.error('Business not found', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFollow() async {
    final currentBusiness = state.valueOrNull;
    if (currentBusiness == null) return;

    try {
      final updatedBusiness = await _repository.followBusiness(businessId);
      state = AsyncValue.data(updatedBusiness);
    } catch (e) {
      
    }
  }
}

final businessProfileControllerProvider = StateNotifierProvider.family<BusinessProfileController, AsyncValue<Business>, String>((ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return BusinessProfileController(repository, businessId);
});

class BusinessReviewsController extends StateNotifier<AsyncValue<List<BusinessReview>>> {
  final BusinessRepository _repository;
  final String businessId;
  int _currentPage = 1;
  bool _hasMore = true;

  BusinessReviewsController(this._repository, this.businessId) : super(const AsyncValue.loading()) {
    loadReviews();
  }

  Future<void> loadReviews() async {
    state = const AsyncValue.loading();
    try {
      final reviews = await _repository.getBusinessReviews(businessId, page: 1);
      _currentPage = 1;
      _hasMore = reviews.length >= 20;
      state = AsyncValue.data(reviews);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore) return;

    final currentReviews = state.valueOrNull ?? [];
    try {
      final newReviews = await _repository.getBusinessReviews(businessId, page: _currentPage + 1);
      _currentPage++;
      _hasMore = newReviews.length >= 20;
      state = AsyncValue.data([...currentReviews, ...newReviews]);
    } catch (e) {
      
    }
  }

  Future<void> addReview(int rating, String? content) async {
    try {
      final newReview = await _repository.addReview(
        businessId,
        rating: rating,
        content: content,
      );
      final currentReviews = state.valueOrNull ?? [];
      state = AsyncValue.data([newReview, ...currentReviews]);
    } catch (e) {
      
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _repository.deleteReview(businessId, reviewId);
      final currentReviews = state.valueOrNull ?? [];
      state = AsyncValue.data(currentReviews.where((r) => r.id != reviewId).toList());
    } catch (e) {
      
    }
  }
}

final businessReviewsControllerProvider = StateNotifierProvider.family<BusinessReviewsController, AsyncValue<List<BusinessReview>>, String>((ref, businessId) {
  final repository = ref.watch(businessRepositoryProvider);
  return BusinessReviewsController(repository, businessId);
});
