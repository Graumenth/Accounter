import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';

class PeriodSelector extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const PeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              _buildPeriodButton(context, l10n.today, 'today'),
              const SizedBox(width: AppSpacing.sm),
              _buildPeriodButton(context, l10n.thisWeek, 'week'),
              const SizedBox(width: AppSpacing.sm),
              _buildPeriodButton(context, l10n.thisMonth, 'month'),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              _buildPeriodButton(context, l10n.thisYear, 'year'),
              const SizedBox(width: AppSpacing.sm),
              _buildPeriodButton(context, l10n.selectDate, 'custom', icon: Icons.calendar_today),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(BuildContext context, String label, String period, {IconData? icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = selectedPeriod == period;

    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () => onPeriodChanged(period),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
              : (isDark ? AppColors.darkSurface : AppColors.surface),
          foregroundColor: isSelected
              ? AppColors.surface
              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.mdRadius,
            side: BorderSide(
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : AppColors.primary)
                  : (isDark ? AppColors.darkBorder : AppColors.border),
            ),
          ),
        ),
        icon: icon != null ? Icon(icon, size: 18) : const SizedBox.shrink(),
        label: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }
}