import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  String get _motivationalMessage {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 10) return 'Өглөөний дасгал хийх цаг боллоо!';
    if (hour >= 10 && hour < 14) return 'Идэвхитэй байх цаг!';
    if (hour >= 14 && hour < 18) return 'Өдрийн дундын эрч!';
    if (hour >= 18 && hour < 21) return 'Оройн дасгалд бэлэн үү?';
    return 'Сайн амраарай!';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [const Color(0xFF1E1E1E), const Color(0xFF2D2D2D)]
              : [Colors.white, Colors.grey.shade50],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with actions
          Row(
            children: [
              // Profile avatar with level indicator
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onProfileTap();
                },
                child: Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFE7409), Color(0xFFFF9149)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFE7409).withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
                    ),
                    // Level badge
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          'L$level',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Greeting and name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$userName! 💪',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              // Theme toggle
              _buildIconButton(
                icon: isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                onTap: onThemeToggle,
                color: isDarkMode ? Colors.amber : Colors.grey[700],
              ),

              const SizedBox(width: 12),

              // Notifications
              Stack(
                children: [
                  _buildIconButton(
                    icon: Icons.notifications_rounded,
                    onTap: onNotificationTap,
                  ),
                  if (notificationCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFE7409),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            notificationCount > 9 ? '9+' : '$notificationCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
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

          const SizedBox(height: 20),

          // Stats row
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white.withValues(alpha: 0.05)
                  : const Color(0xFFFE7409).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFFE7409).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                // Streak
                _buildStatItem(
                  icon: Icons.local_fire_department_rounded,
                  value: '$streakDays',
                  label: 'Streak',
                  color: Colors.orange,
                ),
                _buildDivider(),
                // Level
                _buildStatItem(
                  icon: Icons.military_tech_rounded,
                  value: 'Level $level',
                  label: 'Түвшин',
                  color: Colors.purple,
                ),
                _buildDivider(),
                // XP
                _buildStatItem(
                  icon: Icons.stars_rounded,
                  value: _formatXp(totalXp),
                  label: 'XP',
                  color: Colors.amber,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Motivational message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFE7409).withValues(alpha: 0.1),
                  const Color(0xFFFF9149).withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _motivationalMessage,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey[700],
                      fontWeight: FontWeight.w500,
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withValues(alpha: 0.08) : Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          size: 22,
          color: color ?? (isDarkMode ? Colors.grey[400] : Colors.grey[700]),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      return '${(xp / 1000).toStringAsFixed(1)}K';
    }
    return '$xp';
  }
}
