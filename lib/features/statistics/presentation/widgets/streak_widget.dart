import 'package:flutter/material.dart';

class StreakWidget extends StatelessWidget {
  final int currentStreak;
  final int bestStreak;

  const StreakWidget({
    super.key,
    required this.currentStreak,
    required this.bestStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStreakItem(
              icon: Icons.local_fire_department,
              value: currentStreak,
              label: 'Одоогийн streak',
              color: Colors.orange,
              isActive: currentStreak > 0,
            ),
          ),
          Container(
            width: 1,
            height: 60,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStreakItem(
              icon: Icons.emoji_events,
              value: bestStreak,
              label: 'Хамгийн сайн',
              color: Colors.amber,
              isActive: bestStreak > 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakItem({
    required IconData icon,
    required int value,
    required String label,
    required Color color,
    required bool isActive,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (isActive)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeInOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withOpacity(0.15),
                      ),
                    ),
                  );
                },
              ),
            Icon(
              icon,
              color: isActive ? color : Colors.grey.shade400,
              size: 32,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '$value хоног',
          style: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.grey.shade900 : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
