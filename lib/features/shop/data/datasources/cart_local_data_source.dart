import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart.dart';

abstract interface class CartLocalDataSource {
  Future<Cart> getCart();
  Future<void> saveCart(Cart cart);
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  Cart _currentCart = const Cart();

  @override
  Future<Cart> getCart() async {
    return _currentCart;
  }

  @override
  Future<void> saveCart(Cart cart) async {
    _currentCart = cart;
  }
}

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSourceImpl();
});
