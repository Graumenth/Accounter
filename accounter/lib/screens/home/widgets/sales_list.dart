import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../models/item.dart';
import '../../../constants/app_colors.dart';
import '/l10n/app_localizations.dart';

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
    this.onAddItem,
    required this.noSalesText,
    required this.dragItemText,
  });

  static String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return '${formatter.format(amount)} ₺';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
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
              ? (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.1)
              : (isDark ? AppColors.darkBackground : AppColors.background),
          child: sales.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.textDisabled,
                ),
                SizedBox(height: AppSpacing.lg),
                Text(
                  noSalesText,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
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
                  color: isDark ? AppColors.darkError : AppColors.error,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: AppSpacing.xl),
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.surface,
                    size: 28,
                  ),
                ),
                confirmDismiss: (direction) async {
                  final l10n = AppLocalizations.of(context)!;
                  return await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(l10n.deleteSale),
                        content: Text(l10n.deleteSaleConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(l10n.cancel),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark ? AppColors.darkError : AppColors.error,
                            ),
                            child: Text(l10n.delete),
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
                  isDark: isDark,
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
  final bool isDark;

  const _SaleItem({
    required this.sale,
    required this.onUpdateQuantity,
    required this.isDark,
  });

  static String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return '${formatter.format(amount)} ₺';
  }

  void _showQuantityPicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentQuantity = sale['quantity'] as int;
    int selectedQuantity = currentQuantity;
    final textController = TextEditingController(text: currentQuantity.toString());
    final focusNode = FocusNode();

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
            final isKeyboardVisible = keyboardHeight > 0;

            focusNode.addListener(() {
              setState(() {});
            });

            return Padding(
              padding: EdgeInsets.only(bottom: keyboardHeight),
              child: Material(
                child: Container(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Text(
                                l10n.cancel,
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              onPressed: () {
                                focusNode.dispose();
                                Navigator.pop(context);
                              },
                            ),
                            Text(
                              l10n.quantity,
                              style: AppTextStyles.heading3.copyWith(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: Text(
                                l10n.save,
                                style: AppTextStyles.button.copyWith(
                                  color: isDark ? AppColors.darkPrimary : AppColors.primary,
                                ),
                              ),
                              onPressed: () {
                                final manualQuantity = int.tryParse(textController.text);
                                final finalQuantity = manualQuantity ?? selectedQuantity;
                                if (finalQuantity > 0) {
                                  onUpdateQuantity(sale['id'], finalQuantity);
                                  focusNode.dispose();
                                  Navigator.pop(context);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: TextField(
                          controller: textController,
                          focusNode: focusNode,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.priceLarge.copyWith(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.mdRadius,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mdRadius,
                              borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: AppRadius.mdRadius,
                              borderSide: BorderSide(color: isDark ? AppColors.darkPrimary : AppColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          ),
                          onChanged: (value) {
                            final newValue = int.tryParse(value);
                            if (newValue != null && newValue > 0) {
                              selectedQuantity = newValue;
                            }
                          },
                        ),
                      ),
                      if (!isKeyboardVisible)
                        Container(
                          height: 200,
                          child: CupertinoPicker(
                            scrollController: FixedExtentScrollController(
                              initialItem: currentQuantity - 1 < 9999 ? currentQuantity - 1 : 0,
                            ),
                            itemExtent: 40,
                            onSelectedItemChanged: (int index) {
                              selectedQuantity = index + 1;
                              textController.text = selectedQuantity.toString();
                            },
                            children: List.generate(
                              9999,
                                  (index) => Center(
                                child: Text(
                                  '${index + 1}',
                                  style: AppTextStyles.priceLarge.copyWith(
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final quantity = sale['quantity'] as int;
    final unitPrice = sale['unit_price'] as double;
    final itemTotal = quantity * unitPrice;
    final itemColor = sale['itemColor'] != null
        ? Color(int.parse('0xFF${sale['itemColor'].toString().substring(1)}'))
        : (isDark ? AppColors.darkPrimary : AppColors.primary);

    final isTabletOrDesktop = MediaQuery.of(context).size.width >= 600;

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: EdgeInsets.symmetric(
        horizontal: isTabletOrDesktop ? AppSpacing.xxl : AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      color: isDark ? AppColors.darkSurface : AppColors.surface,
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
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  sale['companyName'],
                  style: AppTextStyles.bodySecondary.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
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
                          title: Text(l10n.deleteSale),
                          content: Text(l10n.deleteSaleConfirm),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? AppColors.darkError : AppColors.error,
                              ),
                              child: Text(l10n.delete),
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
                color: isDark ? AppColors.darkError : AppColors.error,
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
                    color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
                    borderRadius: AppRadius.mdRadius,
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: Text(
                    '$quantity',
                    style: AppTextStyles.price.copyWith(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onUpdateQuantity(sale['id'], quantity + 1),
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
                iconSize: isTabletOrDesktop ? 28 : 24,
              ),
            ],
          ),
          SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: isTabletOrDesktop ? 110 : 90,
            child: Text(
              _formatCurrency(itemTotal),
              textAlign: TextAlign.right,
              style: AppTextStyles.price.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}