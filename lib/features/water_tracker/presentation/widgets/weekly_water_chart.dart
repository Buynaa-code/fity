import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../domain/entities/water_intake.dart';

class WeeklyWaterChart extends StatelessWidget {
  final List<DailyWaterSummary> weeklySummary;
  final bool isDarkMode;

  const WeeklyWaterChart({
    super.key,
    required this.weeklySummary,
    this.isDarkMode = false,
  });

  int get _streakCount {
    int streak = 0;
    final sortedSummary = List<DailyWaterSummary>.from(weeklySummary)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (final summary in sortedSummary) {
      if (summary.isGoalReached) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  int get _goalsReachedThisWeek {
    return weeklySummary.where((s) => s.isGoalReached).length;
  }

  @override
  Widget build(BuildContext context) {
    if (weeklySummary.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxY = weeklySummary.fold<double>(
      2000,
      (max, s) => s.goalMl > max ? s.goalMl.toDouble() : max,
    );

    final streak = _streakCount;
    final goalsReached = _goalsReachedThisWeek;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        border: isDarkMode
            ? Border.all(color: Colors.grey.shade800)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '7 хоногийн түүх',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$goalsReached/7 зорилго биелсэн',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 12,
                      color: isDarkMode
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              // Streak badge
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF39C12).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$streak хоног',
                        style: const TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Legend
          Row(
            children: [
              _LegendItem(
                color: const Color(0xFF3498DB),
                label: 'Уусан',
                isDarkMode: isDarkMode,
              ),
              const SizedBox(width: 16),
              _LegendItem(
                color: const Color(0xFF2ECC71),
                label: 'Зорилго биелсэн',
                isDarkMode: isDarkMode,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Chart
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade800,
                    tooltipRoundedRadius: 12,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final summary = weeklySummary[group.x.toInt()];
                      final percentage = (summary.totalMl / summary.goalMl * 100).toInt();
                      return BarTooltipItem(
                        '${rod.toY.toInt()}мл\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          fontFamily: 'Rubik',
                        ),
                        children: [
                          TextSpan(
                            text: '$percentage%',
                            style: TextStyle(
                              color: summary.isGoalReached
                                  ? const Color(0xFF2ECC71)
                                  : Colors.grey.shade400,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= weeklySummary.length) {
                          return const SizedBox.shrink();
                        }
                        final weekdays = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];
                        final dayIndex = weeklySummary[index].date.weekday - 1;
                        final isToday = _isToday(weeklySummary[index].date);
                        final isGoalReached = weeklySummary[index].isGoalReached;

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                weekdays[dayIndex],
                                style: TextStyle(
                                  color: isToday
                                      ? const Color(0xFF3498DB)
                                      : (isDarkMode
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600),
                                  fontSize: 12,
                                  fontWeight: isToday
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontFamily: 'Rubik',
                                ),
                              ),
                              if (isGoalReached) ...[
                                const SizedBox(height: 2),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2ECC71),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                      reservedSize: 36,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                barGroups: weeklySummary.asMap().entries.map((entry) {
                  final index = entry.key;
                  final summary = entry.value;
                  final isGoalReached = summary.totalMl >= summary.goalMl;
                  final isToday = _isToday(summary.date);

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: summary.totalMl.toDouble(),
                        gradient: isGoalReached
                            ? const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                              )
                            : const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [Color(0xFF2980B9), Color(0xFF3498DB)],
                              ),
                        width: isToday ? 28 : 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: summary.goalMl.toDouble(),
                          color: isDarkMode
                              ? Colors.grey.shade800
                              : Colors.grey.shade200,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDarkMode;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
            fontFamily: 'Rubik',
            fontSize: 11,
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
