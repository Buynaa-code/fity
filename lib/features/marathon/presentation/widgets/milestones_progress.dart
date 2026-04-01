import 'package:flutter/material.dart';
import '../../../../core/branding/brand_config.dart';
import '../../domain/entities/marathon_milestone.dart';

/// Milestone-уудын progress харагдац
class MilestonesProgress extends StatelessWidget {
  final List<MarathonMilestone> milestones;
  final bool showAll;

  const MilestonesProgress({
    super.key,
    required this.milestones,
    this.showAll = false,
  });

  @override
  Widget build(BuildContext context) {
    // Streak ба attendance milestone-уудыг ялгах
    final streakMilestones = milestones
        .where((m) => m.type.isStreakMilestone)
        .toList();
    final attendanceMilestones = milestones
        .where((m) => m.type.isAttendanceMilestone)
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: BrandShadows.small,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: BrandGradients.gold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.military_tech_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Milestones',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.textPrimary,
                ),
              ),
              const Spacer(),
              _buildUnlockedCount(),
            ],
          ),
          const SizedBox(height: 20),
          // Streak milestones
          _buildSectionTitle('Streak', Icons.local_fire_department_rounded),
          const SizedBox(height: 12),
          _buildMilestoneGrid(streakMilestones),
          const SizedBox(height: 20),
          // Attendance milestones
          _buildSectionTitle('Ирц', Icons.check_circle_rounded),
          const SizedBox(height: 12),
          _buildMilestoneGrid(attendanceMilestones),
        ],
      ),
    );
  }

  Widget _buildUnlockedCount() {
    final unlockedCount = milestones.where((m) => m.isUnlocked).length;
    final totalCount = milestones.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: BrandColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$unlockedCount / $totalCount',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: BrandColors.secondary,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: BrandColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: BrandColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneGrid(List<MarathonMilestone> items) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items.map((milestone) => _buildMilestoneItem(milestone)).toList(),
    );
  }

  Widget _buildMilestoneItem(MarathonMilestone milestone) {
    final isUnlocked = milestone.isUnlocked;

    return Container(
      width: 70,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isUnlocked
            ? BrandColors.success.withValues(alpha: 0.1)
            : BrandColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? BrandColors.success : BrandColors.border,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon/Emoji
          Text(
            milestone.icon,
            style: TextStyle(
              fontSize: 24,
              color: isUnlocked ? null : BrandColors.disabled,
            ),
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            _getShortTitle(milestone.type),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: isUnlocked ? BrandColors.textPrimary : BrandColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Progress or XP
          if (isUnlocked)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 12,
                  color: BrandColors.success,
                ),
                const SizedBox(width: 2),
                Text(
                  '+${milestone.xp}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: BrandColors.success,
                  ),
                ),
              ],
            )
          else
            _buildProgressBar(milestone.progress),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: BrandColors.disabled.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: BrandColors.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  String _getShortTitle(MilestoneType type) {
    switch (type) {
      case MilestoneType.streak7:
        return '7 хоног';
      case MilestoneType.streak14:
        return '14 хоног';
      case MilestoneType.streak30:
        return 'Сарын';
      case MilestoneType.streak60:
        return '2 сар';
      case MilestoneType.streak90:
        return '3 сар';
      case MilestoneType.attendance7:
        return '7 удаа';
      case MilestoneType.attendance30:
        return '30 удаа';
      case MilestoneType.attendance60:
        return '60 удаа';
      case MilestoneType.attendance100:
        return '100 удаа';
    }
  }
}

/// Milestone celebration dialog
class MilestoneCelebrationDialog extends StatelessWidget {
  final List<MilestoneType> milestones;
  final VoidCallback onDismiss;

  const MilestoneCelebrationDialog({
    super.key,
    required this.milestones,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (milestones.isEmpty) return const SizedBox.shrink();

    final milestone = milestones.first;
    final totalXp = milestones.fold(0, (sum, m) => sum + m.xp);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Confetti animation placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: BrandGradients.gold,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  milestone.icon,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Milestone Unlocked!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: BrandColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              milestone.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: BrandColors.secondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              milestone.description,
              style: TextStyle(
                fontSize: 14,
                color: BrandColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // XP reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                gradient: BrandGradients.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    '+$totalXp XP',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Dismiss button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onDismiss,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BrandColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Гайхалтай!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
