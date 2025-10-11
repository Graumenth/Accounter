import 'package:flutter/material.dart';
import '../../../models/item.dart';

class ItemList extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onEdit;

  const ItemList({
    super.key,
    required this.items,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Henüz ürün eklenmemiş',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        final itemColor = Color(int.parse('0xFF${item.color.substring(1)}'));
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
            item.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${item.basePriceTL.toStringAsFixed(2)} ₺',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF4A5568)),
          onTap: () => onEdit(item),
        );
      },
    );
  }
}