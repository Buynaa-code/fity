import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_spacing.dart';
import '../../../core/ui/theme/app_typography.dart';
import '../../../features/trainer_marketplace/data/repositories/trainer_repository.dart';
import '../../../features/trainer_marketplace/presentation/pages/trainer_verification_screen.dart';
import 'trainer_login_screen.dart';

class TrainerRegisterScreen extends StatefulWidget {
  const TrainerRegisterScreen({super.key});

  @override
  State<TrainerRegisterScreen> createState() => _TrainerRegisterScreenState();
}

class _TrainerRegisterScreenState extends State<TrainerRegisterScreen> {
  final _pageController = PageController();
  final _trainerRepository = TrainerRepository();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Basic info
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _step1FormKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Step 2: Professional info
  final _experienceController = TextEditingController();
  final _step2FormKey = GlobalKey<FormState>();
  final List<String> _selectedSpecialties = [];
  final List<XFile> _certificationImages = [];

  // Step 3: Profile
  final _bioController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _step3FormKey = GlobalKey<FormState>();
  XFile? _profileImage;

  // Available specialties
  final List<String> _specialties = [
    'Strength',
    'Bodybuilding',
    'Weight Loss',
    'Yoga',
    'Pilates',
    'Cardio',
    'HIIT',
    'CrossFit',
    'Boxing',
    'Kickboxing',
    'Nutrition',
    'Flexibility',
    'Endurance',
    'Functional Training',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _experienceController.dispose();
    _bioController.dispose();
    _hourlyRateController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_step1FormKey.currentState!.validate()) return;
    } else if (_currentStep == 1) {
      if (!_step2FormKey.currentState!.validate()) return;
      if (_selectedSpecialties.isEmpty) {
        _showError('Хамгийн багадаа 1 мэргэшил сонгоно уу');
        return;
      }
      if (_certificationImages.isEmpty) {
        _showError('Гэрчилгээний зураг оруулна уу');
        return;
      }
    }

    HapticFeedback.mediumImpact();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousStep() {
    HapticFeedback.lightImpact();
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }

  Future<void> _pickCertificationImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _certificationImages.add(image);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _register() async {
    if (!_step3FormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // For demo, we just use local file paths as URLs
      final certUrls = _certificationImages.map((e) => e.path).toList();

      final trainer = await _trainerRepository.registerTrainer(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        specialties: _selectedSpecialties,
        experienceYears: int.parse(_experienceController.text),
        certificationUrls: certUrls,
        bio: _bioController.text.trim(),
        hourlyRate: double.parse(_hourlyRateController.text),
        imageUrl: _profileImage?.path,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => TrainerVerificationScreen(trainer: trainer),
        ),
      );
    } catch (e) {
      _showError('Бүртгэл үүсгэхэд алдаа гарлаа: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrainerLoginScreen(),
                ),
              );
            }
          },
        ),
        title: Text(
          'Дасгалжуулагч бүртгэл',
          style: AppTypography.titleLarge.copyWith(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index == _currentStep;
          final isPast = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isPast ? AppColors.primary : AppColors.border,
                    ),
                  ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive || isPast ? AppColors.primary : AppColors.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isPast
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : Text(
                            '${index + 1}',
                            style: AppTypography.labelLarge.copyWith(
                              color: isActive ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                if (index < 2)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isPast ? AppColors.primary : AppColors.border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Үндсэн мэдээлэл',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Өөрийн мэдээллийг оруулна уу',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('Овог нэр', Icons.person_outline),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Нэрээ оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Email
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('И-мэйл', Icons.email_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'И-мэйл оруулна уу';
                }
                if (!value.contains('@')) {
                  return 'Зөв и-мэйл оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Phone
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('Утасны дугаар', Icons.phone_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Утасны дугаар оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: _inputDecoration('Нууц үг', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Нууц үг оруулна уу';
                }
                if (value.length < 6) {
                  return 'Хамгийн багадаа 6 тэмдэгт';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Confirm password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: _inputDecoration('Нууц үг баталгаажуулах', Icons.lock_outline).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
              ),
              validator: (value) {
                if (value != _passwordController.text) {
                  return 'Нууц үг таарахгүй байна';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Next button
            ElevatedButton(
              onPressed: _nextStep,
              style: _buttonStyle(),
              child: Text(
                'Үргэлжлүүлэх',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Form(
        key: _step2FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Мэргэжлийн мэдээлэл',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Туршлага болон мэргэшлээ оруулна уу',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Specialties
            Text(
              'Мэргэшил сонгох',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _specialties.map((specialty) {
                final isSelected = _selectedSpecialties.contains(specialty);
                return FilterChip(
                  label: Text(specialty),
                  selected: isSelected,
                  onSelected: (selected) {
                    HapticFeedback.selectionClick();
                    setState(() {
                      if (selected) {
                        _selectedSpecialties.add(specialty);
                      } else {
                        _selectedSpecialties.remove(specialty);
                      }
                    });
                  },
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Experience
            TextFormField(
              controller: _experienceController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Туршлага (жил)', Icons.work_history_outlined),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Туршлагаа оруулна уу';
                }
                if (int.tryParse(value) == null) {
                  return 'Зөвхөн тоо оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xl),

            // Certification images
            Text(
              'Гэрчилгээний зураг',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Мэргэжлийн гэрчилгээний зураг оруулна уу (заавал)',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  // Add button
                  GestureDetector(
                    onTap: _pickCertificationImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      margin: const EdgeInsets.only(right: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.textSecondary),
                          SizedBox(height: AppSpacing.xs),
                          Text('Нэмэх', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  // Images
                  ..._certificationImages.asMap().entries.map((entry) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: AppSpacing.md),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            image: DecorationImage(
                              image: FileImage(File(entry.value.path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: AppSpacing.md + 4,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _certificationImages.removeAt(entry.key);
                              });
                            },
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Next button
            ElevatedButton(
              onPressed: _nextStep,
              style: _buttonStyle(),
              child: Text(
                'Үргэлжлүүлэх',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Form(
        key: _step3FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Профайл',
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Өөрийгөө танилцуулна уу',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Profile image
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                        image: _profileImage != null
                            ? DecorationImage(
                                image: FileImage(File(_profileImage!.path)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profileImage == null
                          ? const Icon(
                              Icons.person_add_alt_1_outlined,
                              size: 48,
                              color: AppColors.textSecondary,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Bio
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              decoration: _inputDecoration('Танилцуулга', Icons.description_outlined).copyWith(
                hintText: 'Өөрийгөө товч танилцуулна уу...',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Танилцуулга бичнэ үү';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Hourly rate
            TextFormField(
              controller: _hourlyRateController,
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Цагийн үнэ (₮)', Icons.attach_money).copyWith(
                hintText: 'Жишээ: 50000',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Цагийн үнэ оруулна уу';
                }
                if (double.tryParse(value) == null) {
                  return 'Зөвхөн тоо оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Register button
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              style: _buttonStyle(),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Бүртгүүлэх',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Note
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Таны бүртгэл Admin-аар баталгаажуулагдах болно. Энэ нь 24-48 цагийн дотор хийгдэнэ.',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      elevation: 0,
    );
  }
}
