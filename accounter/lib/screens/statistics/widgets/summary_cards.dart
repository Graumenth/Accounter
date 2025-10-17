import 'package:flutter/material.dart';

class SummaryCards extends StatelessWidget {
  final double totalRevenue;
  final double totalCost;
  final double totalProfit;
  final int totalSales;

  const SummaryCards({
    super.key,
    required this.totalRevenue,
    required this.totalCost,
    required this.totalProfit,
    required this.totalSales,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildCard(theme, 'Toplam Satış', totalSales.toString(), Icons.shopping_cart, theme.colorScheme.primary),
        _buildCard(theme, 'Toplam Ciro', '${totalRevenue.toStringAsFixed(2)} ₺', Icons.attach_money, theme.colorScheme.primary),
        _buildCard(theme, 'Toplam Maliyet', '${totalCost.toStringAsFixed(2)} ₺', Icons.money_off, theme.colorScheme.error),
        _buildCard(theme, 'Kar', '${totalProfit.toStringAsFixed(2)} ₺', Icons.trending_up, totalProfit >= 0 ? theme.colorScheme.primary : theme.colorScheme.error),
      ],
    );
  }

  Widget _buildCard(ThemeData theme, String title, String value, IconData icon, Color color) {
    return Card(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Icon(icon, size: 20, color: color),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}