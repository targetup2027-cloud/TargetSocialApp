import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shop_providers.dart';
import '../domain/entities/cart.dart';
import '../../../core/result/result.dart';

class CartController extends StateNotifier<AsyncValue<Cart>> {
  final Ref _ref;

  CartController(this._ref) : super(const AsyncValue.loading()) {
    getCart();
  }

  Future<void> getCart() async {
    state = const AsyncValue.loading();
    final repo = _ref.read(cartRepositoryProvider);
    final result = await repo.getCart();
    
    state = switch (result) {
      Success(value: final cart) => AsyncValue.data(cart),
      Err(failure: final f) => AsyncValue.error(f, StackTrace.current),
    };
  }

  Future<void> addItem(String productId) async {
    final repo = _ref.read(cartRepositoryProvider);
    final result = await repo.addToCart(productId, 1);
    
    if (result case Success(value: final cart)) {
      state = AsyncValue.data(cart);
    }
  }

  Future<void> removeItem(String productId) async {
    final repo = _ref.read(cartRepositoryProvider);
    final result = await repo.removeFromCart(productId);
    
     if (result case Success(value: final cart)) {
      state = AsyncValue.data(cart);
    }
  }
}

final cartControllerProvider = StateNotifierProvider<CartController, AsyncValue<Cart>>((ref) {
  return CartController(ref);
});
