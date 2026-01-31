import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/result/result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/cart.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/cart_local_data_source.dart';
import 'shop_repository_impl.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _localDataSource;
  final ShopRepository _shopRepository;

  CartRepositoryImpl({
    required CartLocalDataSource localDataSource,
    required ShopRepository shopRepository,
  })  : _localDataSource = localDataSource,
        _shopRepository = shopRepository;

  @override
  Future<Result<Cart>> getCart() async {
    try {
      final cart = await _localDataSource.getCart();
      return Success(cart);
    } catch (e) {
      return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Cart>> addToCart(String productId, int quantity) async {
    try {
      final cart = await _localDataSource.getCart();
      
      // Check if item exists
      final existingIndex = cart.items.indexWhere((i) => i.product.id == productId);
      
      List<CartItem> newItems;
      if (existingIndex >= 0) {
        final existingItem = cart.items[existingIndex];
        final newItem = existingItem.copyWith(quantity: existingItem.quantity + quantity);
        newItems = [...cart.items]..[existingIndex] = newItem;
      } else {
        // Fetch product
        final productResult = await _shopRepository.getProductById(productId);
        if (!productResult.isSuccess || productResult.valueOrNull == null) {
             return const Err(UnknownFailure(message: 'Product not found'));
        }
        final product = productResult.valueOrNull!;
        newItems = [...cart.items, CartItem(product: product, quantity: quantity)];
      }

      final newCart = Cart.calculate(items: newItems, shipping: 12.00, taxRate: 0.08); // Mock shipping/tax
      await _localDataSource.saveCart(newCart);
      return Success(newCart);
    } catch (e) {
       return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Cart>> removeFromCart(String productId) async {
     try {
      final cart = await _localDataSource.getCart();
      final newItems = cart.items.where((i) => i.product.id != productId).toList();
      final newCart = Cart.calculate(items: newItems, shipping: 12.00, taxRate: 0.08);
      await _localDataSource.saveCart(newCart);
      return Success(newCart);
    } catch (e) {
       return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Cart>> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) return removeFromCart(productId);
    
    try {
      final cart = await _localDataSource.getCart();
       final existingIndex = cart.items.indexWhere((i) => i.product.id == productId);
      
      if (existingIndex >= 0) {
        final newItem = cart.items[existingIndex].copyWith(quantity: quantity);
        final newItems = [...cart.items]..[existingIndex] = newItem;
        final newCart = Cart.calculate(items: newItems, shipping: 12.00, taxRate: 0.08);
        await _localDataSource.saveCart(newCart);
        return Success(newCart);
      }
      return Success(cart);
    } catch (e) {
       return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> clearCart() async {
    await _localDataSource.saveCart(const Cart());
    return const Success(null);
  }
}

final cartRepositoryImplProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(
    localDataSource: ref.watch(cartLocalDataSourceProvider),
    shopRepository: ref.watch(shopRepositoryImplProvider),
  );
});
