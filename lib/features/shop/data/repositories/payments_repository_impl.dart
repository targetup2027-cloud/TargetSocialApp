import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/result/result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_local_data_source.dart';
import '../datasources/payments_remote_data_source.dart';

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepositoryImpl(
    localDataSource: PaymentsLocalDataSourceImpl(),
    remoteDataSource: PaymentsRemoteDataSourceImpl(),
    config: currentConfig,
  );
});

class PaymentsRepositoryImpl implements PaymentsRepository {
  final PaymentsLocalDataSource _localDataSource;
  final PaymentsRemoteDataSource _remoteDataSource;
  final AppConfig _config;

  PaymentsRepositoryImpl({
    required PaymentsLocalDataSource localDataSource,
    required PaymentsRemoteDataSource remoteDataSource,
    required AppConfig config,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _config = config;

  @override
  Future<Result<PaymentIntent>> createPaymentIntent({
    required String orderId,
    required double amount,
    required String currency,
    required String clientRequestId,
  }) async {
    try {
      final exists = await _localDataSource.hasClientRequestId(clientRequestId);
      if (exists) {
        final cached = await _localDataSource.getPaymentHistory();
        final existing = cached.firstWhere(
          (p) => p.clientRequestId == clientRequestId,
        );
        return Success(existing);
      }

      if (_config.useRemoteData) {
        final intent = await _remoteDataSource.createPaymentIntent(
          orderId: orderId,
          amount: amount,
          currency: currency,
          clientRequestId: clientRequestId,
        );
        return Success(intent);
      } else {
        final intent = await _localDataSource.createLocalPaymentIntent(
          orderId: orderId,
          amount: amount,
          currency: currency,
          clientRequestId: clientRequestId,
        );
        return Success(intent);
      }
    } catch (e) {
      return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PaymentResult>> confirmPayment({
    required String paymentIntentId,
    required Map<String, dynamic> paymentMethod,
  }) async {
    try {
      if (_config.useRemoteData) {
        final result = await _remoteDataSource.confirmPayment(
          paymentIntentId: paymentIntentId,
          paymentMethod: paymentMethod,
        );
        return Success(result);
      } else {
        await _localDataSource.updatePaymentStatus(
          paymentIntentId,
          PaymentStatus.succeeded,
        );
        return Success(PaymentResult(
          paymentIntentId: paymentIntentId,
          status: PaymentStatus.succeeded,
        ));
      }
    } catch (e) {
      return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<PaymentIntent>> getPaymentStatus(String paymentIntentId) async {
    try {
      if (_config.useRemoteData) {
        final intent = await _remoteDataSource.getPaymentStatus(paymentIntentId);
        return Success(intent);
      } else {
        final intent = await _localDataSource.getPaymentIntent(paymentIntentId);
        if (intent == null) {
          return const Err(UnknownFailure(message: 'Payment not found'));
        }
        return Success(intent);
      }
    } catch (e) {
      return Err(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<PaymentIntent>>> getPaymentHistory() async {
    try {
      if (_config.useRemoteData) {
        final history = await _remoteDataSource.getPaymentHistory();
        return Success(history);
      } else {
        final history = await _localDataSource.getPaymentHistory();
        return Success(history);
      }
    } catch (e) {
      return Err(UnknownFailure(message: e.toString()));
    }
  }
}
