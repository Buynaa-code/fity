import 'package:equatable/equatable.dart';
import '../../../domain/entities/trainer.dart';
import '../../../domain/entities/trainer_subscription.dart';

abstract class TrainerRegistrationEvent extends Equatable {
  const TrainerRegistrationEvent();

  @override
  List<Object?> get props => [];
}

class InitializeRegistration extends TrainerRegistrationEvent {
  final String userId;

  const InitializeRegistration(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateBasicInfo extends TrainerRegistrationEvent {
  final String name;
  final String phone;
  final String bio;

  const UpdateBasicInfo({
    required this.name,
    required this.phone,
    required this.bio,
  });

  @override
  List<Object?> get props => [name, phone, bio];
}

class UpdateSpecialties extends TrainerRegistrationEvent {
  final List<String> specialties;
  final List<String> certifications;
  final int experienceYears;

  const UpdateSpecialties({
    required this.specialties,
    required this.certifications,
    required this.experienceYears,
  });

  @override
  List<Object?> get props => [specialties, certifications, experienceYears];
}

class UpdatePriceAndPhotos extends TrainerRegistrationEvent {
  final double hourlyRate;
  final List<String> photoUrls;

  const UpdatePriceAndPhotos({
    required this.hourlyRate,
    required this.photoUrls,
  });

  @override
  List<Object?> get props => [hourlyRate, photoUrls];
}

class UpdateAvailability extends TrainerRegistrationEvent {
  final List<TimeSlot> availableSlots;

  const UpdateAvailability(this.availableSlots);

  @override
  List<Object?> get props => [availableSlots];
}

class SelectSubscriptionTier extends TrainerRegistrationEvent {
  final SubscriptionTier tier;

  const SelectSubscriptionTier(this.tier);

  @override
  List<Object?> get props => [tier];
}

class SubmitRegistration extends TrainerRegistrationEvent {}

class ProcessPayment extends TrainerRegistrationEvent {
  final String paymentMethod;

  const ProcessPayment(this.paymentMethod);

  @override
  List<Object?> get props => [paymentMethod];
}

class GoToStep extends TrainerRegistrationEvent {
  final int step;

  const GoToStep(this.step);

  @override
  List<Object?> get props => [step];
}

class NextStep extends TrainerRegistrationEvent {}

class PreviousStep extends TrainerRegistrationEvent {}
