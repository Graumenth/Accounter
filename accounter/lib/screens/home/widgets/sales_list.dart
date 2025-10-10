import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../models/item.dart';

class SalesList extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> sales;
  final Function(int, int) onUpdateQuantity;
  final Function(Item, int) onAddItem;

  const SalesList({
    super.key,
    required this.isLoading,
    required this.sales,
    required this.onUpdateQuantity,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) => details.data['item'] != null && details.data['companyId'] != null,
      onAcceptWithDetails: (details) {
        final data = details.data;
        onAddItem(data['item'] as Item, data['companyId'] as int);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: candidateData.isNotEmpty
              ? const Color(0xFF38A169).withValues(alpha: 0.1)
              : const Color(0xFFF7FAFC),
          child: sales.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Bu gün için satış yok',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              return _SaleItem(
                sale: sales[index],
                onUpdateQuantity: onUpdateQuantity,
              );
            },
          ),
        );
      },
    );
  }
}

class _SaleItem extends StatelessWidget {
  final Map<String, dynamic> sale;
  final Function(int, int) onUpdateQuantity;

  const _SaleItem({
    required this.sale,
    required this.onUpdateQuantity,
  });

  void _showQuantityPicker(BuildContext context) {
    final currentQuantity = sale['quantity'] as int;
    int selectedQuantity = currentQuantity;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text('İptal'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Adet Seç',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      child: const Text('Tamam'),
                      onPressed: () {
                        onUpdateQuantity(sale['id'], selectedQuantity);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: currentQuantity - 1,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (int index) {
                    selectedQuantity = index + 1;
                  },
                  children: List.generate(
                    100,
                        (index) => Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final quantity = sale['quantity'] as int;
    final itemTotal = (quantity * sale['basePriceCents']) / 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale['itemName'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A202C),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  sale['companyName'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () => onUpdateQuantity(sale['id'], quantity - 1),
                color: const Color(0xFFE53E3E),
                iconSize: 24,
              ),
              GestureDetector(
                onTap: () => _showQuantityPicker(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onUpdateQuantity(sale['id'], quantity + 1),
                color: const Color(0xFF38A169),
                iconSize: 24,
              ),
            ],
          ),
          const SizedBox(width: 8),
          Text(
            '${itemTotal.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A202C),
            ),
          ),
        ],
      ),
    );
  }
}