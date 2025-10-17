import 'package:flutter/material.dart';
import '../../../models/item.dart';

class ItemStats extends StatelessWidget {
  final Item item;
  final int quantity;
  final double totalRevenue;
  final double totalCost;

  const ItemStats({
    super.key,
    required this.item,
    required this.quantity,
    required this.totalRevenue,
    required this.totalCost,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemColor = Color(int.parse(item.color.replaceFirst('#', '0xFF')));
    final profit = totalRevenue - totalCost;

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
                    color: itemColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildColumn(theme, 'Adet', quantity.toString()),
                _buildColumn(theme, 'Toplam Ciro', '${totalRevenue.toStringAsFixed(2)} ₺'),
                _buildColumn(theme, 'Kar', '${profit.toStringAsFixed(2)} ₺', profit >= 0 ? theme.colorScheme.primary : theme.colorScheme.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumn(ThemeData theme, String label, String value, [Color? valueColor]) {
    return Column(
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
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}