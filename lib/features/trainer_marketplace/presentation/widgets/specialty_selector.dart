import 'package:flutter/material.dart';

class SpecialtySelector extends StatelessWidget {
  final List<String> selectedSpecialties;
  final ValueChanged<List<String>> onChanged;

  const SpecialtySelector({
    super.key,
    required this.selectedSpecialties,
    required this.onChanged,
  });

  static const List<String> availableSpecialties = [
    'Strength',
    'Bodybuilding',
    'Weight Loss',
    'Yoga',
    'Pilates',
    'HIIT',
    'Cardio',
    'Flexibility',
    'CrossFit',
    'Boxing',
    'Kickboxing',
    'Nutrition',
    'Endurance',
    'Functional Training',
    'Rehabilitation',
  ];

  static const Map<String, String> specialtyTranslations = {
    'Strength': 'Хүч чадал',
    'Bodybuilding': 'Бодибилдинг',
    'Weight Loss': 'Жин хасах',
    'Yoga': 'Йога',
    'Pilates': 'Пилатес',
    'HIIT': 'HIIT',
    'Cardio': 'Кардио',
    'Flexibility': 'Уян хатан',
    'CrossFit': 'Кроссфит',
    'Boxing': 'Бокс',
    'Kickboxing': 'Кикбоксинг',
    'Nutrition': 'Хоол тэжээл',
    'Endurance': 'Тэсвэр',
    'Functional Training': 'Функциональ',
    'Rehabilitation': 'Нөхөн сэргээх',
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Мэргэшил сонгох',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Дор хаяж 1 мэргэшил сонгоно уу',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSpecialties.map((specialty) {
            final isSelected = selectedSpecialties.contains(specialty);
            return FilterChip(
              label: Text(specialtyTranslations[specialty] ?? specialty),
              selected: isSelected,
              onSelected: (selected) {
                final newList = List<String>.from(selectedSpecialties);
                if (selected) {
                  newList.add(specialty);
                } else {
                  newList.remove(specialty);
                }
                onChanged(newList);
              },
              selectedColor: const Color(0xFFF72928).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFFF72928),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFFF72928) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFFF72928)
                      : Colors.grey[300]!,
                ),
              ),
              backgroundColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }
}
