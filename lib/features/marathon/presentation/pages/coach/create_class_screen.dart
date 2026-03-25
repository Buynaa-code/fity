import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/branding/brand_config.dart';
import '../../../../user/presentation/bloc/user_bloc.dart';
import '../../bloc/marathon_bloc.dart';
import '../../bloc/marathon_event.dart';
import '../../bloc/marathon_state.dart';

class CreateClassScreen extends StatefulWidget {
  const CreateClassScreen({super.key});

  @override
  State<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends State<CreateClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '20');

  TimeOfDay _startTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 8, minute: 0);
  // ignore: prefer_final_fields - this is mutated in setState
  List<int> _selectedWeekdays = [1, 2, 3, 4, 5];

  final List<Map<String, dynamic>> _weekdays = [
    {'day': 1, 'name': 'Да', 'fullName': 'Даваа'},
    {'day': 2, 'name': 'Мя', 'fullName': 'Мягмар'},
    {'day': 3, 'name': 'Лх', 'fullName': 'Лхагва'},
    {'day': 4, 'name': 'Пү', 'fullName': 'Пүрэв'},
    {'day': 5, 'name': 'Ба', 'fullName': 'Баасан'},
    {'day': 6, 'name': 'Бя', 'fullName': 'Бямба'},
    {'day': 7, 'name': 'Ня', 'fullName': 'Ням'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarathonBloc, MarathonState>(
      listener: (context, state) {
        if (state.status == MarathonStatus.success) {
          Navigator.pop(context);
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: BrandColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == MarathonStatus.loading;

        return Scaffold(
          backgroundColor: BrandColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BrandColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: BrandColors.textPrimary),
              ),
            ),
            title: const Text(
              'Шинэ анги үүсгэх',
              style: TextStyle(
                color: BrandColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle('Ангийн мэдээлэл'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _titleController,
                  label: 'Ангийн нэр',
                  hint: 'Жишээ: Өглөөний марафон бэлтгэл',
                  icon: Icons.class_rounded,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ангийн нэр оруулна уу';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Тайлбар (заавал биш)',
                  hint: 'Ангийн талаар дэлгэрэнгүй мэдээлэл...',
                  icon: Icons.description_rounded,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Цагийн хуваарь'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimePicker(
                        label: 'Эхлэх цаг',
                        time: _startTime,
                        onTap: () => _selectTime(true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTimePicker(
                        label: 'Дуусах цаг',
                        time: _endTime,
                        onTap: () => _selectTime(false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildSectionTitle('Долоо хоногийн өдрүүд'),
                const SizedBox(height: 12),
                _buildWeekdaySelector(),
                const SizedBox(height: 24),
                _buildSectionTitle('Оролцогчдын тоо'),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: _maxParticipantsController,
                  label: 'Дээд хязгаар',
                  hint: '20',
                  icon: Icons.people_rounded,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Оролцогчдын тоо оруулна уу';
                    }
                    final number = int.tryParse(value);
                    if (number == null || number < 1) {
                      return 'Зөв тоо оруулна уу';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                _buildCreateButton(isLoading),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: BrandColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: BrandShadows.small,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: BrandColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: BrandShadows.small,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: BrandColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: BrandColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTimeOfDay(time),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdaySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: BrandShadows.small,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _weekdays.map((weekday) {
          final isSelected = _selectedWeekdays.contains(weekday['day']);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                if (isSelected) {
                  _selectedWeekdays.remove(weekday['day']);
                } else {
                  _selectedWeekdays.add(weekday['day']);
                  _selectedWeekdays.sort();
                }
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? BrandColors.primary
                    : BrandColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  weekday['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : BrandColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCreateButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _createClass,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: BrandGradients.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: BrandShadows.primaryGlow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            else ...[
              const Icon(Icons.add_rounded, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'Анги үүсгэх',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(bool isStartTime) async {
    final initialTime = isStartTime ? _startTime : _endTime;
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: BrandColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _createClass() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedWeekdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дор хаяж нэг өдөр сонгоно уу'),
          backgroundColor: BrandColors.error,
        ),
      );
      return;
    }

    final userState = context.read<UserBloc>().state;

    // Dev mode: use fallback values if not logged in
    final coachId = userState.userId ?? 'dev_coach_${DateTime.now().millisecondsSinceEpoch}';
    final coachName = userState.userName.isNotEmpty ? userState.userName : 'Багш';

    HapticFeedback.mediumImpact();
    context.read<MarathonBloc>().add(CreateClass(
      coachId: coachId,
      coachName: coachName,
      coachPhotoUrl: userState.photoUrl,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      startTime: _formatTimeOfDay(_startTime),
      endTime: _formatTimeOfDay(_endTime),
      maxParticipants: int.parse(_maxParticipantsController.text),
      weekdays: _selectedWeekdays,
    ));
  }
}
