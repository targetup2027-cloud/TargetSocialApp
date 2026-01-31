import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_local_data_source.dart';

class ShopRepositoryImpl implements ShopRepository {
  final ShopLocalDataSource _localDataSource;

  ShopRepositoryImpl({
    required ShopLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<Result<List<Product>>> getProducts({
    String? category,
    String? searchQuery,
    String? sortBy,
  }) async {
    try {
      final allProducts = await _localDataSource.getProducts();
      
      var filtered = allProducts;
      
      if (category != null && category != 'All') {
        filtered = filtered.where((p) => p.category.toLowerCase().contains(category.toLowerCase()) || category == 'Fashion' && (p.name.contains('Watch') || p.name.contains('Sunglasses') || p.name.contains('Backpack'))).toList(); 
      }
      
      return Success(filtered);
    } catch (e) {
      return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Product?>> getProductById(String id) async {
    try {
      final allProducts = await _localDataSource.getProducts();
      final product = allProducts.firstWhere((p) => p.id == id, orElse: () => throw Exception('Not found'));
      return Success(product);
    } catch (e) {
      return const Success(null);
    }
  }
}

final shopRepositoryImplProvider = Provider<ShopRepository>((ref) {
  return ShopRepositoryImpl(
    localDataSource: ref.watch(shopLocalDataSourceProvider),
  );
});
