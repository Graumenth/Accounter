import 'package:flutter/material.dart';
import '../../../models/company.dart';

class CompanyStats extends StatelessWidget {
  final Company company;
  final double totalRevenue;
  final double totalCost;
  final double profit;

  const CompanyStats({
    super.key,
    required this.company,
    required this.totalRevenue,
    required this.totalCost,
    required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final companyColor = Color(int.parse(company.color.replaceFirst('#', '0xFF')));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: companyColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    company.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStatRow(theme, 'Toplam Ciro:', '${totalRevenue.toStringAsFixed(2)} ₺', theme.colorScheme.primary),
            const SizedBox(height: 8),
            _buildStatRow(theme, 'Toplam Maliyet:', '${totalCost.toStringAsFixed(2)} ₺', theme.colorScheme.error),
            const SizedBox(height: 8),
            Container(
              height: 1,
              color: theme.dividerColor,
              margin: const EdgeInsets.symmetric(vertical: 8),
            ),
            _buildStatRow(theme, 'Kar:', '${profit.toStringAsFixed(2)} ₺', profit >= 0 ? theme.colorScheme.primary : theme.colorScheme.error),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(ThemeData theme, String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}