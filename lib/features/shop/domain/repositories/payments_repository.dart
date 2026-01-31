import '../../../../core/result/result.dart';

enum PaymentStatus { pending, processing, succeeded, failed, refunded }

class PaymentIntent {
  final String id;
  final String orderId;
  final double amount;
  final String currency;
  final PaymentStatus status;
  final String? clientRequestId;
  final DateTime createdAt;

  const PaymentIntent({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.status,
    this.clientRequestId,
    required this.createdAt,
  });
}

class PaymentResult {
  final String paymentIntentId;
  final PaymentStatus status;
  final String? errorMessage;

  const PaymentResult({
    required this.paymentIntentId,
    required this.status,
    this.errorMessage,
  });
}

abstract interface class PaymentsRepository {
  Future<Result<PaymentIntent>> createPaymentIntent({
    required String orderId,
    required double amount,
    required String currency,
    required String clientRequestId,
  });

  Future<Result<PaymentResult>> confirmPayment({
    required String paymentIntentId,
    required Map<String, dynamic> paymentMethod,
  });

  Future<Result<PaymentIntent>> getPaymentStatus(String paymentIntentId);

  Future<Result<List<PaymentIntent>>> getPaymentHistory();
}
