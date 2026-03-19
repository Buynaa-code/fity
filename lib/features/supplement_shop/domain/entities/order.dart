import 'package:equatable/equatable.dart';
import 'cart_item.dart';

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Хүлээгдэж байна';
      case OrderStatus.confirmed:
        return 'Баталгаажсан';
      case OrderStatus.processing:
        return 'Боловсруулж байна';
      case OrderStatus.shipped:
        return 'Хүргэлтэнд гарсан';
      case OrderStatus.delivered:
        return 'Хүргэгдсэн';
      case OrderStatus.cancelled:
        return 'Цуцлагдсан';
    }
  }

  String get icon {
    switch (this) {
      case OrderStatus.pending:
        return '⏳';
      case OrderStatus.confirmed:
        return '✅';
      case OrderStatus.processing:
        return '📦';
      case OrderStatus.shipped:
        return '🚚';
      case OrderStatus.delivered:
        return '🎉';
      case OrderStatus.cancelled:
        return '❌';
    }
  }
}

class ShippingAddress extends Equatable {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String district;

  const ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.address,
    this.city = 'Улаанбаатар',
    this.district = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'district': district,
    };
  }

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      city: json['city'] as String? ?? 'Улаанбаатар',
      district: json['district'] as String? ?? '',
    );
  }

  String get fullAddress => '$city, $district, $address';

  @override
  List<Object?> get props => [fullName, phone, address, city, district];
}

class Order extends Equatable {
  final String id;
  final List<CartItem> items;
  final double totalPrice;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final ShippingAddress shippingAddress;
  final String? notes;

  const Order({
    required this.id,
    required this.items,
    required this.totalPrice,
    required this.shippingAddress,
    this.status = OrderStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.notes,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  String get formattedTotalPrice => '₮${totalPrice.toStringAsFixed(0)}';

  String get formattedDate {
    return '${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}';
  }

  Order copyWith({
    String? id,
    List<CartItem>? items,
    double? totalPrice,
    OrderStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    ShippingAddress? shippingAddress,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'shippingAddress': shippingAddress.toJson(),
      'notes': notes,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: OrderStatus.values[json['status'] as int],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      shippingAddress:
          ShippingAddress.fromJson(json['shippingAddress'] as Map<String, dynamic>),
      notes: json['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        items,
        totalPrice,
        status,
        createdAt,
        updatedAt,
        shippingAddress,
        notes,
      ];
}
