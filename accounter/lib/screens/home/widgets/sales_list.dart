import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../models/item.dart';
import '../../../constants/app_colors.dart';

class SalesList extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> sales;
  final Function(int, int) onUpdateQuantity;
  final Function(Item, int)? onAddItem;
  final String noSalesText;
  final String dragItemText;

  const SalesList({
    super.key,
    required this.isLoading,
    required this.sales,
    required this.onUpdateQuantity,
    required this.noSalesText,
    required this.dragItemText,
    this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    return DragTarget<Map<String, dynamic>>(
      onWillAcceptWithDetails: (details) =>
      onAddItem != null &&
          details.data['item'] != null &&
          details.data['companyId'] != null,
      onAcceptWithDetails: (details) {
        if (onAddItem != null) {
          final data = details.data;
          onAddItem!(data['item'] as Item, data['companyId'] as int);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          color: candidateData.isNotEmpty
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.background,
          child: sales.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: AppSpacing.md),
                Text(
                  noSalesText,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                if (onAddItem != null) ...[
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    dragItemText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              return _SaleCard(
                sale: sale,
                onUpdateQuantity: onUpdateQuantity,
              );
            },
          ),
        );
      },
    );
  }
}

class _SaleCard extends StatelessWidget {
  final Map<String, dynamic> sale;
  final Function(int, int) onUpdateQuantity;

  const _SaleCard({
    required this.sale,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = Color(int.parse(sale['itemColor'].toString().replaceFirst('#', '0xFF')));
    final companyColor = Color(int.parse(sale['companyColor'].toString().replaceFirst('#', '0xFF')));
    final saleId = sale['id'] as int;
    final quantity = sale['quantity'] as int;
    final unitPrice = sale['unit_price'] as double;
    final totalPrice = quantity * unitPrice;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 80,
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sale['itemName'],
                          style: AppTextStyles.bodyLarge,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: companyColor.withOpacity(0.1),
                          borderRadius: AppRadius.smRadius,
                          border: Border.all(color: companyColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          sale['companyName'],
                          style: TextStyle(
                            fontSize: 12,
                            color: companyColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${unitPrice.toStringAsFixed(2)} ₺',
                        style: AppTextStyles.caption,
                      ),
                      Text(
                        '${totalPrice.toStringAsFixed(2)} ₺',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 100,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => onUpdateQuantity(saleId, quantity + 1),
                  child: const Icon(
                    Icons.add_circle,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => onUpdateQuantity(saleId, quantity - 1),
                  child: Icon(
                    quantity > 1 ? Icons.remove_circle : Icons.delete,
                    color: quantity > 1 ? AppColors.warning : AppColors.error,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}