import 'package:flutter/material.dart';

class WeeklyProgressChart extends StatelessWidget {
  final List<int> weeklyWorkouts; // 7 days of workout counts
  final List<double> weeklyCalories; // 7 days of calories
  final int currentStreak;
  final bool isDarkMode;

  const WeeklyProgressChart({
    super.key,
    required this.weeklyWorkouts,
    required this.weeklyCalories,
    required this.currentStreak,
    required this.isDarkMode,
  });

  static const List<String> _dayLabels = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().weekday - 1; // 0 = Monday
    final maxCalories = weeklyCalories.isEmpty
        ? 500
        : weeklyCalories.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDarkMode ? Colors.black : Colors.grey).withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Долоо хоногийн тойм',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weeklyWorkouts.where((w) => w > 0).length}/7 өдөр идэвхтэй',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFE7409), Color(0xFFFF9149)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$currentStreak',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bar chart
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final isToday = index == today;
                final hasWorkout = weeklyWorkouts.length > index && weeklyWorkouts[index] > 0;
                final calories = weeklyCalories.length > index ? weeklyCalories[index] : 0;
                final barHeight = maxCalories > 0
                    ? (calories / maxCalories * 80).clamp(8.0, 80.0)
                    : 8.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Workout indicator
                        if (hasWorkout)
                          Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                              size: 16,
                            ),
                          ),

                        // Bar
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: barHeight,
                          decoration: BoxDecoration(
                            gradient: isToday
                                ? const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [Color(0xFFFE7409), Color(0xFFFF9149)],
                                  )
                                : LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: hasWorkout
                                        ? [Colors.green.shade400, Colors.green.shade300]
                                        : [Colors.grey.shade300, Colors.grey.shade200],
                                  ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Day label
                        Text(
                          _dayLabels[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday
                                ? const Color(0xFFFE7409)
                                : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.green, 'Дасгал хийсэн'),
              const SizedBox(width: 20),
              _buildLegendItem(const Color(0xFFFE7409), 'Өнөөдөр'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
