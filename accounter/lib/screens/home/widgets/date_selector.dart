import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatelessWidget {
  final DateTime selectedDate;
  final Function(int) onDateChanged;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String getDateLabel(DateTime date) {
    final today = DateTime.now();
    if (isSameDay(date, today)) {
      return 'Bugün';
    } else if (isSameDay(date, today.subtract(const Duration(days: 1)))) {
      return 'Dün';
    } else if (isSameDay(date, today.add(const Duration(days: 1)))) {
      return 'Yarın';
    }
    return DateFormat('dd MMM', 'tr_TR').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final dayBefore = selectedDate.subtract(const Duration(days: 1));
    final dayAfter = selectedDate.add(const Duration(days: 1));

    return Column(
      children: [
        Container(
          height: 2,
          color: const Color(0xFFE2E8F0),
        ),
        GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity! > 0) {
              onDateChanged(-1);
            } else if (details.primaryVelocity! < 0) {
              onDateChanged(1);
            }
          },
          child: Container(
            height: 56,
            color: Colors.white,
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_left, size: 24),
                    onPressed: () => onDateChanged(-1),
                    color: const Color(0xFF4A5568),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onDateChanged(-1),
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Text(
                        getDateLabel(dayBefore),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color(0xFFF0F4F8),
                    alignment: Alignment.center,
                    child: Text(
                      getDateLabel(selectedDate),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A202C),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => onDateChanged(1),
                    child: Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: Text(
                        getDateLabel(dayAfter),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: IconButton(
                    icon: const Icon(Icons.chevron_right, size: 24),
                    onPressed: () => onDateChanged(1),
                    color: const Color(0xFF4A5568),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 2,
          color: const Color(0xFFE2E8F0),
        ),
      ],
    );
  }
}