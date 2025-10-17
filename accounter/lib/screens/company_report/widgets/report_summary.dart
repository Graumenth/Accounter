import 'package:flutter/material.dart';

class ReportSummary extends StatelessWidget {
  final double totalRevenue;
  final double totalCost;
  final double profit;
  final int totalQuantity;

  const ReportSummary({
    super.key,
    required this.totalRevenue,
    required this.totalCost,
    required this.profit,
    required this.totalQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(theme, 'Toplam Adet', totalQuantity.toString()),
              _buildStat(theme, 'Toplam Ciro', '${totalRevenue.toStringAsFixed(2)} ₺', theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(theme, 'Toplam Maliyet', '${totalCost.toStringAsFixed(2)} ₺', theme.colorScheme.error),
              _buildStat(theme, 'Kar', '${profit.toStringAsFixed(2)} ₺', profit >= 0 ? theme.colorScheme.primary : theme.colorScheme.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(ThemeData theme, String label, String value, [Color? valueColor]) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}