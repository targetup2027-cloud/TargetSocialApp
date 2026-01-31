import 'package:uuid/uuid.dart';
import '../../domain/repositories/payments_repository.dart';

abstract interface class PaymentsLocalDataSource {
  Future<PaymentIntent> createLocalPaymentIntent({
    required String orderId,
    required double amount,
    required String currency,
    required String clientRequestId,
  });

  Future<void> updatePaymentStatus(String paymentIntentId, PaymentStatus status);

  Future<PaymentIntent?> getPaymentIntent(String paymentIntentId);

  Future<List<PaymentIntent>> getPaymentHistory();

  Future<bool> hasClientRequestId(String clientRequestId);
}

class PaymentsLocalDataSourceImpl implements PaymentsLocalDataSource {
  final Map<String, PaymentIntent> _cache = {};
  final Set<String> _usedClientRequestIds = {};
  final Uuid _uuid = const Uuid();

  @override
  Future<PaymentIntent> createLocalPaymentIntent({
    required String orderId,
    required double amount,
    required String currency,
    required String clientRequestId,
  }) async {
    if (_usedClientRequestIds.contains(clientRequestId)) {
      final existing = _cache.values.firstWhere(
        (p) => p.clientRequestId == clientRequestId,
      );
      return existing;
    }

    final intent = PaymentIntent(
      id: _uuid.v4(),
      orderId: orderId,
      amount: amount,
      currency: currency,
      status: PaymentStatus.pending,
      clientRequestId: clientRequestId,
      createdAt: DateTime.now(),
    );

    _cache[intent.id] = intent;
    _usedClientRequestIds.add(clientRequestId);
    return intent;
  }

  @override
  Future<void> updatePaymentStatus(String paymentIntentId, PaymentStatus status) async {
    final existing = _cache[paymentIntentId];
    if (existing != null) {
      _cache[paymentIntentId] = PaymentIntent(
        id: existing.id,
        orderId: existing.orderId,
        amount: existing.amount,
        currency: existing.currency,
        status: status,
        clientRequestId: existing.clientRequestId,
        createdAt: existing.createdAt,
      );
    }
  }

  @override
  Future<PaymentIntent?> getPaymentIntent(String paymentIntentId) async {
    return _cache[paymentIntentId];
  }

  @override
  Future<List<PaymentIntent>> getPaymentHistory() async {
    return _cache.values.toList();
  }

  @override
  Future<bool> hasClientRequestId(String clientRequestId) async {
    return _usedClientRequestIds.contains(clientRequestId);
  }
}
