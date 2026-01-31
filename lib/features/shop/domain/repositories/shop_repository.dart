import '../../../../core/result/result.dart';
import '../entities/product.dart';

abstract interface class ShopRepository {
  Future<Result<List<Product>>> getProducts({
    String? category,
    String? searchQuery,
    String? sortBy,
  });

  Future<Result<Product?>> getProductById(String id);
}
