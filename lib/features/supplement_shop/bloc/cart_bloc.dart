import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/entities/cart.dart';
import '../domain/entities/order.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends ChangeNotifier {
  CartState _state = const CartState();

  CartState get state => _state;

  static const String _cartKey = 'supplement_cart';
  static const String _ordersKey = 'supplement_orders';

  CartBloc() {
    _loadCart();
  }

  void add(CartEvent event) {
    if (event is CartLoadRequested) {
      _loadCart();
    } else if (event is CartItemAdded) {
      _addItem(event);
    } else if (event is CartItemRemoved) {
      _removeItem(event);
    } else if (event is CartItemIncremented) {
      _incrementItem(event);
    } else if (event is CartItemDecremented) {
      _decrementItem(event);
    } else if (event is CartItemQuantityUpdated) {
      _updateQuantity(event);
    } else if (event is CartCleared) {
      _clearCart();
    } else if (event is CartCheckoutRequested) {
      _checkout(event);
    }
  }

  Future<void> _loadCart() async {
    _state = _state.copyWith(status: CartStatus.loading);
    notifyListeners();

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

      _state = _state.copyWith(
        cart: cart,
        orderHistory: orders,
        status: CartStatus.loaded,
      );
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Сагс ачаалахад алдаа гарлаа',
      );
      notifyListeners();
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartKey, json.encode(_state.cart.toJson()));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  Future<void> _saveOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = _state.orderHistory.map((o) => o.toJson()).toList();
      await prefs.setString(_ordersKey, json.encode(ordersJson));
    } catch (e) {
      debugPrint('Error saving orders: $e');
    }
  }

  void _addItem(CartItemAdded event) {
    final newCart = _state.cart.addItem(event.product, quantity: event.quantity);
    _state = _state.copyWith(cart: newCart, status: CartStatus.loaded);
    notifyListeners();
    _saveCart();
  }

  void _removeItem(CartItemRemoved event) {
    final newCart = _state.cart.removeItem(event.productId);
    _state = _state.copyWith(cart: newCart, status: CartStatus.loaded);
    notifyListeners();
    _saveCart();
  }

  void _incrementItem(CartItemIncremented event) {
    final newCart = _state.cart.incrementItem(event.productId);
    _state = _state.copyWith(cart: newCart, status: CartStatus.loaded);
    notifyListeners();
    _saveCart();
  }

  void _decrementItem(CartItemDecremented event) {
    final newCart = _state.cart.decrementItem(event.productId);
    _state = _state.copyWith(cart: newCart, status: CartStatus.loaded);
    notifyListeners();
    _saveCart();
  }

  void _updateQuantity(CartItemQuantityUpdated event) {
    final newCart = _state.cart.updateItemQuantity(event.productId, event.quantity);
    _state = _state.copyWith(cart: newCart, status: CartStatus.loaded);
    notifyListeners();
    _saveCart();
  }

  void _clearCart() {
    _state = _state.copyWith(cart: const Cart(), status: CartStatus.loaded);
    notifyListeners();
    _saveCart();
  }

  Future<void> _checkout(CartCheckoutRequested event) async {
    _state = _state.copyWith(status: CartStatus.checkingOut);
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    try {
      final order = Order(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        items: _state.cart.items,
        totalPrice: _state.cart.totalPrice,
        shippingAddress: event.shippingAddress,
        status: OrderStatus.confirmed,
        createdAt: DateTime.now(),
        notes: event.notes,
      );

      final newOrderHistory = [order, ..._state.orderHistory];

      _state = _state.copyWith(
        cart: const Cart(),
        status: CartStatus.checkoutSuccess,
        lastOrder: order,
        orderHistory: newOrderHistory,
      );
      notifyListeners();

      await _saveCart();
      await _saveOrders();
    } catch (e) {
      _state = _state.copyWith(
        status: CartStatus.error,
        errorMessage: 'Захиалга үүсгэхэд алдаа гарлаа',
      );
      notifyListeners();
    }
  }

  bool containsProduct(String productId) {
    return _state.cart.containsProduct(productId);
  }

  int getProductQuantity(String productId) {
    return _state.cart.getProductQuantity(productId);
  }
}
