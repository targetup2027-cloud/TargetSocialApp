import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product.dart';

abstract interface class ShopLocalDataSource {
  Future<List<Product>> getProducts();
}

class ShopLocalDataSourceImpl implements ShopLocalDataSource {
  @override
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 300)); 
    return _mockProducts;
  }

  static final List<Product> _mockProducts = [
    Product(
      id: '1',
      imageUrl: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300&h=300&fit=crop',
      name: 'Premium Wireless Headphones',
      storeName: 'TechVibe Store',
      trustScore: 98,
      rating: 4.8,
      reviewCount: 2847,
      price: 299.99,
      originalPrice: 399.99,
      badge: 'Trending',
      badgeColorValue: 0xFF8B5CF6,
      discountBadge: '-25%',
      category: 'Tech',
    ),
    Product(
      id: '2',
      imageUrl: 'https://images.unsplash.com/photo-1558089687-f282ffcbc126?w=300&h=300&fit=crop',
      name: 'Smart Home Security Camera',
      storeName: 'SecureLife Tech',
      trustScore: 97,
      rating: 4.8,
      reviewCount: 3421,
      price: 129.99,
      originalPrice: 179.99,
      badge: 'Hot Deal',
      badgeColorValue: 0xFFF97316,
      discountBadge: '-28%',
      category: 'Tech',
    ),
    Product(
      id: '3',
      imageUrl: 'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=300&h=300&fit=crop',
      name: 'Designer Sunglasses...',
      storeName: 'Optic Luxe',
      trustScore: 96,
      rating: 4.9,
      reviewCount: 1082,
      price: 245,
      badge: 'Limited',
      badgeColorValue: 0xFF6366F1,
      category: 'Fashion',
    ),
    Product(
      id: '4',
      imageUrl: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=300&h=300&fit=crop',
      name: 'Minimalist Designer Watch',
      storeName: 'Luxe Timepieces',
      trustScore: 95,
      rating: 4.9,
      reviewCount: 1523,
      price: 549,
      badge: 'Best Seller',
      badgeColorValue: 0xFF06B6D4,
      category: 'Fashion',
    ),
    Product(
      id: '5',
      imageUrl: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?w=300&h=300&fit=crop',
      name: 'Premium Leather Backpack',
      storeName: 'Urban Essentials',
      trustScore: 72,
      rating: 4.6,
      reviewCount: 634,
      price: 189.99,
      category: 'Fashion',
    ),
    Product(
      id: '6',
      imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=300&h=300&fit=crop',
      name: 'Artisan Coffee Beans - 2kg',
      storeName: 'Morning Roast Co.',
      trustScore: 45,
      rating: 4.7,
      reviewCount: 892,
      price: 45.99,
      originalPrice: 59.99,
      badge: 'Hot Deal',
      badgeColorValue: 0xFFF97316,
      discountBadge: '-28%',
      category: 'Food',
    ),
  ];
}

final shopLocalDataSourceProvider = Provider<ShopLocalDataSource>((ref) {
  return ShopLocalDataSourceImpl();
});
