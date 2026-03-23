import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../../core/services/gym_occupancy_service.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_typography.dart';
import '../../../../core/ui/theme/app_spacing.dart';

class GymOccupancyCard extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onTap;

  const GymOccupancyCard({
    super.key,
    required this.isDarkMode,
    this.onTap,
  });

  @override
  State<GymOccupancyCard> createState() => _GymOccupancyCardState();
}

class _GymOccupancyCardState extends State<GymOccupancyCard>
    with SingleTickerProviderStateMixin {
  final _service = GymOccupancyService.instance;
  StreamSubscription<GymOccupancy>? _subscription;
  GymOccupancy? _occupancy;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _service.startListening();
    _subscription = _service.occupancyStream.listen((occupancy) {
      if (mounted) {
        setState(() => _occupancy = occupancy);
      }
    });

    // Get initial data
    _occupancy = _service.currentOccupancy;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Color _getOccupancyColor(OccupancyLevel level) {
    switch (level) {
      case OccupancyLevel.low:
        return AppColors.success;
      case OccupancyLevel.moderate:
        return AppColors.warning;
      case OccupancyLevel.busy:
        return AppColors.primary;
      case OccupancyLevel.full:
        return AppColors.error;
    }
  }

  IconData _getOccupancyIcon(OccupancyLevel level) {
    switch (level) {
      case OccupancyLevel.low:
        return Icons.check_circle_rounded;
      case OccupancyLevel.moderate:
        return Icons.remove_circle_rounded;
      case OccupancyLevel.busy:
        return Icons.warning_rounded;
      case OccupancyLevel.full:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_occupancy == null) {
      return _buildLoadingState();
    }

    final color = _getOccupancyColor(_occupancy!.level);
    final bgColor = widget.isDarkMode ? AppColors.darkSurface : AppColors.surface;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
        _showDetailSheet(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                // Animated status indicator
                ScaleTransition(
                  scale: _occupancy!.level == OccupancyLevel.busy ||
                          _occupancy!.level == OccupancyLevel.full
                      ? _pulseAnimation
                      : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(
                      _getOccupancyIcon(_occupancy!.level),
                      color: color,
                      size: AppSpacing.iconMd,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Заалны дүүргэлт',
                            style: AppTypography.titleMedium.copyWith(
                              color: widget.isDarkMode
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'LIVE',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _occupancy!.timeSinceUpdate,
                        style: AppTypography.bodySmall.copyWith(
                          color: widget.isDarkMode
                              ? AppColors.darkTextSecondary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Percentage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_occupancy!.percentageInt}%',
                      style: AppTypography.numberSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _occupancy!.levelText,
                      style: AppTypography.labelSmall.copyWith(
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: Stack(
                children: [
                  // Background
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? AppColors.darkSurfaceVariant
                          : AppColors.surfaceVariant,
                    ),
                  ),
                  // Progress
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    height: 10,
                    width: MediaQuery.of(context).size.width *
                        0.85 *
                        _occupancy!.percentage,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color,
                          color.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Current count
                Row(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: AppSpacing.iconSm,
                      color: widget.isDarkMode
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${_occupancy!.currentCount}',
                            style: AppTypography.titleMedium.copyWith(
                              color: widget.isDarkMode
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${_occupancy!.maxCapacity} хүн',
                            style: AppTypography.bodySmall.copyWith(
                              color: widget.isDarkMode
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Recommendation
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 14,
                        color: color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _occupancy!.recommendation,
                        style: AppTypography.labelSmall.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: widget.isDarkMode ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            'Дүүргэлт ачаалж байна...',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    final color = _getOccupancyColor(_occupancy!.level);
    final peakHours = _service.getPeakHoursPrediction();
    final bestTime = _service.getBestTimeToVisit();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: widget.isDarkMode ? AppColors.darkSurface : AppColors.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusXxl),
            ),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.sectionSpacing),
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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      color: color,
                      size: AppSpacing.iconLg,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _occupancy!.gymName,
                          style: AppTypography.headlineMedium.copyWith(
                            color: widget.isDarkMode
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_occupancy!.levelText} - ${_occupancy!.percentageInt}%',
                              style: AppTypography.titleMedium.copyWith(
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Main stats
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: widget.isDarkMode
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        Icons.people_rounded,
                        '${_occupancy!.currentCount}',
                        'Одоогийн',
                        color,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        Icons.event_available_rounded,
                        '${_occupancy!.availableSpots}',
                        'Сул зай',
                        AppColors.success,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 50,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _buildStatItem(
                        Icons.groups_rounded,
                        '${_occupancy!.maxCapacity}',
                        'Багтаамж',
                        AppColors.info,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Area breakdown
              if (_occupancy!.areaBreakdown != null) ...[
                Text(
                  'Бүсээр',
                  style: AppTypography.titleLarge.copyWith(
                    color: widget.isDarkMode
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ..._occupancy!.areaBreakdown!.entries.map((entry) {
                  final areaPercentage = entry.value / _occupancy!.currentCount;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildAreaRow(entry.key, entry.value, areaPercentage),
                  );
                }),
                const SizedBox(height: AppSpacing.lg),
              ],
              // Best time suggestion
              Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withValues(alpha: 0.15),
                      AppColors.success.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(
                        Icons.schedule_rounded,
                        color: AppColors.success,
                        size: AppSpacing.iconMd,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Хамгийн тохиромжтой цаг',
                            style: AppTypography.labelMedium.copyWith(
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            bestTime,
                            style: AppTypography.titleLarge.copyWith(
                              color: widget.isDarkMode
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Peak hours
              Text(
                'Өнөөдрийн таамаг',
                style: AppTypography.titleLarge.copyWith(
                  color: widget.isDarkMode
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: peakHours.map((hour) {
                    final level = hour['level'] as double;
                    final barColor = level > 0.8
                        ? AppColors.error
                        : level > 0.6
                            ? AppColors.warning
                            : AppColors.success;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 60 * level,
                              decoration: BoxDecoration(
                                color: barColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              hour['hour'] as String,
                              style: AppTypography.labelSmall.copyWith(
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.numberSmall.copyWith(
            color: widget.isDarkMode
                ? AppColors.darkTextPrimary
                : AppColors.textPrimary,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: widget.isDarkMode
                ? AppColors.darkTextSecondary
                : AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildAreaRow(String name, int count, double percentage) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            name,
            style: AppTypography.bodyMedium.copyWith(
              color: widget.isDarkMode
                  ? AppColors.darkTextPrimary
                  : AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: widget.isDarkMode
                  ? AppColors.darkBorder
                  : AppColors.border,
              color: AppColors.primary,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 40,
          child: Text(
            '$count',
            style: AppTypography.labelMedium.copyWith(
              color: widget.isDarkMode
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
