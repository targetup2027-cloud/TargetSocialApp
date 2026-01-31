import '../../../../core/result/result.dart';
import '../entities/order.dart';

abstract interface class OrderRepository {
  Future<Result<Order>> createOrderFromCart();
  Future<Result<Order>> getOrder(String orderId);
  Future<Result<List<Order>>> getMyOrders();
}
