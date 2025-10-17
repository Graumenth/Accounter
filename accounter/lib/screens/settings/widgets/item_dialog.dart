import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  final nameController = TextEditingController(text: item?.name ?? '');
  final priceController = TextEditingController(
    text: item != null ? item.basePriceTL.toStringAsFixed(2) : '',
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
              if (nameController.text.trim().isEmpty) return;
              final price = double.tryParse(priceController.text);
              if (price == null || price <= 0) return;

              Navigator.pop(context, {
                'name': nameController.text.trim(),
                'priceCents': (price * 100).toInt(),
                'color': '#${selectedColor.toARGB32().toRadixString(16).substring(2).padLeft(6, '0')}',
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(saveLabel),
          ),
        ],
      ),
    ),
  );
}