import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shop_providers.dart';
import '../domain/entities/product.dart';
import '../../../core/result/result.dart';

class ProductsFilter {
  final String? category;
  final String? searchQuery;
  final String? sortBy;

  const ProductsFilter({
    this.category,
    this.searchQuery,
    this.sortBy,
  });
}

final productsFilterProvider = StateProvider<ProductsFilter>((ref) {
  return const ProductsFilter();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(shopRepositoryProvider);
  final filter = ref.watch(productsFilterProvider);
  
  final result = await repo.getProducts(
    category: filter.category,
    searchQuery: filter.searchQuery,
    sortBy: filter.sortBy,
  );
  
  return switch (result) {
    Success(value: final products) => products,
    Err() => [],
  };
});
