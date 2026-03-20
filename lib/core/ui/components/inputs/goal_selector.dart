import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_typography.dart';

/// Goal option for onboarding
class GoalOption {
  final String id;
  final String icon;
  final String title;
  final String description;
  final Color color;

  const GoalOption({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    this.color = AppColors.primary,
  });
}

/// Goal selector grid for onboarding
class GoalSelector extends StatelessWidget {
  final List<GoalOption> options;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final int crossAxisCount;

  const GoalSelector({
    super.key,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.0,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = option.id == selectedId;

        return _GoalCard(
          option: option,
          isSelected: isSelected,
          onTap: () {
            HapticFeedback.selectionClick();
            onSelected(option.id);
          },
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final GoalOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? option.color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? option.color.withValues(alpha: 0.15)
                    : AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  option.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Title
            Text(
              option.title,
              style: AppTypography.titleMedium.copyWith(
                color: isSelected ? option.color : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Default fitness goals
class FitnessGoals {
  static const List<GoalOption> defaults = [
    GoalOption(
      id: 'build_muscle',
      icon: '💪',
      title: 'Булчин хөгжүүлэх',
      description: 'Хүч чадал нэмэгдүүлэх',
      color: AppColors.strength,
    ),
    GoalOption(
      id: 'lose_weight',
      icon: '🏃',
      title: 'Жин хасах',
      description: 'Өөх тос шатаах',
      color: AppColors.cardio,
    ),
    GoalOption(
      id: 'stay_active',
      icon: '🧘',
      title: 'Идэвхтэй байх',
      description: 'Эрүүл амьдралын хэв маяг',
      color: AppColors.flexibility,
    ),
    GoalOption(
      id: 'get_healthy',
      icon: '❤️',
      title: 'Эрүүл болох',
      description: 'Ерөнхий эрүүл мэнд',
      color: AppColors.success,
    ),
  ];
}
