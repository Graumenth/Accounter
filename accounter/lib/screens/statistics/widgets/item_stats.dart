import 'package:flutter/material.dart';

class ItemStats extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ItemStats({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) => _buildItemStat(item)).toList(),
    );
  }

  Widget _buildItemStat(Map<String, dynamic> item) {
    final total = (item['total'] as int) / 100;
    final quantity = item['quantity'] as int;
    final color = Color(int.parse('0xFF${item['color'].toString().substring(1)}'));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity adet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF38A169),
            ),
          ),
        ],
      ),
    );
  }
}