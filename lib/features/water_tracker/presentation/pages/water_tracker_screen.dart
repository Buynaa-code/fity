import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_typography.dart';
import '../../../../core/ui/theme/app_spacing.dart';
import '../bloc/water_bloc.dart';
import '../bloc/water_event.dart';
import '../bloc/water_state.dart';
import '../widgets/water_progress_ring.dart';
import '../widgets/water_quick_add.dart';
import '../widgets/weekly_water_chart.dart';
import '../../domain/entities/water_intake.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, state),
              SliverToBoxAdapter(
                child: _buildBody(context, state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, WaterState state) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(
          left: AppSpacing.screenPadding,
          bottom: AppSpacing.md,
        ),
        title: Text(
          'Усны хэмжээ',
          style: AppTypography.headlineLarge.copyWith(
            fontSize: 20,
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.textSecondary,
            onPressed: () => _showGoalSettings(context, state.dailySummary?.goalMl ?? 2000),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Widget _buildBody(BuildContext context, WaterState state) {
    if (state.status == WaterStatus.loading && state.dailySummary == null) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.water,
            strokeWidth: 3,
          ),
        ),
      );
    }

    final summary = state.dailySummary ??
        DailyWaterSummary(
          date: DateTime.now(),
          totalMl: 0,
          goalMl: 2000,
          intakes: const [],
        );

    return RefreshIndicator(
      onRefresh: () async {
        context.read<WaterBloc>().add(const LoadWeeklySummary());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      color: AppColors.water,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Progress Ring
            WaterProgressRing(
              progress: summary.progress,
              currentMl: summary.totalMl,
              goalMl: summary.goalMl,
              size: 220,
            ),
            const SizedBox(height: AppSpacing.md),
            // Status message
            _buildStatusMessage(summary),
            const SizedBox(height: AppSpacing.xl),
            // Quick add buttons
            WaterQuickAdd(
              onAdd: (amount) {
                HapticFeedback.mediumImpact();
                context.read<WaterBloc>().add(AddWaterIntake(amount));
                _showAddedSnackbar(context, amount);
              },
            ),
            const SizedBox(height: AppSpacing.sectionSpacing),
            // Weekly chart
            if (state.weeklySummary.isNotEmpty) ...[
              _buildSectionHeader('Долоо хоногийн тойм'),
              const SizedBox(height: AppSpacing.md),
              WeeklyWaterChart(weeklySummary: state.weeklySummary),
              const SizedBox(height: AppSpacing.sectionSpacing),
            ],
            // Today's log
            _buildSectionHeader('Өнөөдрийн бүртгэл'),
            const SizedBox(height: AppSpacing.md),
            _buildTodayLog(context, summary),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTypography.titleLarge,
      ),
    );
  }

  Widget _buildStatusMessage(DailyWaterSummary summary) {
    String message;
    Color color;
    IconData icon;

    if (summary.isGoalReached) {
      message = 'Зорилгодоо хүрлээ! 🎉';
      color = AppColors.success;
      icon = Icons.celebration;
    } else if (summary.progress >= 0.75) {
      message = 'Бараг хүрч байна! ${summary.remaining}мл үлдсэн';
      color = AppColors.water;
      icon = Icons.trending_up;
    } else if (summary.progress >= 0.5) {
      message = 'Сайн байна! ${summary.remaining}мл үлдсэн';
      color = AppColors.warning;
      icon = Icons.thumb_up_outlined;
    } else {
      message = 'Ус уухаа бүү март! ${summary.remaining}мл үлдсэн';
      color = AppColors.textTertiary;
      icon = Icons.water_drop_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppSpacing.iconSm + 2),
          const SizedBox(width: AppSpacing.sm),
          Text(
            message,
            style: AppTypography.labelMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLog(BuildContext context, DailyWaterSummary summary) {
    if (summary.intakes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.waterLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.water_drop_outlined,
                size: AppSpacing.iconXl,
                color: AppColors.water.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Өнөөдөр ус уугаагүй байна',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Дээрх товчлуурууд дээр дарж ус нэмнэ үү',
              style: AppTypography.bodySmall,
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.cardPadding,
              AppSpacing.cardPadding,
              AppSpacing.sm,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm + 2,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.waterLight,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.water_drop,
                              size: AppSpacing.iconSm,
                              color: AppColors.water,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${summary.intakes.length}',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.water,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'удаа бүртгэгдсэн',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_horiz,
                    color: AppColors.textTertiary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  onSelected: (value) {
                    if (value == 'reset') {
                      _showResetConfirmation(context, summary);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'reset',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                            size: AppSpacing.iconMd,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Бүгдийг устгах',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          // Intake list
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: summary.intakes.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: AppColors.divider,
              indent: AppSpacing.cardPadding + AppSpacing.iconLg + AppSpacing.md,
            ),
            itemBuilder: (context, index) {
              final intake = summary.intakes[summary.intakes.length - 1 - index];
              return _buildIntakeItem(context, intake);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeItem(BuildContext context, WaterIntake intake) {
    final timeStr =
        '${intake.timestamp.hour.toString().padLeft(2, '0')}:${intake.timestamp.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key(intake.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.screenPadding),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.white),
      ),
      onDismissed: (_) {
        context.read<WaterBloc>().add(RemoveWaterIntake(intake.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${intake.amountMl}мл устгагдлаа',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.textPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding,
          vertical: AppSpacing.sm + 4,
        ),
        child: Row(
          children: [
            Container(
              width: AppSpacing.iconLg + 8,
              height: AppSpacing.iconLg + 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.water.withValues(alpha: 0.2),
                    AppColors.water.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(
                Icons.water_drop_rounded,
                color: AppColors.water,
                size: AppSpacing.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${intake.amountMl}мл',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeStr,
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_left,
              color: AppColors.textTertiary,
              size: AppSpacing.iconMd,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddedSnackbar(BuildContext context, int amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                Icons.check_rounded,
                color: AppColors.white,
                size: AppSpacing.iconSm,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '+$amountмл нэмэгдлээ',
              style: AppTypography.labelLarge.copyWith(color: AppColors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.water,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        duration: const Duration(seconds: 2),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
        ),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, DailyWaterSummary summary) {
    final previousIntakes = List<WaterIntake>.from(summary.intakes);
    final previousTotalMl = summary.totalMl;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) => Container(
        padding: const EdgeInsets.all(AppSpacing.sectionSpacing),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXxl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: AppSpacing.iconLg,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Бүртгэлийг устгах',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Өнөөдрийн бүх усны бүртгэлийг устгах уу?',
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Summary card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.waterLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.water_drop,
                    color: AppColors.water,
                    size: AppSpacing.iconLg,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${summary.totalMl} мл',
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.water,
                        ),
                      ),
                      Text(
                        '${summary.intakes.length} удаа бүртгэгдсэн',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.water,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                    ),
                    child: Text(
                      'Болих',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      HapticFeedback.mediumImpact();
                      context.read<WaterBloc>().add(const ResetDailyWater());
                      _showResetUndoSnackbar(context, previousIntakes, previousTotalMl);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Устгах',
                      style: AppTypography.labelLarge.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showResetUndoSnackbar(
    BuildContext context,
    List<WaterIntake> previousIntakes,
    int previousTotalMl,
  ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.white, size: AppSpacing.iconMd),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                '$previousTotalMlмл устгагдлаа',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        duration: const Duration(seconds: 5),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.1,
          left: AppSpacing.screenPadding,
          right: AppSpacing.screenPadding,
        ),
        action: SnackBarAction(
          label: 'Буцаах',
          textColor: AppColors.water,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.read<WaterBloc>().add(UndoResetDailyWater(
              previousIntakes: previousIntakes,
              previousTotalMl: previousTotalMl,
            ));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.replay_rounded, color: AppColors.white, size: AppSpacing.iconMd),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Бүртгэл сэргээгдлээ',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showGoalSettings(BuildContext context, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());
    int selectedGoal = currentGoal;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.sectionSpacing,
            AppSpacing.sectionSpacing,
            AppSpacing.sectionSpacing,
            MediaQuery.of(context).viewInsets.bottom + AppSpacing.sectionSpacing,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXxl),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Өдрийн зорилго',
                style: AppTypography.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Өдөрт уух ёстой усны хэмжээгээ тохируулна уу',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Input field
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: AppTypography.numberSmall,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null) {
                    setModalState(() => selectedGoal = parsed);
                  }
                },
                decoration: InputDecoration(
                  suffixText: 'мл',
                  suffixStyle: AppTypography.titleLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    borderSide: BorderSide(color: AppColors.water, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Quick presets
              Row(
                children: [1500, 2000, 2500, 3000].map((goal) {
                  final isSelected = selectedGoal == goal;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: goal == 3000 ? 0 : AppSpacing.sm,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setModalState(() => selectedGoal = goal);
                          controller.text = goal.toString();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.sm + 2,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.water : AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(
                              color: isSelected ? AppColors.water : AppColors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '${(goal / 1000).toStringAsFixed(1)}L',
                            style: AppTypography.labelMedium.copyWith(
                              color: isSelected ? AppColors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final goal = int.tryParse(controller.text);
                    if (goal != null && goal > 0) {
                      HapticFeedback.mediumImpact();
                      context.read<WaterBloc>().add(UpdateDailyGoal(goal));
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.water,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Хадгалах',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
