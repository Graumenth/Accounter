import 'package:flutter/material.dart';
import '../../../models/pending_sale.dart';
import '../../../models/item.dart';

class SalesList extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> savedSales;
  final List<PendingSale> pendingSales;
  final Function(int) onRemovePending;
  final Function(int, int) onUpdateQuantity;
  final Function(Item, int) onAddItem;

  const SalesList({
    super.key,
    required this.isLoading,
    required this.savedSales,
    required this.pendingSales,
    required this.onRemovePending,
    required this.onUpdateQuantity,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final allSales = [...savedSales];
    final hasSales = allSales.isNotEmpty || pendingSales.isNotEmpty;

    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (data) => data != null,
      onAcceptWithDetails: (details) {
        final data = details.data;
        onAddItem(data['item'] as Item, data['companyId'] as int);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: candidateData.isNotEmpty
              ? const Color(0xFF38A169).withOpacity(0.1)
              : const Color(0xFFF7FAFC),
          child: !hasSales
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
            itemCount: allSales.length + pendingSales.length,
            itemBuilder: (context, index) {
              if (index < allSales.length) {
                return _SavedSaleItem(sale: allSales[index]);
              } else {
                final pendingIndex = index - allSales.length;
                return _PendingSaleItem(
                  sale: pendingSales[pendingIndex],
                  onRemove: () => onRemovePending(pendingIndex),
                  onQuantityUpdate: (delta) => onUpdateQuantity(pendingIndex, delta),
                );
              }
            },
          ),
        );
      },
    );
  }
}

class _SavedSaleItem extends StatelessWidget {
  final Map<String, dynamic> sale;

  const _SavedSaleItem({required this.sale});

  @override
  Widget build(BuildContext context) {
    final itemTotal = (sale['quantity'] * sale['basePriceCents']) / 100;

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
                  '${sale['companyName']} • ${sale['quantity']} adet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
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

class _PendingSaleItem extends StatelessWidget {
  final PendingSale sale;
  final VoidCallback onRemove;
  final Function(int) onQuantityUpdate;

  const _PendingSaleItem({
    required this.sale,
    required this.onRemove,
    required this.onQuantityUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final itemTotal = sale.item.basePriceTL * sale.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: const Color(0xFFFFF8E1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFA726),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'BEKLEMEDE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        sale.item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1A202C),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${sale.item.basePriceTL.toStringAsFixed(2)} ₺',
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
                onPressed: () => onQuantityUpdate(-1),
                color: const Color(0xFFE53E3E),
                iconSize: 20,
              ),
              Text(
                '${sale.quantity}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onQuantityUpdate(1),
                color: const Color(0xFF38A169),
                iconSize: 20,
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
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onRemove,
            color: const Color(0xFFE53E3E),
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}