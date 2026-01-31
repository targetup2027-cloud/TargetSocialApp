import 'package:equatable/equatable.dart';
import 'cart.dart';

enum OrderStatus { draft, pending, paid, failed, refunded }

class Order extends Equatable {
  final String id;
  final Cart cart;
  final OrderStatus status;
  final String userId;
  final DateTime createdAt;
  final String? paymentId;

  const Order({
    required this.id,
    required this.cart,
    required this.status,
    required this.userId,
    required this.createdAt,
    this.paymentId,
  });

  @override
  List<Object?> get props => [id, cart, status, userId, createdAt, paymentId];
}
