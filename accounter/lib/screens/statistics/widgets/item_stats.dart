import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ItemStats extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ItemStats({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: items.map((item) => _buildItemStat(context, l10n, item)).toList(),
    );
  }

  Widget _buildItemStat(BuildContext context, AppLocalizations l10n, Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final total = (item['total'] as int) / 100;
    final quantity = item['quantity'] as int;
    final color = Color(int.parse('0xFF${item['color'].toString().substring(1)}'));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity ${l10n.quantitySuffix}',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} ₺',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}