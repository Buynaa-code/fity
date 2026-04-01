import '../../domain/entities/trainer_subscription.dart';

class TrainerSubscriptionModel extends TrainerSubscription {
  const TrainerSubscriptionModel({
    required super.id,
    required super.trainerId,
    required super.tier,
    required super.status,
    required super.price,
    required super.startDate,
    required super.endDate,
    required super.createdAt,
  });

  factory TrainerSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return TrainerSubscriptionModel(
      id: json['id'] as String,
      trainerId: json['trainerId'] as String,
      tier: SubscriptionTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => SubscriptionTier.basic,
      ),
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SubscriptionStatus.pending,
      ),
      price: (json['price'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trainerId': trainerId,
      'tier': tier.name,
      'status': status.name,
      'price': price,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TrainerSubscriptionModel.fromEntity(TrainerSubscription entity) {
    return TrainerSubscriptionModel(
      id: entity.id,
      trainerId: entity.trainerId,
      tier: entity.tier,
      status: entity.status,
      price: entity.price,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
    );
  }

  @override
  TrainerSubscriptionModel copyWith({
    String? id,
    String? trainerId,
    SubscriptionTier? tier,
    SubscriptionStatus? status,
    double? price,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return TrainerSubscriptionModel(
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
}
