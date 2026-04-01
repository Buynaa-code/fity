import 'package:equatable/equatable.dart';

enum SubscriptionTier { basic, professional, premium }

enum SubscriptionStatus { active, expired, cancelled, pending }

class TrainerSubscription extends Equatable {
  final String id;
  final String trainerId;
  final SubscriptionTier tier;
  final SubscriptionStatus status;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;

  const TrainerSubscription({
    required this.id,
    required this.trainerId,
    required this.tier,
    required this.status,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  bool get isActive =>
      status == SubscriptionStatus.active && DateTime.now().isBefore(endDate);

  bool get isFeatured =>
      isActive &&
      (tier == SubscriptionTier.professional ||
          tier == SubscriptionTier.premium);

  String get tierName {
    switch (tier) {
      case SubscriptionTier.basic:
        return 'Энгийн';
      case SubscriptionTier.professional:
        return 'Мэргэжлийн';
      case SubscriptionTier.premium:
        return 'Премиум';
    }
  }

  static double getTierPrice(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic:
        return 50000;
      case SubscriptionTier.professional:
        return 100000;
      case SubscriptionTier.premium:
        return 200000;
    }
  }

  static List<String> getTierFeatures(SubscriptionTier tier) {
    switch (tier) {
      case SubscriptionTier.basic:
        return [
          'Marketplace бүртгэл',
          '5 захиалга/сар',
          'Үндсэн профайл',
        ];
      case SubscriptionTier.professional:
        return [
          'Marketplace бүртгэл',
          'Хязгааргүй захиалга',
          'Нүүр хуудас карусел-д харагдах',
          'Мэргэжлийн профайл',
        ];
      case SubscriptionTier.premium:
        return [
          'Marketplace бүртгэл',
          'Хязгааргүй захиалга',
          'Карусел-д эхэнд харагдах',
          'Видео танилцуулга',
          'Онцгой дэмжлэг',
        ];
    }
  }

  int get remainingDays {
    if (!isActive) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }

  TrainerSubscription copyWith({
    String? id,
    String? trainerId,
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    double? price,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return TrainerSubscription(
      id: id ?? this.id,
      trainerId: trainerId ?? this.trainerId,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      price: price ?? this.price,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trainerId,
        tier,
        status,
        price,
        startDate,
        endDate,
        createdAt,
      ];
}
