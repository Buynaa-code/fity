import 'package:flutter/material.dart';
import '../../../../core/branding/brand_config.dart';

/// 7 хоногийн ирцийн харагдац (dots)
class WeeklyAttendanceDots extends StatelessWidget {
  final Map<DateTime, String> weeklyAttendance;
  final bool compact;

  const WeeklyAttendanceDots({
    super.key,
    required this.weeklyAttendance,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Огноогоор эрэмбэлэх
    final sortedDates = weeklyAttendance.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: compact ? MainAxisAlignment.start : MainAxisAlignment.spaceEvenly,
      children: sortedDates.map((date) {
        final status = weeklyAttendance[date] ?? 'not_scheduled';
        final isToday = _isToday(date);

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 0),
          child: _buildDot(date, status, isToday),
        );
      }).toList(),
    );
  }

  Widget _buildDot(DateTime date, String status, bool isToday) {
    final color = _getColor(status);
    final size = compact ? 8.0 : 12.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!compact)
          Text(
            _getWeekdayShort(date.weekday),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? BrandColors.textPrimary : BrandColors.textTertiary,
            ),
          ),
        if (!compact) const SizedBox(height: 4),
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: isToday
                ? Border.all(
                    color: BrandColors.primary,
                    width: 2,
                  )
                : null,
            boxShadow: status == 'attended'
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        ),
        if (!compact) const SizedBox(height: 2),
        if (!compact)
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 9,
              color: isToday ? BrandColors.textPrimary : BrandColors.textTertiary,
            ),
          ),
      ],
    );
  }

  Color _getColor(String status) {
    switch (status) {
      case 'attended':
        return BrandColors.success;
      case 'missed':
        return BrandColors.error;
      case 'future':
        return BrandColors.disabled.withValues(alpha: 0.3);
      case 'not_scheduled':
      default:
        return BrandColors.disabled.withValues(alpha: 0.15);
    }
  }

  String _getWeekdayShort(int weekday) {
    const days = ['Да', 'Мя', 'Лх', 'Пү', 'Ба', 'Бя', 'Ня'];
    return days[weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
