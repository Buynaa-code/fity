import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/ui/theme/app_colors.dart';
import '../../../../core/ui/theme/app_typography.dart';
import '../../../../core/ui/theme/app_spacing.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  final int streakDays;
  final int level;
  final int totalXp;
  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onNotificationTap;
  final VoidCallback onProfileTap;
  final int notificationCount;

  const HomeHeader({
    super.key,
    required this.userName,
    required this.streakDays,
    required this.level,
    required this.totalXp,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onNotificationTap,
    required this.onProfileTap,
    this.notificationCount = 0,
  });

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Сайн шөнө';
    if (hour < 12) return 'Өглөөний мэнд';
    if (hour < 18) return 'Өдрийн мэнд';
    return 'Орой мэнд';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        MediaQuery.of(context).padding.top + AppSpacing.md,
        AppSpacing.screenPadding,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBackground : AppColors.background,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row - Profile and Actions
          Row(
            children: [
              // Profile avatar with level indicator
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onProfileTap();
                },
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      const Center(
                        child: Icon(Icons.person_rounded, color: Colors.white, size: 26),
                      ),
                      // Level badge
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isDarkMode ? AppColors.darkBackground : AppColors.background,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            '$level',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Greeting and name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary,
                      ),
                    ),
                    Text(
                      userName,
                      style: AppTypography.headlineMedium.copyWith(
                        color: isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action buttons
              _buildIconButton(
                icon: isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: onThemeToggle,
              ),
              const SizedBox(width: AppSpacing.sm),
              Stack(
                children: [
                  _buildIconButton(
                    icon: Icons.notifications_outlined,
                    onTap: onNotificationTap,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            notificationCount > 9 ? '9+' : '$notificationCount',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Stats row - clean minimal design
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.darkSurface : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Streak
                _buildStatItem(
                  icon: Icons.local_fire_department_rounded,
                  value: '$streakDays',
                  label: 'өдөр',
                  color: AppColors.streak,
                  hasValue: streakDays > 0,
                ),
                _buildDivider(),
                // Level
                _buildStatItem(
                  icon: Icons.workspace_premium_rounded,
                  value: 'Lv.$level',
                  label: 'түвшин',
                  color: AppColors.secondary,
                  hasValue: true,
                ),
                _buildDivider(),
                // XP
                _buildStatItem(
                  icon: Icons.star_rounded,
                  value: _formatXp(totalXp),
                  label: 'XP',
                  color: AppColors.badge,
                  hasValue: totalXp > 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDarkMode
              ? AppColors.darkSurfaceVariant
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required bool hasValue,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: hasValue ? color : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: AppTypography.titleMedium.copyWith(
                  color: hasValue
                      ? (isDarkMode ? AppColors.darkTextPrimary : AppColors.textPrimary)
                      : (isDarkMode ? Colors.grey[600] : Colors.grey[400]),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: isDarkMode ? AppColors.darkBorder : AppColors.divider,
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}K';
    }
    return '$xp';
  }
}
