import 'package:flutter/material.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> total;

  const SummaryCards({
    super.key,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = (total['totalAmount'] ?? 0) as int;
    final totalQuantity = (total['totalQuantity'] ?? 0) as int;
    final totalSales = (total['totalSales'] ?? 0) as int;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                '💰 Toplam',
                '${(totalAmount / 100).toStringAsFixed(2)} ₺',
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                '📦 Adet',
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
                '🧾 Satış',
                '$totalSales',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                '📊 Ortalama',
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

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              color: Colors.grey[600],
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