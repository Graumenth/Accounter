import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/l10n/app_localizations.dart';
import '../../../../constants/app_colors.dart';

class ReportHeader extends StatelessWidget {
  final String companyName;
  final DateTime startDate;
  final DateTime endDate;

  const ReportHeader({
    super.key,
    required this.companyName,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.lgRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            companyName,
            style: AppTextStyles.heading2.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.startDate,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dateFormat.format(startDate),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Icon(
                  Icons.arrow_forward,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.endDate,
                    style: AppTextStyles.caption.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    dateFormat.format(endDate),
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}