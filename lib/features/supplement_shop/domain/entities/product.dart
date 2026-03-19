import 'package:equatable/equatable.dart';

enum ProductCategory {
  protein,
  vitamins,
  preworkout,
  recovery,
  weightLoss,
  accessories,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.protein:
        return 'Уураг';
      case ProductCategory.vitamins:
        return 'Витамин';
      case ProductCategory.preworkout:
        return 'Дасгалын өмнөх';
      case ProductCategory.recovery:
        return 'Сэргээлт';
      case ProductCategory.weightLoss:
        return 'Жин хасах';
      case ProductCategory.accessories:
        return 'Хэрэгсэл';
    }
  }

  String get icon {
    switch (this) {
      case ProductCategory.protein:
        return '💪';
      case ProductCategory.vitamins:
        return '💊';
      case ProductCategory.preworkout:
        return '⚡';
      case ProductCategory.recovery:
        return '🧘';
      case ProductCategory.weightLoss:
        return '🔥';
      case ProductCategory.accessories:
        return '🎽';
    }
  }
}

class Product extends Equatable {
  final String id;
  final String name;
  final double price;
  final String image;
  final String description;
  final ProductCategory category;
  final double rating;
  final int reviewCount;
  final bool inStock;
  final int stockQuantity;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.inStock = true,
    this.stockQuantity = 100,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? image,
    String? description,
    ProductCategory? category,
    double? rating,
    int? reviewCount,
    bool? inStock,
    int? stockQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      image: image ?? this.image,
      description: description ?? this.description,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      inStock: inStock ?? this.inStock,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'description': description,
      'category': category.index,
      'rating': rating,
      'reviewCount': reviewCount,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      image: json['image'] as String,
      description: json['description'] as String,
      category: ProductCategory.values[json['category'] as int],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      inStock: json['inStock'] as bool? ?? true,
      stockQuantity: json['stockQuantity'] as int? ?? 100,
    );
  }

  String get formattedPrice => '₮${price.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        image,
        description,
        category,
        rating,
        reviewCount,
        inStock,
        stockQuantity,
      ];
}
