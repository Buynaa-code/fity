import 'package:flutter/material.dart';
import '../../../core/services/checkin_service.dart';
import '../../../core/ui/theme/app_colors.dart';
import '../../../core/ui/theme/app_spacing.dart';
import '../../../core/ui/theme/app_typography.dart';

class CheckinsListScreen extends StatefulWidget {
  const CheckinsListScreen({super.key});

  @override
  State<CheckinsListScreen> createState() => _CheckinsListScreenState();
}

class _CheckinsListScreenState extends State<CheckinsListScreen> {
  List<CheckInRecord> _todayCheckIns = [];
  bool _isLoading = true;
  int _activeCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCheckIns();
  }

  Future<void> _loadCheckIns() async {
    setState(() => _isLoading = true);

    try {
      final history = await CheckInService.instance.getCheckInHistory(limit: 100);
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final todayCheckIns = history.where((r) =>
        r.checkInTime.isAfter(todayStart)
      ).toList();

      final activeCount = todayCheckIns.where((r) => r.isActive).length;

      setState(() {
        _todayCheckIns = todayCheckIns;
        _activeCount = activeCount;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadCheckIns,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Өнөөдрийн ирц',
                        style: AppTypography.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _formatDate(DateTime.now()),
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.people_rounded,
                          value: '${_todayCheckIns.length}',
                          label: 'Нийт ирц',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.fitness_center_rounded,
                          value: '$_activeCount',
                          label: 'Идэвхтэй',
                          color: AppColors.success,
                          isHighlighted: _activeCount > 0,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.logout_rounded,
                          value: '${_todayCheckIns.length - _activeCount}',
                          label: 'Гарсан',
                          color: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.lg),
              ),

              // Active sessions section
              if (_activeCount > 0) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                    child: Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'Идэвхтэй ($_activeCount)',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final activeCheckIns = _todayCheckIns.where((r) => r.isActive).toList();
                      if (index >= activeCheckIns.length) return null;
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.screenPadding,
                          vertical: AppSpacing.xs,
                        ),
                        child: _buildCheckInCard(activeCheckIns[index], isActive: true),
                      );
                    },
                    childCount: _todayCheckIns.where((r) => r.isActive).length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
              ],

              // Completed sessions section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.textTertiary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Дууссан (${_todayCheckIns.length - _activeCount})',
                        style: AppTypography.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

              // Check-in list
              _isLoading
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xl),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      ),
                    )
                  : _todayCheckIns.where((r) => !r.isActive).isEmpty
                      ? SliverToBoxAdapter(
                          child: _buildEmptyState(),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final completedCheckIns = _todayCheckIns.where((r) => !r.isActive).toList();
                              if (index >= completedCheckIns.length) return null;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.screenPadding,
                                  vertical: AppSpacing.xs,
                                ),
                                child: _buildCheckInCard(completedCheckIns[index]),
                              );
                            },
                            childCount: _todayCheckIns.where((r) => !r.isActive).length,
                          ),
                        ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxl),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isHighlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: isHighlighted
            ? Border.all(color: color.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.numberSmall.copyWith(
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInCard(CheckInRecord record, {bool isActive = false}) {
    final duration = isActive
        ? record.currentDuration
        : record.duration;
    final hours = duration?.inHours ?? 0;
    final minutes = (duration?.inMinutes ?? 0) % 60;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.success.withValues(alpha: 0.05)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: isActive
            ? Border.all(color: AppColors.success.withValues(alpha: 0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: isActive
                  ? AppColors.successGradient
                  : AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Center(
              child: Text(
                _getInitials(record.oderId),
                style: AppTypography.titleSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Гишүүн #${record.oderId.substring(0, 6)}',
                      style: AppTypography.titleSmall,
                    ),
                    if (isActive) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          'Идэвхтэй',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Орсон: ${_formatTime(record.checkInTime)}',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          // Duration
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hours > 0 ? '${hours}ц ${minutes}м' : '${minutes}м',
                style: AppTypography.titleSmall.copyWith(
                  color: isActive ? AppColors.success : AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (record.xpEarned != null && !isActive)
                Text(
                  '+${record.xpEarned} XP',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.secondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: AppColors.disabled,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Дууссан ирц байхгүй байна',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Нэгдүгээр', 'Хоёрдугаар', 'Гуравдугаар', 'Дөрөвдүгээр',
      'Тавдугаар', 'Зургадугаар', 'Долдугаар', 'Наймдугаар',
      'Есдүгээр', 'Аравдугаар', 'Арван нэгдүгээр', 'Арван хоёрдугаар',
    ];
    return '${date.year} оны ${months[date.month - 1]} сарын ${date.day}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getInitials(String userId) {
    if (userId.length >= 2) {
      return userId.substring(0, 2).toUpperCase();
    }
    return userId.toUpperCase();
  }
}
