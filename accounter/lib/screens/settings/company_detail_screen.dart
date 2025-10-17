import 'package:flutter/material.dart';
import '../../models/company.dart';
import '../../models/company_item_price.dart';
import '../../services/database_service.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
        backgroundColor: Colors.white,
        title: Text(
          '${item['name']} - ${l10n.customPrice}',
          style: const TextStyle(color: Color(0xFF1A202C)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.basePrice}: ${((item['base_price_cents'] as int) / 100).toStringAsFixed(2)} ₺',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
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
            ),
          ],
        ),
        actions: [
          if (hasCustomPrice)
            TextButton(
              onPressed: () => Navigator.pop(context, 'reset'),
              child: Text(
                l10n.returnToDefault,
                style: const TextStyle(color: Color(0xFFE53E3E)),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38A169),
            ),
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (result == 'reset') {
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
        await DatabaseService.instance.setCompanyItemPrice(
          CompanyItemPrice(
            companyId: widget.company.id!,
            itemId: item['item_id'] as int,
            customPriceCents: (price * 100).round(),
          ),
        );
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
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF38A169),
        ),
      )
          : itemsWithPrices.isEmpty
          ? Center(
        child: Text(
          l10n.noItemsYet,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
          ),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: itemsWithPrices.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = itemsWithPrices[index];
          final itemColor = Color(int.parse(item['item_color'].replaceFirst('#', '0xFF')));
          final hasCustomPrice = item['custom_price_cents'] != null;
          final displayPrice = hasCustomPrice
              ? (item['custom_price_cents'] as int) / 100
              : (item['base_price_cents'] as int) / 100;

          return Card(
            color: Colors.white,
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
                  color: Color(0xFF1A202C),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    '${displayPrice.toStringAsFixed(2)} ₺',
                    style: TextStyle(
                      color: hasCustomPrice
                          ? const Color(0xFF38A169)
                          : const Color(0xFF9CA3AF),
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
                      child: Text(
                        l10n.custom,
                        style: const TextStyle(
                          color: Color(0xFF38A169),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9CA3AF),
                  ),
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