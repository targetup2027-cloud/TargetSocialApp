import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String imageUrl;
  final String name;
  final String storeName;
  final int trustScore;
  final double rating;
  final int reviewCount;
  final double price;
  final double? originalPrice;
  final String? badge;
  final int? badgeColorValue;
  final String? discountBadge;
  final String category;

  const Product({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.storeName,
    required this.trustScore,
    required this.rating,
    required this.reviewCount,
    required this.price,
    this.originalPrice,
    this.badge,
    this.badgeColorValue,
    this.discountBadge,
    this.category = 'All',
  });

  @override
  List<Object?> get props => [
    id, imageUrl, name, storeName, trustScore, rating, reviewCount, 
    price, originalPrice, badge, badgeColorValue, discountBadge, category
  ];
}
