import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../../../constants/app_colors.dart';

class ReportSummary extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Map<int, int> itemTotals;

  const ReportSummary({
    super.key,
    required this.items,
    required this.itemTotals,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double grandTotal = 0;
    for (var item in items) {
      final total = itemTotals[item['id'] as int] ?? 0;
      final price = item['avg_unit_price'] as double;
      grandTotal += total * price;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkPrimary, AppColors.darkPrimary]
              : [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.2),
                  borderRadius: AppRadius.mdRadius,
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.surface,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.grandTotal,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${items.length} ${l10n.items}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.surface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Text(
            '₺${grandTotal.toStringAsFixed(2)}',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.surface,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }
}