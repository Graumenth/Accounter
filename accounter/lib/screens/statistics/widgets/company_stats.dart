import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../../constants/app_colors.dart';
import '../../../models/sale.dart';

class CompanyStats extends StatelessWidget {
  final List<Map<String, dynamic>> companies;
  final DateTime startDate;
  final DateTime endDate;

  const CompanyStats({
    super.key,
    required this.companies,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: companies.map((company) => _buildCompanyItem(context, company)).toList(),
    );
  }

  Widget _buildCompanyItem(BuildContext context, Map<String, dynamic> company) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = (company['total'] as int) / 100;
    final quantity = company['quantity'] as int;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/company-report',
          arguments: {
            'companyId': company['id'],
            'companyName': company['name'],
            'startDate': Sale.dateToString(startDate),
            'endDate': Sale.dateToString(endDate),
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.surface,
          borderRadius: AppRadius.lgRadius,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company['name'],
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
            Row(
              children: [
                Text(
                  '${total.toStringAsFixed(2)} ₺',
                  style: AppTextStyles.price.copyWith(
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}