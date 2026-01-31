import 'package:equatable/equatable.dart';

class PriceSummary extends Equatable {
  final double subtotal;
  final double shipping;
  final double tax;
  final double discount;
  final double total;
  final bool isEstimated;
  final String? quoteId;
  final DateTime? expiresAt;

  const PriceSummary({
    required this.subtotal,
    required this.shipping,
    required this.tax,
    this.discount = 0.0,
    required this.total,
    required this.isEstimated,
    this.quoteId,
    this.expiresAt,
  });

  factory PriceSummary.estimated({
    required double subtotal,
    double shipping = 0.0,
    double taxRate = 0.0,
    double discount = 0.0,
  }) {
    final tax = subtotal * taxRate;
    final total = subtotal + shipping + tax - discount;
    return PriceSummary(
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      discount: discount,
      total: total,
      isEstimated: true,
    );
  }

  factory PriceSummary.fromServer({
    required double subtotal,
    required double shipping,
    required double tax,
    required double discount,
    required double total,
    required String quoteId,
    DateTime? expiresAt,
  }) {
    return PriceSummary(
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      discount: discount,
      total: total,
      isEstimated: false,
      quoteId: quoteId,
      expiresAt: expiresAt,
    );
  }

  @override
  List<Object?> get props => [subtotal, shipping, tax, discount, total, isEstimated, quoteId, expiresAt];
}
