import 'package:flutter/material.dart';
import '../../../../core/branding/brand_config.dart';
import '../../domain/entities/attendance.dart';

/// Ирцийн түүхийн жагсаалт
class AttendanceHistoryList extends StatelessWidget {
  final List<Attendance> history;
  final VoidCallback? onLoadMore;
  final bool hasMore;

  const AttendanceHistoryList({
    super.key,
    required this.history,
    this.onLoadMore,
    this.hasMore = false,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: BrandShadows.small,
        ),
        child: Column(
          children: [
            Icon(
              Icons.history_rounded,
              size: 48,
              color: BrandColors.disabled,
            ),
            const SizedBox(height: 12),
            Text(
              'Ирцийн түүх байхгүй',
              style: TextStyle(
                fontSize: 14,
                color: BrandColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    // Өдрөөр бүлэглэх
    final groupedByMonth = _groupByMonth(history);

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
                  color: BrandColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: BrandColors.info,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Ирцийн түүх',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BrandColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${history.length} удаа',
                style: TextStyle(
                  fontSize: 13,
                  color: BrandColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...groupedByMonth.entries.map((entry) {
            return _buildMonthSection(entry.key, entry.value);
          }),
          if (hasMore && onLoadMore != null) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: onLoadMore,
                child: Text(
                  'Цааш үзэх',
                  style: TextStyle(
                    color: BrandColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Map<String, List<Attendance>> _groupByMonth(List<Attendance> attendances) {
    final Map<String, List<Attendance>> grouped = {};
    for (final a in attendances) {
      final monthKey = '${a.date.year}-${a.date.month.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(monthKey, () => []).add(a);
    }
    return grouped;
  }

  Widget _buildMonthSection(String monthKey, List<Attendance> attendances) {
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final monthName = _getMonthName(month);
    final isCurrentYear = year == DateTime.now().year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            isCurrentYear ? monthName : '$monthName $year',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: BrandColors.textSecondary,
            ),
          ),
        ),
        ...attendances.map((a) => _buildAttendanceItem(a)),
      ],
    );
  }

  Widget _buildAttendanceItem(Attendance attendance) {
    final isToday = _isToday(attendance.date);
    final isYesterday = _isYesterday(attendance.date);

    String dateDisplay;
    if (isToday) {
      dateDisplay = 'Өнөөдөр';
    } else if (isYesterday) {
      dateDisplay = 'Өчигдөр';
    } else {
      dateDisplay = '${attendance.date.month}/${attendance.date.day} - ${_getWeekdayName(attendance.date.weekday)}';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isToday
            ? BrandColors.success.withValues(alpha: 0.08)
            : BrandColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: isToday
            ? Border.all(color: BrandColors.success.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: BrandColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 18,
              color: BrandColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateDisplay,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                    color: BrandColors.textPrimary,
                  ),
                ),
                Text(
                  _formatTime(attendance.checkedInAt),
                  style: TextStyle(
                    fontSize: 11,
                    color: BrandColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: BrandColors.success,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'NEW',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Нэгдүгээр сар', 'Хоёрдугаар сар', 'Гуравдугаар сар',
      'Дөрөвдүгээр сар', 'Тавдугаар сар', 'Зургадугаар сар',
      'Долдугаар сар', 'Наймдугаар сар', 'Есдүгээр сар',
      'Аравдугаар сар', 'Арван нэгдүгээр сар', 'Арван хоёрдугаар сар',
    ];
    return months[month];
  }

  String _getWeekdayName(int weekday) {
    const days = ['Даваа', 'Мягмар', 'Лхагва', 'Пүрэв', 'Баасан', 'Бямба', 'Ням'];
    return days[weekday - 1];
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }
}
