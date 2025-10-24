import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';
import '../../../models/item.dart';
import '../../../constants/app_colors.dart';

Future<dynamic> showItemDialog(
    BuildContext context, {
      Item? item,
      required String itemNameLabel,
      required String priceLabel,
      required String colorLabel,
      required String cancelLabel,
      required String saveLabel,
      String? deleteLabel,
      required String newItemLabel,
      required String editItemLabel,
    }) async {
  final formatter = NumberFormat('#,##0.00', 'tr_TR');
  final nameController = TextEditingController(text: item?.name ?? '');
  final priceController = TextEditingController(
    text: item != null ? formatter.format(item.basePriceTL) : '',
  );
  Color selectedColor = item != null
      ? Color(int.parse('0xFF${item.color.substring(1)}'))
      : const Color(0xFF38A169);

  final isEdit = item != null;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return await showDialog<dynamic>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: Text(
          isEdit ? editItemLabel : newItemLabel,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: itemNameLabel,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: priceLabel,
                  border: const OutlineInputBorder(),
                  prefixText: '₺ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              InkWell(
                onTap: () async {
                  final color = await showDialog<Color>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
                      title: Text(
                        colorLabel,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      content: SingleChildScrollView(
                        child: BlockPicker(
                          pickerColor: selectedColor,
                          onColorChanged: (color) {
                            Navigator.pop(context, color);
                          },
                        ),
                      ),
                    ),
                  );
                  if (color != null) {
                    setState(() => selectedColor = color);
                  }
                },
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          borderRadius: AppRadius.smRadius,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        colorLabel,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (isEdit && deleteLabel != null)
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: Text(
                deleteLabel,
                style: TextStyle(
                  color: isDark ? AppColors.darkError : AppColors.error,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              cancelLabel,
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty &&
                  priceController.text.trim().isNotEmpty) {
                final priceText = priceController.text.trim()
                    .replaceAll('.', '')
                    .replaceAll(',', '.');
                final price = double.tryParse(priceText);
                if (price != null) {
                  Navigator.pop(context, {
                    'name': nameController.text.trim(),
                    'priceCents': (price * 100).toInt(),
                    'color': '#${selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
            ),
            child: Text(
              saveLabel,
              style: const TextStyle(color: AppColors.surface),
            ),
          ),
        ],
      ),
    ),
  );
}