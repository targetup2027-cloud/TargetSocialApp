import 'package:equatable/equatable.dart';
import 'product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;

  const CartItem({
    required this.product,
    required this.quantity,
  });

  double get total => product.price * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [product, quantity];
}

class Cart extends Equatable {
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;

  const Cart({
    this.items = const [],
    this.subtotal = 0.0,
    this.shipping = 0.0,
    this.tax = 0.0,
    this.total = 0.0,
  });

  factory Cart.calculate({required List<CartItem> items, double shipping = 0.0, double taxRate = 0.0}) {
    final subtotal = items.fold(0.0, (sum, item) => sum + item.total);
    final tax = subtotal * taxRate;
    final total = subtotal + shipping + tax;
    
    return Cart(
      items: items,
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      total: total,
    );
  }

  @override
  List<Object?> get props => [items, subtotal, shipping, tax, total];
}
