import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/cart.dart';
import '../domain/entities/order.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// CartBloc - Сагсны state management
/// flutter_bloc ашиглан зөв Bloc pattern хэрэгжүүлсэн
class CartBloc extends Bloc<CartEvent, CartState> {
  static const String _cartKey = 'supplement_cart';
  static const String _ordersKey = 'supplement_orders';

  CartBloc() : super(const CartState()) {
    on<CartLoadRequested>(_onLoadRequested);
    on<CartItemAdded>(_onItemAdded);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartItemIncremented>(_onItemIncremented);
    on<CartItemDecremented>(_onItemDecremented);
    on<CartItemQuantityUpdated>(_onQuantityUpdated);
    on<CartCleared>(_onCleared);
    on<CartCheckoutRequested>(_onCheckoutRequested);
    on<CartItemUndoRemoved>(_onItemUndoRemoved);
  }

  // ============================================
  // EVENT HANDLERS
  // ============================================

  Future<void> _onLoadRequested(
    CartLoadRequested event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(status: CartStatus.loading));

    try {
      final prefs = await SharedPreferences.getInstance();

      // Load cart
      final cartData = prefs.getString(_cartKey);
      Cart cart = const Cart();
      if (cartData != null) {
        cart = Cart.fromJson(json.decode(cartData));
      }

      // Load order history
      final ordersData = prefs.getString(_ordersKey);
      List<Order> orders = [];
      if (ordersData != null) {
        final ordersList = json.decode(ordersData) as List;
        orders = ordersList
            .map((o) => Order.fromJson(o as Map<String, dynamic>))
            .toList();
      }

      emit(state.copyWith(
        cart: cart,
        orderHistory: orders,
        status: CartStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Сагс ачаалахад алдаа гарлаа',
      ));
    }
  }

  Future<void> _onItemAdded(
    CartItemAdded event,
    Emitter<CartState> emit,
  ) async {
    // Check stock before adding
    if (!event.product.inStock) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: '${event.product.name} дууссан байна',
      ));
      // Restore to loaded after error
      emit(state.copyWith(status: CartStatus.loaded));
      return;
    }

    final currentQuantity = state.cart.getProductQuantity(event.product.id);
    final newQuantity = currentQuantity + event.quantity;

    // Check if exceeds stock
    if (newQuantity > event.product.stockQuantity) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Хамгийн ихдээ ${event.product.stockQuantity} ширхэг захиалах боломжтой',
      ));
      emit(state.copyWith(status: CartStatus.loaded));
      return;
    }

    final newCart = state.cart.addItem(event.product, quantity: event.quantity);
    emit(state.copyWith(cart: newCart, status: CartStatus.loaded));
    await _saveCart(newCart);
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    // Store removed item for undo
    final removedItem = state.cart.items.firstWhere(
      (item) => item.product.id == event.productId,
      orElse: () => throw Exception('Item not found'),
    );

    final newCart = state.cart.removeItem(event.productId);
    emit(state.copyWith(
      cart: newCart,
      status: CartStatus.loaded,
      lastRemovedItem: removedItem,
    ));
    await _saveCart(newCart);
  }

  Future<void> _onItemUndoRemoved(
    CartItemUndoRemoved event,
    Emitter<CartState> emit,
  ) async {
    if (state.lastRemovedItem == null) return;

    final item = state.lastRemovedItem!;
    final newCart = state.cart.addItem(item.product, quantity: item.quantity);
    emit(state.copyWith(
      cart: newCart,
      status: CartStatus.loaded,
      lastRemovedItem: null,
    ));
    await _saveCart(newCart);
  }

  Future<void> _onItemIncremented(
    CartItemIncremented event,
    Emitter<CartState> emit,
  ) async {
    // Find product to check stock
    final item = state.cart.items.firstWhere(
      (item) => item.product.id == event.productId,
      orElse: () => throw Exception('Item not found'),
    );

    if (item.quantity >= item.product.stockQuantity) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Хамгийн ихдээ ${item.product.stockQuantity} ширхэг',
      ));
      emit(state.copyWith(status: CartStatus.loaded));
      return;
    }

    final newCart = state.cart.incrementItem(event.productId);
    emit(state.copyWith(cart: newCart, status: CartStatus.loaded));
    await _saveCart(newCart);
  }

  Future<void> _onItemDecremented(
    CartItemDecremented event,
    Emitter<CartState> emit,
  ) async {
    final newCart = state.cart.decrementItem(event.productId);
    emit(state.copyWith(cart: newCart, status: CartStatus.loaded));
    await _saveCart(newCart);
  }

  Future<void> _onQuantityUpdated(
    CartItemQuantityUpdated event,
    Emitter<CartState> emit,
  ) async {
    if (event.quantity < 1) {
      // Remove item if quantity is 0 or less
      add(CartItemRemoved(productId: event.productId));
      return;
    }

    // Find product to check stock
    final item = state.cart.items.firstWhere(
      (item) => item.product.id == event.productId,
      orElse: () => throw Exception('Item not found'),
    );

    if (event.quantity > item.product.stockQuantity) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Хамгийн ихдээ ${item.product.stockQuantity} ширхэг',
      ));
      emit(state.copyWith(status: CartStatus.loaded));
      return;
    }

    final newCart = state.cart.updateItemQuantity(event.productId, event.quantity);
    emit(state.copyWith(cart: newCart, status: CartStatus.loaded));
    await _saveCart(newCart);
  }

  Future<void> _onCleared(
    CartCleared event,
    Emitter<CartState> emit,
  ) async {
    emit(state.copyWith(cart: const Cart(), status: CartStatus.loaded));
    await _saveCart(const Cart());
  }

  Future<void> _onCheckoutRequested(
    CartCheckoutRequested event,
    Emitter<CartState> emit,
  ) async {
    if (state.cart.isEmpty) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Сагс хоосон байна',
      ));
      return;
    }

    emit(state.copyWith(status: CartStatus.checkingOut));

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      final order = Order(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        items: state.cart.items,
        totalPrice: state.cart.totalPrice,
        shippingAddress: event.shippingAddress,
        status: OrderStatus.confirmed,
        createdAt: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
        notes: event.notes,
        paymentMethod: event.paymentMethod,
      );

      final newOrderHistory = [order, ...state.orderHistory];

      emit(state.copyWith(
        cart: const Cart(),
        status: CartStatus.checkoutSuccess,
        lastOrder: order,
        orderHistory: newOrderHistory,
      ));

      await _saveCart(const Cart());
      await _saveOrders(newOrderHistory);
    } catch (e) {
      emit(state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Захиалга үүсгэхэд алдаа гарлаа',
      ));
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  Future<void> _saveCart(Cart cart) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartKey, json.encode(cart.toJson()));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> _saveOrders(List<Order> orders) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = orders.map((o) => o.toJson()).toList();
      await prefs.setString(_ordersKey, json.encode(ordersJson));
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  /// Check if product is in cart
  bool containsProduct(String productId) {
    return state.cart.containsProduct(productId);
  }

  /// Get product quantity in cart
  int getProductQuantity(String productId) {
    return state.cart.getProductQuantity(productId);
  }
}
