import '../../domain/repositories/payments_repository.dart';

abstract interface class PaymentsRemoteDataSource {
  Future<PaymentIntent> createPaymentIntent({
    required String orderId,
    required double amount,
    required String currency,
    required String clientRequestId,
  });

  Future<PaymentResult> confirmPayment({
    required String paymentIntentId,
    required Map<String, dynamic> paymentMethod,
  });

  Future<PaymentIntent> getPaymentStatus(String paymentIntentId);

  Future<List<PaymentIntent>> getPaymentHistory();
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  @override
  Future<PaymentIntent> createPaymentIntent({
    required String orderId,
    required double amount,
    required String currency,
    required String clientRequestId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PaymentResult> confirmPayment({
    required String paymentIntentId,
    required Map<String, dynamic> paymentMethod,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<PaymentIntent> getPaymentStatus(String paymentIntentId) {
    throw UnimplementedError();
  }

  @override
  Future<List<PaymentIntent>> getPaymentHistory() {
    throw UnimplementedError();
  }
}
