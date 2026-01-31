import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/price_summary.dart';
import '../../domain/repositories/quote_repository.dart';

final quoteRepositoryProvider = Provider<QuoteRepository>((ref) {
  return QuoteRepositoryImpl(config: currentConfig);
});

class QuoteRepositoryImpl implements QuoteRepository {
  final AppConfig _config;

  QuoteRepositoryImpl({required AppConfig config}) : _config = config;

  @override
  Future<Result<PriceSummary>> getQuote(Cart cart) async {
    if (_config.useRemoteData) {
      throw UnimplementedError();
    } else {
      final summary = PriceSummary.estimated(
        subtotal: cart.subtotal,
        shipping: cart.shipping,
        taxRate: 0.05,
      );
      return Success(summary);
    }
  }
}
