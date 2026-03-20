import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import '../../domain/entities/badge.dart';

class BadgeCard extends StatelessWidget {
  final Badge badge;
  final UserBadge? userBadge;
  final BadgeProgress? progress;
  final VoidCallback? onTap;

  const BadgeCard({
    super.key,
    required this.badge,
    this.userBadge,
    this.progress,
    this.onTap,
  });

  bool get isEarned => userBadge != null;
  bool get isNew => userBadge?.isNew ?? false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
        _showBadgeDetail(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isEarned
              ? Border.all(color: badge.color.withValues(alpha: 0.5), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: isEarned
                  ? badge.color.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isEarned ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Badge Icon
                  _buildBadgeIcon(),
                  const SizedBox(height: 8),

                  // Badge Name
                  Text(
                    badge.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isEarned ? Colors.grey[800] : Colors.grey[400],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Progress indicator (if not earned)
                  if (!isEarned && progress != null) ...[
                    const SizedBox(height: 6),
                    _buildProgressIndicator(),
                  ],

                  // XP reward
                  if (isEarned) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.stars_rounded,
                          size: 12,
                          color: Colors.amber[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '+${badge.xpReward}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // New badge indicator
            if (isNew)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withValues(alpha: 0.4),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),

            // Rarity indicator
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: badge.rarityGradient,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeIcon() {
    final double size = 48;

    if (!isEarned) {
      // Locked badge
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Icon(
          badge.iconData,
          color: Colors.grey[400],
          size: 24,
        ),
      );
    }

    // Earned badge with gradient and glow
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            badge.color,
            badge.color.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: badge.color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        badge.iconData,
        color: Colors.white,
        size: 24,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final percent = progress?.progressPercent ?? 0.0;
    final current = progress?.currentValue ?? 0;
    final required = progress?.requiredValue ?? badge.requiredValue;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              badge.color.withValues(alpha: 0.5),
            ),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$current/$required',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _showBadgeDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BadgeDetailSheet(
        badge: badge,
        userBadge: userBadge,
        progress: progress,
      ),
    );
  }
}

class BadgeDetailSheet extends StatelessWidget {
  final Badge badge;
  final UserBadge? userBadge;
  final BadgeProgress? progress;

  const BadgeDetailSheet({
    super.key,
    required this.badge,
    this.userBadge,
    this.progress,
  });

  bool get isEarned => userBadge != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Large badge icon
                Hero(
                  tag: 'badge_${badge.id}',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: isEarned
                          ? LinearGradient(
                              colors: [badge.color, badge.color.withValues(alpha: 0.7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: isEarned ? null : Colors.grey[200],
                      shape: BoxShape.circle,
                      boxShadow: isEarned
                          ? [
                              BoxShadow(
                                color: badge.color.withValues(alpha: 0.4),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      badge.iconData,
                      color: isEarned ? Colors.white : Colors.grey[400],
                      size: 48,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Badge name
                Text(
                  badge.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // Rarity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: badge.rarityGradient),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge.rarityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  badge.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem(
                      Icons.category_rounded,
                      badge.categoryName,
                      'Ангилал',
                    ),
                    _buildStatItem(
                      Icons.stars_rounded,
                      '+${badge.xpReward}',
                      'XP',
                      color: Colors.amber,
                    ),
                    _buildStatItem(
                      Icons.track_changes_rounded,
                      '${badge.requiredValue} ${badge.unit}',
                      'Шаардлага',
                    ),
                  ],
                ),

                // Progress or earned date
                if (isEarned) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Амжилттай авсан!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                _formatDate(userBadge!.earnedAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (progress != null) ...[
                  const SizedBox(height: 20),
                  _buildProgressSection(),
                ],

                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: badge.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Хаах',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    final percent = progress!.progressPercent;
    final current = progress!.currentValue;
    final required = progress!.requiredValue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Явц',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '$current / $required ${badge.unit}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: badge.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(badge.color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percent * 100).toInt()}% дууссан',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
