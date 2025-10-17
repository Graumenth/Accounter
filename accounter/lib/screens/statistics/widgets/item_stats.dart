import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';

class ItemStats extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ItemStats({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => _buildItemStat(context, item)).toList(),
    );
  }

  Widget _buildItemStat(BuildContext context, Map<String, dynamic> item) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = (item['total'] as int) / 100;
    final quantity = item['quantity'] as int;
    final color = Color(int.parse('0xFF${item['color'].toString().substring(1)}'));

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.lgRadius,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$quantity ${l10n.quantitySuffix}',
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} ₺',
            style: AppTextStyles.price.copyWith(
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}