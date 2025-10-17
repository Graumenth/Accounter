import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> total;

  const SummaryCards({
    super.key,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final totalAmount = (total['totalAmount'] ?? 0) as int;
    final totalQuantity = (total['totalQuantity'] ?? 0) as int;
    final totalSales = (total['totalSales'] ?? 0) as int;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                l10n.total,
                '${(totalAmount / 100).toStringAsFixed(2)} ₺',
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSummaryCard(
                context,
                l10n.quantity,
                '$totalQuantity',
                const Color(0xFF3B82F6),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                l10n.sales,
                '$totalSales',
                const Color(0xFFF97316),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildSummaryCard(
                context,
                l10n.average,
                totalSales > 0
                    ? '${(totalAmount / totalSales / 100).toStringAsFixed(2)} ₺'
                    : '0 ₺',
                const Color(0xFFA855F7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}