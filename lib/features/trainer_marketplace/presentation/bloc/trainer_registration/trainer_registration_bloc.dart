import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/trainer_repository.dart';
import 'trainer_registration_event.dart';
import 'trainer_registration_state.dart';

class TrainerRegistrationBloc
    extends Bloc<TrainerRegistrationEvent, TrainerRegistrationState> {
  final TrainerRepository repository;

  TrainerRegistrationBloc({required this.repository})
      : super(const TrainerRegistrationState()) {
    on<InitializeRegistration>(_onInitialize);
    on<UpdateBasicInfo>(_onUpdateBasicInfo);
    on<UpdateSpecialties>(_onUpdateSpecialties);
    on<UpdatePriceAndPhotos>(_onUpdatePriceAndPhotos);
    on<UpdateAvailability>(_onUpdateAvailability);
    on<SelectSubscriptionTier>(_onSelectSubscriptionTier);
    on<SubmitRegistration>(_onSubmitRegistration);
    on<ProcessPayment>(_onProcessPayment);
    on<GoToStep>(_onGoToStep);
    on<NextStep>(_onNextStep);
    on<PreviousStep>(_onPreviousStep);
  }

  void _onInitialize(
    InitializeRegistration event,
    Emitter<TrainerRegistrationState> emit,
  ) {
    emit(state.copyWith(userId: event.userId));
  }

  void _onUpdateBasicInfo(
    UpdateBasicInfo event,
    Emitter<TrainerRegistrationState> emit,
  ) {
    emit(state.copyWith(
      name: event.name,
      phone: event.phone,
      bio: event.bio,
    ));
  }

  void _onUpdateSpecialties(
    UpdateSpecialties event,
    Emitter<TrainerRegistrationState> emit,
  ) {
    emit(state.copyWith(
      specialties: event.specialties,
      certifications: event.certifications,
      experienceYears: event.experienceYears,
    ));
  }

  void _onUpdatePriceAndPhotos(
    UpdatePriceAndPhotos event,
    Emitter<TrainerRegistrationState> emit,
  ) {
    emit(state.copyWith(
      hourlyRate: event.hourlyRate,
      photoUrls: event.photoUrls,
    ));
  }

  void _onUpdateAvailability(
    UpdateAvailability event,
    Emitter<TrainerRegistrationState> emit,
  ) {
    emit(state.copyWith(availableSlots: event.availableSlots));
  }

  void _onSelectSubscriptionTier(
    SelectSubscriptionTier event,
    Emitter<TrainerRegistrationState> emit,
  ) {
    emit(state.copyWith(selectedTier: event.tier));
  }

  Future<void> _onSubmitRegistration(
    SubmitRegistration event,
    Emitter<TrainerRegistrationState> emit,
  ) async {
    if (state.userId == null) {
      emit(state.copyWith(error: 'Хэрэглэгчийн мэдээлэл олдсонгүй'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final trainer = await repository.createTrainer(
        userId: state.userId!,
        name: state.name,
        bio: state.bio,
        phone: state.phone,
        specialties: state.specialties,
        hourlyRate: state.hourlyRate,
        experienceYears: state.experienceYears,
        certifications: state.certifications,
        availableSlots: state.availableSlots,
        photoUrls: state.photoUrls,
      );

      emit(state.copyWith(
        isLoading: false,
        registeredTrainer: trainer,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Бүртгэл амжилтгүй: ${e.toString()}',
      ));
    }
  }

  Future<void> _onProcessPayment(
    ProcessPayment event,
    Emitter<TrainerRegistrationState> emit,
  ) async {
    if (state.registeredTrainer == null || state.selectedTier == null) {
      emit(state.copyWith(error: 'Дасгалжуулагч эсвэл subscription сонгогдоогүй'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 1));

      final subscription = await repository.createSubscription(
        trainerId: state.registeredTrainer!.id,
        tier: state.selectedTier!,
      );

      emit(state.copyWith(
        isLoading: false,
        isRegistered: true,
        subscription: subscription,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Төлбөр амжилтгүй: ${e.toString()}',
      ));
    }
  }

  void _onGoToStep(
    GoToStep event,
    Emitter<TrainerRegistrationState> emit,
  ) {
    if (event.step >= 0 && event.step < RegistrationStep.values.length) {
      emit(state.copyWith(
        currentStep: RegistrationStep.values[event.step],
      ));
    }
  }

  void _onNextStep(
    NextStep event,
    Emitter<TrainerRegistrationState> emit,
  ) {
    final nextIndex = state.stepIndex + 1;
    if (nextIndex < RegistrationStep.values.length) {
      emit(state.copyWith(
        currentStep: RegistrationStep.values[nextIndex],
      ));
    }
  }

  void _onPreviousStep(
    PreviousStep event,
    Emitter<TrainerRegistrationState> emit,
  ) {
    final prevIndex = state.stepIndex - 1;
    if (prevIndex >= 0) {
      emit(state.copyWith(
        currentStep: RegistrationStep.values[prevIndex],
      ));
    }
  }
}
