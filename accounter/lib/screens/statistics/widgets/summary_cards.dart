import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> total;

  const SummaryCards({
    super.key,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
                '💰 ${l10n.total}',
                '${(totalAmount / 100).toStringAsFixed(2)} ₺',
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                '📦 ${l10n.quantity}',
                '$totalQuantity',
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                '🧾 ${l10n.sales}',
                '$totalSales',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                context,
                '📊 ${l10n.average}',
                totalSales > 0
                    ? '${(totalAmount / totalSales / 100).toStringAsFixed(2)} ₺'
                    : '0 ₺',
                Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, String value, Color color) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
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
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
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