import 'package:flutter/material.dart';
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
                color: Color(0xFF4A5568),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
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
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.company.name,
          style: const TextStyle(
            color: Color(0xFF1A202C),
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
            const SizedBox(height: 16),
            const Text(
              'Henüz ürün yok',
              style: TextStyle(
                color: Color(0xFF4A5568),
                fontSize: 16,
              ),
            ),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itemsWithPrices.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = itemsWithPrices[index];
          final hasCustomPrice = item['custom_price_cents'] != null;
          final displayPrice = hasCustomPrice
              ? (item['custom_price_cents'] as int) / 100
              : (item['base_price_cents'] as int) / 100;
          final itemColor = Color(int.parse('0xFF${item['color'].toString().substring(1)}'));

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                  const SizedBox(height: 4),
                  if (hasCustomPrice)
                    Text(
                      'Varsayılan: ${((item['base_price_cents'] as int) / 100).toStringAsFixed(2)} ₺',
                      style: const TextStyle(
                        color: Color(0xFF4A5568),
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    '${displayPrice.toStringAsFixed(2)} ₺',
                    style: TextStyle(
                      color: hasCustomPrice ? const Color(0xFF38A169) : const Color(0xFF4A5568),
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
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38A169).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Özel',
                        style: TextStyle(
                          color: Color(0xFF38A169),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Color(0xFF4A5568)),
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