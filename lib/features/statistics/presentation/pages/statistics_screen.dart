import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';
import '../widgets/stat_card.dart';
import '../widgets/weekly_activity_chart.dart';
import '../widgets/streak_widget.dart';
import '../../domain/entities/statistics.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatisticsBloc, StatisticsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text(
              'Статистик',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month_outlined),
                onPressed: () => _showMonthPicker(context),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, StatisticsState state) {
    if (state.status == StatisticsStatus.loading && state.workoutStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final workoutStats = state.workoutStats ?? WorkoutStatistics.empty();
    final weeklyStats = state.weeklyStats ?? WeeklyStats.empty();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<StatisticsBloc>().add(const LoadStatistics());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero stat card
            LargeStatCard(
              icon: Icons.fitness_center,
              value: '${workoutStats.totalWorkouts}',
              label: 'Нийт дасгал',
              color: Colors.orange,
              trailing: _buildCircularProgress(weeklyStats),
            ),
            const SizedBox(height: 20),
            // Streak widget
            StreakWidget(
              currentStreak: workoutStats.currentStreak,
              bestStreak: workoutStats.bestStreak,
            ),
            const SizedBox(height: 20),
            // Stats grid
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.local_fire_department,
                    value: '${workoutStats.totalCalories.toInt()}',
                    label: 'Нийт калори',
                    color: Colors.red,
                    subtitle: 'ккал шатаасан',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.timer,
                    value: _formatDuration(workoutStats.totalTime),
                    label: 'Нийт цаг',
                    color: Colors.blue,
                    subtitle: 'идэвхтэй',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.water_drop,
                    value: '${(weeklyStats.totalWaterMl / 1000).toStringAsFixed(1)}л',
                    label: 'Долоо хоногт',
                    color: Colors.cyan,
                    subtitle: 'ус уусан',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle,
                    value: '${weeklyStats.goalsMetCount}',
                    label: 'Зорилго',
                    color: Colors.green,
                    subtitle: '7 хоногт биелүүлсэн',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Weekly activity chart
            if (weeklyStats.dailyActivities.isNotEmpty)
              WeeklyActivityChart(activities: weeklyStats.dailyActivities),
            const SizedBox(height: 24),
            // Exercise breakdown
            _buildExerciseBreakdown(workoutStats),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(WeeklyStats weeklyStats) {
    final weeklyGoal = 7;
    final progress = weeklyStats.goalsMetCount / weeklyGoal;

    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 6,
              strokeCap: StrokeCap.round,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${weeklyStats.goalsMetCount}/$weeklyGoal',
                style: const TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                'хоног',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseBreakdown(WorkoutStatistics stats) {
    if (stats.exerciseCounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.fitness_center, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Дасгалын бүртгэл байхгүй',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    final sortedExercises = stats.exerciseCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalCount = sortedExercises.fold<int>(0, (sum, e) => sum + e.value);

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Дасгалын задаргаа',
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          ...sortedExercises.take(5).map((entry) {
            final percentage = entry.value / totalCount;
            return _buildExerciseItem(entry.key, entry.value, percentage);
          }),
        ],
      ),
    );
  }

  Widget _buildExerciseItem(String name, int count, double percentage) {
    final colors = [
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
    ];
    final colorIndex = name.hashCode % colors.length;
    final color = colors[colorIndex.abs()];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$count удаа',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}ц ${duration.inMinutes.remainder(60)}м';
    }
    return '${duration.inMinutes}м';
  }

  void _showMonthPicker(BuildContext context) {
    final now = DateTime.now();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Сар сонгох',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(6, (index) {
                final month = now.month - index;
                final year = month <= 0 ? now.year - 1 : now.year;
                final actualMonth = month <= 0 ? month + 12 : month;
                final monthNames = [
                  '1-р сар', '2-р сар', '3-р сар', '4-р сар',
                  '5-р сар', '6-р сар', '7-р сар', '8-р сар',
                  '9-р сар', '10-р сар', '11-р сар', '12-р сар',
                ];

                return ActionChip(
                  label: Text(monthNames[actualMonth - 1]),
                  onPressed: () {
                    context.read<StatisticsBloc>().add(
                          LoadMonthlyActivities(year: year, month: actualMonth),
                        );
                    Navigator.pop(context);
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
