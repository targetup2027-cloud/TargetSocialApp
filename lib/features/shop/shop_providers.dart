import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'domain/repositories/shop_repository.dart';
import 'data/repositories/shop_repository_impl.dart';
import 'domain/repositories/cart_repository.dart';
import 'data/repositories/cart_repository_impl.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  return ref.watch(shopRepositoryImplProvider);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return ref.watch(cartRepositoryImplProvider);
});
