import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../../models/item.dart';
import '../../../constants/app_colors.dart';

class SalesList extends StatelessWidget {
  final bool isLoading;
  final List<Map<String, dynamic>> sales;
  final Function(int, int) onUpdateQuantity;
  final Function(Item, int)? onAddItem;

  const SalesList({
    super.key,
    required this.isLoading,
    required this.sales,
    required this.onUpdateQuantity,
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
                  Icons.inbox_outlined,
                  size: 64,
                  color: AppColors.textDisabled,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Bu gün için satış yok',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: sales.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(sales[index]['id'].toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: AppColors.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.xl),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.surface,
                    size: 28,
                  ),
                ),
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Satışı Sil'),
                        content: const Text('Bu satışı silmek istediğinize emin misiniz?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('İptal'),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            child: const Text('Sil'),
                          ),
                        ],
                      );
                    },
                  );
                },
                onDismissed: (direction) {
                  onUpdateQuantity(sales[index]['id'], 0);
                },
                child: _SaleItem(
                  sale: sales[index],
                  onUpdateQuantity: onUpdateQuantity,
                ),
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
          color: AppColors.surface,
          child: Column(
            children: [
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'İptal',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Adet Seç',
                      style: AppTextStyles.heading3,
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Tamam',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
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
                        style: AppTextStyles.priceLarge,
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
    final itemColor = sale['itemColor'] != null
        ? Color(int.parse('0xFF${sale['itemColor'].toString().substring(1)}'))
        : AppColors.primary;

    final isTabletOrDesktop = MediaQuery.of(context).size.width >= 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: EdgeInsets.symmetric(
        horizontal: isTabletOrDesktop ? AppSpacing.xxl : AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          SizedBox(width: isTabletOrDesktop ? AppSpacing.lg : AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sale['itemName'],
                  style: AppTextStyles.bodyLarge,
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  sale['companyName'],
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () async {
                  if (quantity == 1) {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Satışı Sil'),
                          content: const Text('Bu satışı silmek istediğinize emin misiniz?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('İptal'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                              ),
                              child: const Text('Sil'),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirm == true) {
                      onUpdateQuantity(sale['id'], 0);
                    }
                  } else {
                    onUpdateQuantity(sale['id'], quantity - 1);
                  }
                },
                color: AppColors.error,
                iconSize: isTabletOrDesktop ? 28 : 24,
              ),
              GestureDetector(
                onTap: () => _showQuantityPicker(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTabletOrDesktop ? AppSpacing.lg : AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '$quantity',
                    style: AppTextStyles.price,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onUpdateQuantity(sale['id'], quantity + 1),
                color: AppColors.primary,
                iconSize: isTabletOrDesktop ? 28 : 24,
              ),
            ],
          ),
          SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: isTabletOrDesktop ? 110 : 90,
            child: Text(
              '${itemTotal.toStringAsFixed(2)} ₺',
              textAlign: TextAlign.right,
              style: AppTextStyles.price,
            ),
          ),
        ],
      ),
    );
  }
}