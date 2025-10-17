import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DailyChart extends StatelessWidget {
  final List<Map<String, dynamic>> daily;

  const DailyChart({
    super.key,
    required this.daily,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final maxValue = daily.fold<int>(0, (max, day) {
      final total = day['total'] as int;
      return total > max ? total : max;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: daily.map((day) => _buildDayBar(theme, day, maxValue)).toList(),
      ),
    );
  }

  Widget _buildDayBar(ThemeData theme, Map<String, dynamic> day, int maxValue) {
    final date = day['date'] as String;
    final total = (day['total'] as int) / 100;
    final percentage = maxValue > 0 ? (day['total'] as int) / maxValue : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              DateFormat('dd MMM').format(DateTime.parse(date)),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '${total.toStringAsFixed(2)} ₺',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}