import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/item.dart';
import '../../../services/database_service.dart';
import '../../../constants/app_colors.dart';
import '/l10n/app_localizations.dart';

class ItemDetailScreen extends StatefulWidget {
  final Item item;

  const ItemDetailScreen({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.item.name);
    priceController = TextEditingController(text: widget.item.basePriceTL.toStringAsFixed(2));
    selectedColor = Color(int.parse('0xFF${widget.item.color.substring(1)}'));
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> saveItem() async {
    if (nameController.text.trim().isEmpty) return;
    final price = double.tryParse(priceController.text);
    if (price == null || price <= 0) return;

    final updatedItem = Item(
      id: widget.item.id,
      name: nameController.text.trim(),
      basePriceCents: (price * 100).round(),
      color: '#${selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    );

    await DatabaseService.instance.updateItem(updatedItem);
  }

  Future<void> showColorPicker() async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = await showDialog<Color>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: Text(
          l10n.color,
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
      saveItem();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.item.name,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: isDark ? AppColors.darkSurface : AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: l10n.itemName,
                      border: const OutlineInputBorder(),
                    ),
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    onChanged: (value) {
                      if (value.trim().isNotEmpty) {
                        saveItem();
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: l10n.price,
                      border: const OutlineInputBorder(),
                      prefixText: '₺ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    onChanged: (value) {
                      final price = double.tryParse(value);
                      if (price != null && price > 0) {
                        saveItem();
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  InkWell(
                    onTap: showColorPicker,
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
                            l10n.color,
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
          ],
        ),
      ),
    );
  }
}