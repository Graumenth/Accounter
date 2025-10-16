import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/company.dart';
import '../../models/company_item_price.dart';
import '../../services/database_service.dart';

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
  List<Map<String, dynamic>> itemsWithPrices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    setState(() => isLoading = true);
    itemsWithPrices = await DatabaseService.instance.getCompanyItemsWithPrices(widget.company.id!);
    setState(() => isLoading = false);
  }

  Future<void> showPriceDialog(Map<String, dynamic> item) async {
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
        title: Text('${item['name']} - Özel Fiyat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Varsayılan Fiyat: ${((item['base_price_cents'] as int) / 100).toStringAsFixed(2)} ₺',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Özel Fiyat (TL)',
                border: OutlineInputBorder(),
                prefixText: '₺ ',
              ),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          if (hasCustomPrice)
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: const Text('Varsayılana Dön', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result == 'delete') {
      await DatabaseService.instance.deleteCompanyItemPrice(
        widget.company.id!,
        item['id'],
      );
      loadItems();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Varsayılan fiyata döndürüldü')),
        );
      }
    } else if (result != null && result.isNotEmpty) {
      final price = double.tryParse(result);
      if (price != null) {
        final companyItemPrice = CompanyItemPrice(
          companyId: widget.company.id!,
          itemId: item['id'],
          customPriceCents: (price * 100).toInt(),
        );
        await DatabaseService.instance.setCompanyItemPrice(companyItemPrice);
        loadItems();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Özel fiyat kaydedildi')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.company.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : itemsWithPrices.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            SizedBox(height: AppSpacing.lg),
            const Text(
              'Henüz ürün yok',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.md),
        itemCount: itemsWithPrices.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = itemsWithPrices[index];
          final hasCustomPrice = item['custom_price_cents'] != null;
          final displayPrice = hasCustomPrice
              ? (item['custom_price_cents'] as int) / 100
              : (item['base_price_cents'] as int) / 100;
          final itemColor = Color(int.parse('0xFF${item['color'].toString().substring(1)}'));

          return Container(
            margin: EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.lgRadius,
            ),
            child: ListTile(
              leading: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: itemColor,
                  shape: BoxShape.circle,
                ),
              ),
              title: Text(
                item['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.xs),
                  if (hasCustomPrice)
                    Text(
                      'Varsayılan: ${((item['base_price_cents'] as int) / 100).toStringAsFixed(2)} ₺',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '${displayPrice.toStringAsFixed(2)} ₺',
                    style: TextStyle(
                      color: hasCustomPrice ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: hasCustomPrice ? FontWeight.w600 : FontWeight.normal,
                      fontSize: hasCustomPrice ? 16 : 14,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasCustomPrice)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: AppRadius.smRadius,
                      ),
                      child: const Text(
                        'Özel',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                ],
              ),
              onTap: () => showPriceDialog(item),
            ),
          );
        },
      ),
    );
  }
}