import 'package:equatable/equatable.dart';
import '../domain/entities/product.dart';
import '../domain/entities/order.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoadRequested extends CartEvent {
  const CartLoadRequested();
}

class CartItemAdded extends CartEvent {
  final Product product;
  final int quantity;

  const CartItemAdded({
    required this.product,
    this.quantity = 1,
  });

  @override
  List<Object?> get props => [product, quantity];
}

class CartItemRemoved extends CartEvent {
  final String productId;

  const CartItemRemoved({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class CartItemIncremented extends CartEvent {
  final String productId;

  const CartItemIncremented({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class CartItemDecremented extends CartEvent {
  final String productId;

  const CartItemDecremented({required this.productId});

  @override
  List<Object?> get props => [productId];
}

class CartItemQuantityUpdated extends CartEvent {
  final String productId;
  final int quantity;

  const CartItemQuantityUpdated({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

class CartCleared extends CartEvent {
  const CartCleared();
}

class CartCheckoutRequested extends CartEvent {
  final ShippingAddress shippingAddress;
  final String? notes;
  final String paymentMethod;

  const CartCheckoutRequested({
    required this.shippingAddress,
    this.notes,
    this.paymentMethod = 'cash',
  });

  @override
  List<Object?> get props => [shippingAddress, notes, paymentMethod];
}

/// Undo last removed item
class CartItemUndoRemoved extends CartEvent {
  const CartItemUndoRemoved();
}
