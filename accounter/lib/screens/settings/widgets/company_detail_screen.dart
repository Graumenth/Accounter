import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../models/company.dart';
import '../../../models/item.dart';
import '../../../models/company_item_price.dart';
import '../../../services/database_service.dart';
import '../../../constants/app_colors.dart';
import '/l10n/app_localizations.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Company company;

  const CompanyDetailScreen({
    super.key,
    required this.company,
  });

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late TextEditingController nameController;
  late Color selectedColor;
  List<Map<String, dynamic>> itemsWithPrices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.company.name);
    selectedColor = Color(int.parse('0xFF${widget.company.color.substring(1)}'));
    loadItems();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);
    itemsWithPrices = await DatabaseService.instance.getCompanyItemsWithPrices(widget.company.id!);
    setState(() => isLoading = false);
  }

  Future<void> saveCompany() async {
    if (nameController.text.trim().isEmpty) return;

    final updatedCompany = Company(
      id: widget.company.id,
      name: nameController.text.trim(),
      color: '#${selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2)}',
    );

    await DatabaseService.instance.updateCompany(updatedCompany);
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
      saveCompany();
    }
  }

  Future<void> showPriceDialog(Map<String, dynamic> item) async {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCustomPrice = item['custom_price_cents'] != null;
    final currentPrice = hasCustomPrice
        ? (item['custom_price_cents'] as int) / 100
        : (item['base_price_cents'] as int) / 100;

    final controller = TextEditingController(
      text: currentPrice.toStringAsFixed(2),
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        title: Text(
          '${item['name']} - ${l10n.customPrice}',
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.basePrice}: ${((item['base_price_cents'] as int) / 100).toStringAsFixed(2)} ₺',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '${l10n.customPrice} (TL)',
                border: const OutlineInputBorder(),
                prefixText: '₺ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          if (hasCustomPrice)
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: Text(
                l10n.returnToDefault,
                style: TextStyle(
                  color: isDark ? AppColors.darkError : AppColors.error,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (result == 'delete') {
      await DatabaseService.instance.deleteCompanyItemPrice(
        widget.company.id!,
        item['item_id'] as int,
      );
      await loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.returnedToDefault)),
        );
      }
    } else if (result != null && result.isNotEmpty) {
      final price = double.tryParse(result);
      if (price != null && price > 0) {
        final companyItemPrice = CompanyItemPrice(
          companyId: widget.company.id!,
          itemId: item['item_id'] as int,
          customPriceCents: (price * 100).toInt(),
        );
        await DatabaseService.instance.setCompanyItemPrice(companyItemPrice);
        await loadItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.customPriceSaved)),
          );
        }
      }
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
          widget.company.name,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
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
                    labelText: l10n.companyName,
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  onChanged: (value) {
                    if (value.trim().isNotEmpty) {
                      saveCompany();
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
          Container(
            height: 8,
            color: isDark ? AppColors.darkBackground : AppColors.background,
          ),
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            )
                : itemsWithPrices.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.textDisabled,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noItemsYet,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: itemsWithPrices.length,
              itemBuilder: (context, index) {
                final item = itemsWithPrices[index];
                final hasCustomPrice = item['custom_price_cents'] != null;
                final displayPrice = hasCustomPrice
                    ? (item['custom_price_cents'] as int) / 100
                    : (item['base_price_cents'] as int) / 100;
                final basePrice = (item['base_price_cents'] as int) / 100;
                final itemColor = Color(int.parse('0xFF${item['item_color'].toString().substring(1)}'));
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
                              item['name'],
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs),
                            Text(
                              '${l10n.basePrice}: ${basePrice.toStringAsFixed(2)} ₺',
                              style: AppTextStyles.bodySecondary.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final l10n = AppLocalizations.of(context)!;
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
                                      pickerColor: itemColor,
                                      onColorChanged: (color) {
                                        Navigator.pop(context, color);
                                      },
                                    ),
                                  ),
                                ),
                              );

                              if (color != null) {
                                final colorHex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
                                await DatabaseService.instance.updateItem(
                                  Item(
                                    id: item['item_id'] as int,
                                    name: item['name'],
                                    basePriceCents: item['base_price_cents'] as int,
                                    color: colorHex,
                                  ),
                                );
                                await loadItems();
                              }
                            },
                            child: Container(
                              width: isTabletOrDesktop ? 40 : 36,
                              height: isTabletOrDesktop ? 40 : 36,
                              decoration: BoxDecoration(
                                color: itemColor,
                                borderRadius: AppRadius.mdRadius,
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.border,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: AppSpacing.sm),
                          GestureDetector(
                            onTap: () => showPriceDialog(item),
                            child: Container(
                              width: isTabletOrDesktop ? 120 : 100,
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
                                '${displayPrice.toStringAsFixed(2)} ₺',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.price.copyWith(
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}