import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';

class DailyChart extends StatelessWidget {
  final List<Map<String, dynamic>> daily;

  const DailyChart({
    super.key,
    required this.daily,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxValue = daily.fold<int>(0, (max, day) {
      final total = day['total'] as int;
      return total > max ? total : max;
    });

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.lgRadius,
      ),
      child: Column(
        children: daily.map((day) => _buildDayBar(context, day, maxValue)).toList(),
      ),
    );
  }

  Widget _buildDayBar(BuildContext context, Map<String, dynamic> day, int maxValue) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final date = day['date'] as String;
    final total = (day['total'] as int) / 100;
    final percentage = maxValue > 0 ? (day['total'] as int) / maxValue : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              DateFormat('dd MMM').format(DateTime.parse(date)),
              style: AppTextStyles.bodySecondary.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkPrimary : AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 80,
            child: Text(
              '${total.toStringAsFixed(2)} ₺',
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}