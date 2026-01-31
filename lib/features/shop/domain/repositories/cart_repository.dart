import '../../../../core/result/result.dart';
import '../entities/cart.dart';

abstract interface class CartRepository {
  Future<Result<Cart>> getCart();
  Future<Result<Cart>> addToCart(String productId, int quantity);
  Future<Result<Cart>> removeFromCart(String productId);
  Future<Result<Cart>> updateQuantity(String productId, int quantity);
  Future<Result<void>> clearCart();
}
