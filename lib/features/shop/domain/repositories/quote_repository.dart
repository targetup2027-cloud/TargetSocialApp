import '../../../../core/result/result.dart';
import '../entities/cart.dart';
import '../entities/price_summary.dart';

abstract interface class QuoteRepository {
  Future<Result<PriceSummary>> getQuote(Cart cart);
}
