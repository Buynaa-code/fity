import 'package:equatable/equatable.dart';
import 'cart_item.dart';
import 'product.dart';

class Cart extends Equatable {
  final List<CartItem> items;

  const Cart({
    this.items = const [],
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      items.fold(0.0, (sum, item) => sum + item.totalPrice);

  String get formattedTotalPrice => '₮${totalPrice.toStringAsFixed(0)}';

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  bool containsProduct(String productId) {
    return items.any((item) => item.product.id == productId);
  }

  int getProductQuantity(String productId) {
    final item = items.where((item) => item.product.id == productId).firstOrNull;
    return item?.quantity ?? 0;
  }

  Cart addItem(Product product, {int quantity = 1}) {
    final existingIndex =
        items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      final updatedItems = List<CartItem>.from(items);
      updatedItems[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + quantity,
      );
      return Cart(items: updatedItems);
    } else {
      return Cart(items: [...items, CartItem(product: product, quantity: quantity)]);
    }
  }

  Cart removeItem(String productId) {
    return Cart(
      items: items.where((item) => item.product.id != productId).toList(),
    );
  }

  Cart updateItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      return removeItem(productId);
    }

    final updatedItems = items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    return Cart(items: updatedItems);
  }

  Cart incrementItem(String productId) {
    final updatedItems = items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    return Cart(items: updatedItems);
  }

  Cart decrementItem(String productId) {
    final item = items.where((item) => item.product.id == productId).firstOrNull;
    if (item == null) return this;

    if (item.quantity <= 1) {
      return removeItem(productId);
    }

    final updatedItems = items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: item.quantity - 1);
      }
      return item;
    }).toList();

    return Cart(items: updatedItems);
  }

  Cart clear() {
    return const Cart(items: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [items];
}
