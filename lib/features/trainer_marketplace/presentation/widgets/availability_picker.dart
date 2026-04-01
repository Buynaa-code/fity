import 'package:flutter/material.dart';
import '../../domain/entities/trainer.dart';

class AvailabilityPicker extends StatefulWidget {
  final List<TimeSlot> selectedSlots;
  final ValueChanged<List<TimeSlot>> onChanged;

  const AvailabilityPicker({
    super.key,
    required this.selectedSlots,
    required this.onChanged,
  });

  @override
  State<AvailabilityPicker> createState() => _AvailabilityPickerState();
}

class _AvailabilityPickerState extends State<AvailabilityPicker> {
  final List<String> _weekDays = [
    'Даваа',
    'Мягмар',
    'Лхагва',
    'Пүрэв',
    'Баасан',
    'Бямба',
    'Ням',
  ];

  final List<int> _hours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20];

  Set<String> _selectedSlotIds = {};

  @override
  void initState() {
    super.initState();
    _selectedSlotIds = widget.selectedSlots.map((s) => s.id).toSet();
  }

  String _getSlotId(int dayIndex, int hour) => '${dayIndex}_$hour';

  void _toggleSlot(int dayIndex, int hour) {
    final slotId = _getSlotId(dayIndex, hour);
    setState(() {
      if (_selectedSlotIds.contains(slotId)) {
        _selectedSlotIds.remove(slotId);
      } else {
        _selectedSlotIds.add(slotId);
      }
    });
    _notifyChange();
  }

  void _notifyChange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final slots = <TimeSlot>[];
    for (final slotId in _selectedSlotIds) {
      final parts = slotId.split('_');
      final dayIndex = int.parse(parts[0]);
      final hour = int.parse(parts[1]);

      final date = startOfWeek.add(Duration(days: dayIndex));
      slots.add(TimeSlot(
        id: slotId,
        dateTime: DateTime(date.year, date.month, date.day, hour),
        durationMinutes: 60,
        isAvailable: true,
      ));
    }
    widget.onChanged(slots);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Боломжтой цагууд',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Захиалга хүлээн авах боломжтой цагуудаа сонгоно уу',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowHeight: 40,
            dataRowMinHeight: 36,
            dataRowMaxHeight: 36,
            columnSpacing: 8,
            horizontalMargin: 0,
            columns: [
              const DataColumn(
                label: SizedBox(
                  width: 50,
                  child: Text('Цаг', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              ..._weekDays.map((day) => DataColumn(
                    label: SizedBox(
                      width: 40,
                      child: Text(
                        day.substring(0, 2),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )),
            ],
            rows: _hours.map((hour) {
              return DataRow(
                cells: [
                  DataCell(Text(
                    '${hour.toString().padLeft(2, '0')}:00',
                    style: const TextStyle(fontSize: 12),
                  )),
                  ...List.generate(7, (dayIndex) {
                    final isSelected =
                        _selectedSlotIds.contains(_getSlotId(dayIndex, hour));
                    return DataCell(
                      GestureDetector(
                        onTap: () => _toggleSlot(dayIndex, hour),
                        child: Container(
                          width: 36,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFF72928)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFF72928),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Боломжтой',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
            const SizedBox(width: 24),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Боломжгүй',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${_selectedSlotIds.length} цаг сонгогдсон',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFFF72928),
          ),
        ),
      ],
    );
  }
}
