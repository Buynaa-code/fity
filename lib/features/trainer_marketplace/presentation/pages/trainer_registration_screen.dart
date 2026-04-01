import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/trainer_repository.dart';
import '../../domain/entities/trainer.dart';
import '../../domain/entities/trainer_subscription.dart';
import '../bloc/trainer_registration/trainer_registration_bloc.dart';
import '../bloc/trainer_registration/trainer_registration_event.dart';
import '../bloc/trainer_registration/trainer_registration_state.dart';
import '../widgets/specialty_selector.dart';
import '../widgets/certification_input.dart';
import '../widgets/availability_picker.dart';
import '../widgets/photo_gallery_picker.dart';
import '../widgets/subscription_plan_card.dart';

class TrainerRegistrationScreen extends StatelessWidget {
  final String userId;

  const TrainerRegistrationScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrainerRegistrationBloc(
        repository: TrainerRepository(),
      )..add(InitializeRegistration(userId)),
      child: const _TrainerRegistrationView(),
    );
  }
}

class _TrainerRegistrationView extends StatelessWidget {
  const _TrainerRegistrationView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrainerRegistrationBloc, TrainerRegistrationState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state.isRegistered) {
          _showSuccessDialog(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Дасгалжуулагч бүртгэл'),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          body: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(state),
              // Content
              Expanded(
                child: _buildStepContent(context, state),
              ),
              // Navigation buttons
              _buildNavigationButtons(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressIndicator(TrainerRegistrationState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: List.generate(state.totalSteps, (index) {
              final isCompleted = index < state.stepIndex;
              final isCurrent = index == state.stepIndex;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < state.totalSteps - 1 ? 8 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? const Color(0xFFF72928)
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            _getStepTitle(state.currentStep),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Алхам ${state.stepIndex + 1}/${state.totalSteps}',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.basicInfo:
        return 'Үндсэн мэдээлэл';
      case RegistrationStep.specialties:
        return 'Мэргэшил';
      case RegistrationStep.priceAndPhotos:
        return 'Үнэ & Зураг';
      case RegistrationStep.availability:
        return 'Цагийн хуваарь';
      case RegistrationStep.subscription:
        return 'Subscription сонгох';
    }
  }

  Widget _buildStepContent(BuildContext context, TrainerRegistrationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: switch (state.currentStep) {
        RegistrationStep.basicInfo => _BasicInfoStep(state: state),
        RegistrationStep.specialties => _SpecialtiesStep(state: state),
        RegistrationStep.priceAndPhotos => _PriceAndPhotosStep(state: state),
        RegistrationStep.availability => _AvailabilityStep(state: state),
        RegistrationStep.subscription => _SubscriptionStep(state: state),
      },
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    TrainerRegistrationState state,
  ) {
    final bloc = context.read<TrainerRegistrationBloc>();
    final isFirstStep = state.stepIndex == 0;
    final isLastStep = state.currentStep == RegistrationStep.subscription;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (!isFirstStep)
            Expanded(
              child: OutlinedButton(
                onPressed: state.isLoading
                    ? null
                    : () => bloc.add(PreviousStep()),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Буцах'),
              ),
            ),
          if (!isFirstStep) const SizedBox(width: 12),
          Expanded(
            flex: isFirstStep ? 1 : 1,
            child: ElevatedButton(
              onPressed: state.isLoading || !state.canProceed
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      if (isLastStep) {
                        // First submit registration, then process payment
                        if (state.registeredTrainer == null) {
                          bloc.add(SubmitRegistration());
                        } else {
                          bloc.add(const ProcessPayment('card'));
                        }
                      } else {
                        bloc.add(NextStep());
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF72928),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: state.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLastStep
                          ? (state.registeredTrainer == null
                              ? 'Бүртгүүлэх'
                              : 'Төлбөр төлөх')
                          : 'Үргэлжлүүлэх',
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Бүртгэл амжилттай!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Таны дасгалжуулагчийн профайл идэвхжлээ. Одоо гишүүд танаас захиалга өгөх боломжтой болсон.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF72928),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Дуусгах'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BasicInfoStep extends StatefulWidget {
  final TrainerRegistrationState state;

  const _BasicInfoStep({required this.state});

  @override
  State<_BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<_BasicInfoStep> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.state.name);
    _phoneController = TextEditingController(text: widget.state.phone);
    _bioController = TextEditingController(text: widget.state.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _updateBloc() {
    context.read<TrainerRegistrationBloc>().add(UpdateBasicInfo(
          name: _nameController.text,
          phone: _phoneController.text,
          bio: _bioController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Нэр',
          hint: 'Таны бүтэн нэр',
          icon: Icons.person_outline,
          onChanged: (_) => _updateBloc(),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _phoneController,
          label: 'Утасны дугаар',
          hint: '9911 1234',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          onChanged: (_) => _updateBloc(),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _bioController,
          label: 'Танилцуулга',
          hint: 'Өөрийнхөө тухай товч бичнэ үү...',
          icon: Icons.edit_note,
          maxLines: 4,
          onChanged: (_) => _updateBloc(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: maxLines == 1 ? Icon(icon, color: Colors.grey[500]) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF72928), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecialtiesStep extends StatefulWidget {
  final TrainerRegistrationState state;

  const _SpecialtiesStep({required this.state});

  @override
  State<_SpecialtiesStep> createState() => _SpecialtiesStepState();
}

class _SpecialtiesStepState extends State<_SpecialtiesStep> {
  late List<String> _specialties;
  late List<String> _certifications;
  late int _experienceYears;

  @override
  void initState() {
    super.initState();
    _specialties = List.from(widget.state.specialties);
    _certifications = List.from(widget.state.certifications);
    _experienceYears = widget.state.experienceYears;
  }

  void _updateBloc() {
    context.read<TrainerRegistrationBloc>().add(UpdateSpecialties(
          specialties: _specialties,
          certifications: _certifications,
          experienceYears: _experienceYears,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpecialtySelector(
          selectedSpecialties: _specialties,
          onChanged: (specialties) {
            setState(() => _specialties = specialties);
            _updateBloc();
          },
        ),
        const SizedBox(height: 32),
        CertificationInput(
          certifications: _certifications,
          onChanged: (certifications) {
            setState(() => _certifications = certifications);
            _updateBloc();
          },
        ),
        const SizedBox(height: 32),
        Text(
          'Туршлага (жил)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton.filled(
              onPressed: _experienceYears > 0
                  ? () {
                      setState(() => _experienceYears--);
                      _updateBloc();
                    }
                  : null,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '$_experienceYears жил',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 16),
            IconButton.filled(
              onPressed: () {
                setState(() => _experienceYears++);
                _updateBloc();
              },
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF72928),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceAndPhotosStep extends StatefulWidget {
  final TrainerRegistrationState state;

  const _PriceAndPhotosStep({required this.state});

  @override
  State<_PriceAndPhotosStep> createState() => _PriceAndPhotosStepState();
}

class _PriceAndPhotosStepState extends State<_PriceAndPhotosStep> {
  late TextEditingController _priceController;
  late List<String> _photoUrls;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.state.hourlyRate > 0
          ? widget.state.hourlyRate.toInt().toString()
          : '',
    );
    _photoUrls = List.from(widget.state.photoUrls);
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void _updateBloc() {
    final price = double.tryParse(_priceController.text) ?? 0;
    context.read<TrainerRegistrationBloc>().add(UpdatePriceAndPhotos(
          hourlyRate: price,
          photoUrls: _photoUrls,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Цагийн үнэ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          onChanged: (_) => _updateBloc(),
          decoration: InputDecoration(
            hintText: '50000',
            prefixText: '₮ ',
            suffixText: '/цаг',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFF72928), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Санал болгох үнийн хязгаар: ₮30,000 - ₮100,000/цаг',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 32),
        PhotoGalleryPicker(
          photoUrls: _photoUrls,
          onChanged: (urls) {
            setState(() => _photoUrls = urls);
            _updateBloc();
          },
        ),
      ],
    );
  }
}

class _AvailabilityStep extends StatefulWidget {
  final TrainerRegistrationState state;

  const _AvailabilityStep({required this.state});

  @override
  State<_AvailabilityStep> createState() => _AvailabilityStepState();
}

class _AvailabilityStepState extends State<_AvailabilityStep> {
  late List<TimeSlot> _availableSlots;

  @override
  void initState() {
    super.initState();
    _availableSlots = List.from(widget.state.availableSlots);
  }

  @override
  Widget build(BuildContext context) {
    return AvailabilityPicker(
      selectedSlots: _availableSlots,
      onChanged: (slots) {
        setState(() => _availableSlots = slots);
        context.read<TrainerRegistrationBloc>().add(UpdateAvailability(slots));
      },
    );
  }
}

class _SubscriptionStep extends StatelessWidget {
  final TrainerRegistrationState state;

  const _SubscriptionStep({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Subscription сонгоно уу',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Subscription төлсний дараа танийг marketplace-д нэн даруй харагдах болно',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        ...SubscriptionTier.values.reversed.map((tier) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SubscriptionPlanCard(
                tier: tier,
                isSelected: state.selectedTier == tier,
                onTap: () {
                  context
                      .read<TrainerRegistrationBloc>()
                      .add(SelectSubscriptionTier(tier));
                },
              ),
            )),
      ],
    );
  }
}
