import 'package:equatable/equatable.dart';
import '../domain/entities/cart.dart';
import '../domain/entities/order.dart';

enum CartStatus {
  initial,
  loading,
  loaded,
  checkingOut,
  checkoutSuccess,
  error,
}

class CartState extends Equatable {
  final Cart cart;
  final CartStatus status;
  final String? errorMessage;
  final Order? lastOrder;
  final List<Order> orderHistory;

  const CartState({
    this.cart = const Cart(),
    this.status = CartStatus.initial,
    this.errorMessage,
    this.lastOrder,
    this.orderHistory = const [],
  });

  bool get isEmpty => cart.isEmpty;
  bool get isNotEmpty => cart.isNotEmpty;
  int get itemCount => cart.itemCount;
  double get totalPrice => cart.totalPrice;
  String get formattedTotalPrice => cart.formattedTotalPrice;

  CartState copyWith({
    Cart? cart,
    CartStatus? status,
    String? errorMessage,
    Order? lastOrder,
    List<Order>? orderHistory,
  }) {
    return CartState(
      cart: cart ?? this.cart,
      status: status ?? this.status,
      errorMessage: errorMessage,
      lastOrder: lastOrder ?? this.lastOrder,
      orderHistory: orderHistory ?? this.orderHistory,
    );
  }

  @override
  List<Object?> get props => [cart, status, errorMessage, lastOrder, orderHistory];
}
