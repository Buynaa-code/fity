import 'package:equatable/equatable.dart';
import '../../../domain/entities/trainer.dart';
import '../../../domain/entities/trainer_subscription.dart';

enum RegistrationStep {
  basicInfo,
  specialties,
  priceAndPhotos,
  availability,
  preview,
  subscription,
}

class TrainerRegistrationState extends Equatable {
  final String? userId;
  final RegistrationStep currentStep;
  final bool isLoading;
  final String? error;

  // Step 1: Basic Info
  final String name;
  final String phone;
  final String email;
  final String bio;
  final String location;
  final String? profileImagePath;

  // Step 2: Specialties
  final List<String> specialties;
  final List<String> certifications;
  final int experienceYears;

  // Step 3: Price & Photos
  final double hourlyRate;
  final List<String> photoUrls;

  // Step 4: Availability
  final List<TimeSlot> availableSlots;

  // Step 5: Subscription
  final SubscriptionTier? selectedTier;
  final bool isRegistered;
  final Trainer? registeredTrainer;
  final TrainerSubscription? subscription;

  const TrainerRegistrationState({
    this.userId,
    this.currentStep = RegistrationStep.basicInfo,
    this.isLoading = false,
    this.error,
    this.name = '',
    this.phone = '',
    this.email = '',
    this.bio = '',
    this.location = '',
    this.profileImagePath,
    this.specialties = const [],
    this.certifications = const [],
    this.experienceYears = 0,
    this.hourlyRate = 0,
    this.photoUrls = const [],
    this.availableSlots = const [],
    this.selectedTier,
    this.isRegistered = false,
    this.registeredTrainer,
    this.subscription,
  });

  bool get isBasicInfoValid =>
      name.isNotEmpty &&
      phone.isNotEmpty &&
      email.isNotEmpty &&
      bio.isNotEmpty &&
      location.isNotEmpty;

  bool get isSpecialtiesValid =>
      specialties.isNotEmpty && experienceYears > 0;

  bool get isPriceValid => hourlyRate > 0;

  bool get isAvailabilityValid => availableSlots.isNotEmpty;

  bool get canProceed {
    switch (currentStep) {
      case RegistrationStep.basicInfo:
        return isBasicInfoValid;
      case RegistrationStep.specialties:
        return isSpecialtiesValid;
      case RegistrationStep.priceAndPhotos:
        return isPriceValid;
      case RegistrationStep.availability:
        return isAvailabilityValid;
      case RegistrationStep.preview:
        return true;
      case RegistrationStep.subscription:
        return selectedTier != null;
    }
  }

  int get stepIndex => currentStep.index;

  int get totalSteps => RegistrationStep.values.length;

  double get progress => (stepIndex + 1) / totalSteps;

  TrainerRegistrationState copyWith({
    String? userId,
    RegistrationStep? currentStep,
    bool? isLoading,
    String? error,
    String? name,
    String? phone,
    String? bio,
    List<String>? specialties,
    List<String>? certifications,
    int? experienceYears,
    double? hourlyRate,
    List<String>? photoUrls,
    List<TimeSlot>? availableSlots,
    SubscriptionTier? selectedTier,
    bool? isRegistered,
    Trainer? registeredTrainer,
    TrainerSubscription? subscription,
  }) {
    return TrainerRegistrationState(
      userId: userId ?? this.userId,
      currentStep: currentStep ?? this.currentStep,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      specialties: specialties ?? this.specialties,
      certifications: certifications ?? this.certifications,
      experienceYears: experienceYears ?? this.experienceYears,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      photoUrls: photoUrls ?? this.photoUrls,
      availableSlots: availableSlots ?? this.availableSlots,
      selectedTier: selectedTier ?? this.selectedTier,
      isRegistered: isRegistered ?? this.isRegistered,
      registeredTrainer: registeredTrainer ?? this.registeredTrainer,
      subscription: subscription ?? this.subscription,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        currentStep,
        isLoading,
        error,
        name,
        phone,
        bio,
        specialties,
        certifications,
        experienceYears,
        hourlyRate,
        photoUrls,
        availableSlots,
        selectedTier,
        isRegistered,
        registeredTrainer,
        subscription,
      ];
}
