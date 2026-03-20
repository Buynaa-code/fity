import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/water_bloc.dart';
import '../bloc/water_event.dart';
import '../bloc/water_state.dart';
import '../widgets/water_progress_ring.dart';
import '../widgets/water_quick_add.dart';
import '../widgets/weekly_water_chart.dart';
import '../../domain/entities/water_intake.dart';

class WaterTrackerScreen extends StatelessWidget {
  const WaterTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text(
              'Усны хэмжээ',
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
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _showGoalSettings(context, state.dailySummary?.goalMl ?? 2000),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, WaterState state) {
    if (state.status == WaterStatus.loading && state.dailySummary == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final summary = state.dailySummary ??
        DailyWaterSummary(
          date: DateTime.now(),
          totalMl: 0,
          goalMl: 2000,
          intakes: const [],
        );

    return RefreshIndicator(
      onRefresh: () async {
        context.read<WaterBloc>().add(const LoadWeeklySummary());
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Progress Ring
            WaterProgressRing(
              progress: summary.progress,
              currentMl: summary.totalMl,
              goalMl: summary.goalMl,
              size: 220,
            ),
            const SizedBox(height: 8),
            // Status message
            _buildStatusMessage(summary),
            const SizedBox(height: 32),
            // Quick add buttons
            WaterQuickAdd(
              onAdd: (amount) {
                HapticFeedback.mediumImpact();
                context.read<WaterBloc>().add(AddWaterIntake(amount));
                _showAddedSnackbar(context, amount);
              },
            ),
            const SizedBox(height: 24),
            // Weekly chart
            if (state.weeklySummary.isNotEmpty)
              WeeklyWaterChart(weeklySummary: state.weeklySummary),
            const SizedBox(height: 24),
            // Today's log
            _buildTodayLog(context, summary),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusMessage(DailyWaterSummary summary) {
    String message;
    Color color;
    IconData icon;

    if (summary.isGoalReached) {
      message = 'Зорилгодоо хүрлээ!';
      color = Colors.green;
      icon = Icons.celebration;
    } else if (summary.progress >= 0.75) {
      message = 'Бараг хүрч байна! ${summary.remaining}мл үлдсэн';
      color = Colors.blue;
      icon = Icons.trending_up;
    } else if (summary.progress >= 0.5) {
      message = 'Сайн байна! ${summary.remaining}мл үлдсэн';
      color = Colors.orange;
      icon = Icons.thumb_up_outlined;
    } else {
      message = 'Ус уухаа бүү март! ${summary.remaining}мл үлдсэн';
      color = Colors.grey.shade600;
      icon = Icons.water_drop_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Rubik',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayLog(BuildContext context, DailyWaterSummary summary) {
    if (summary.intakes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(Icons.water_drop_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Өнөөдөр ус уугаагүй байна',
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Өнөөдрийн бүртгэл',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${summary.intakes.length} удаа',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    if (value == 'reset') {
                      _showResetConfirmation(context, summary);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'reset',
                      child: Row(
                        children: [
                          Icon(Icons.refresh_rounded,
                            color: Colors.red.shade400,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Бүгдийг устгах',
                            style: TextStyle(
                              color: Colors.red.shade400,
                              fontWeight: FontWeight.w500,
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
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: summary.intakes.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final intake = summary.intakes[summary.intakes.length - 1 - index];
              return _buildIntakeItem(context, intake);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIntakeItem(BuildContext context, WaterIntake intake) {
    final timeStr =
        '${intake.timestamp.hour.toString().padLeft(2, '0')}:${intake.timestamp.minute.toString().padLeft(2, '0')}';

    return Dismissible(
      key: Key(intake.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red.shade400,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<WaterBloc>().add(RemoveWaterIntake(intake.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${intake.amountMl}мл устгагдлаа'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.water_drop, color: Colors.blue, size: 20),
        ),
        title: Text(
          '${intake.amountMl}мл',
          style: const TextStyle(
            fontFamily: 'Rubik',
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Text(
          timeStr,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  void _showAddedSnackbar(BuildContext context, int amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('+$amountмл нэмэгдлээ'),
          ],
        ),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, DailyWaterSummary summary) {
    final previousIntakes = List<WaterIntake>.from(summary.intakes);
    final previousTotalMl = summary.totalMl;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Бүртгэлийг устгах',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Өнөөдрийн бүх усны бүртгэлийг устгах уу?',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.water_drop, color: Colors.blue.shade400, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${summary.totalMl} мл',
                        style: TextStyle(
                          fontFamily: 'Rubik',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Text(
                        '${summary.intakes.length} удаа бүртгэгдсэн',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Болих',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              HapticFeedback.mediumImpact();
              context.read<WaterBloc>().add(const ResetDailyWater());
              _showResetUndoSnackbar(context, previousIntakes, previousTotalMl);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Устгах',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetUndoSnackbar(
    BuildContext context,
    List<WaterIntake> previousIntakes,
    int previousTotalMl,
  ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${previousTotalMl}мл устгагдлаа',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Буцаах',
          textColor: Colors.blue.shade300,
          onPressed: () {
            HapticFeedback.lightImpact();
            context.read<WaterBloc>().add(UndoResetDailyWater(
              previousIntakes: previousIntakes,
              previousTotalMl: previousTotalMl,
            ));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.replay, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text('Бүртгэл сэргээгдлээ'),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showGoalSettings(BuildContext context, int currentGoal) {
    final controller = TextEditingController(text: currentGoal.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Өдрийн зорилго',
              style: TextStyle(
                fontFamily: 'Rubik',
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Өдөрт уух ёстой усны хэмжээгээ тохируулна уу',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontFamily: 'Rubik',
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                suffixText: 'мл',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Quick presets
            Wrap(
              spacing: 8,
              children: [1500, 2000, 2500, 3000].map((goal) {
                return ActionChip(
                  label: Text('$goalмл'),
                  onPressed: () => controller.text = goal.toString(),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final goal = int.tryParse(controller.text);
                  if (goal != null && goal > 0) {
                    context.read<WaterBloc>().add(UpdateDailyGoal(goal));
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Хадгалах',
                  style: TextStyle(
                    fontFamily: 'Rubik',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
