import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/company.dart';
import '../../../constants/app_colors.dart';

Future<dynamic> showCompanyDialog(
    BuildContext context, {
      Company? company,
      required String companyNameLabel,
      required String colorLabel,
      required String cancelLabel,
      required String saveLabel,
      String? deleteLabel,
      required String newCompanyLabel,
      required String editCompanyLabel,
    }) async {
  final nameController = TextEditingController(text: company?.name ?? '');
  Color selectedColor = company != null
      ? Color(int.parse('0xFF${company.color.substring(1)}'))
      : const Color(0xFF2563EB);

  final isEdit = company != null;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return await showDialog<dynamic>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: Text(
          isEdit ? editCompanyLabel : newCompanyLabel,
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
                  labelText: companyNameLabel,
                  border: const OutlineInputBorder(),
                ),
                autofocus: true,
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
              if (nameController.text.trim().isNotEmpty) {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'color': '#${selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
                });
              }
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