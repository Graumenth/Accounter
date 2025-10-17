import 'package:flutter/material.dart';

class ItemStats extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const ItemStats({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          final name = item['name'] as String;
          final quantity = item['total_quantity'] as int;
          final revenue = item['total_revenue'] as int;
          final itemColor = Color(
            int.parse('0xFF${(item['color'] as String).substring(1)}'),
          );

          return ListTile(
            leading: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: itemColor,
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A202C),
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF38A169).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$quantity adet',
                      style: const TextStyle(
                        color: Color(0xFF38A169),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            trailing: Text(
              '${(revenue / 100).toStringAsFixed(2)} ₺',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C),
              ),
            ),
          );
        },
      ),
    );
  }
}