import 'package:flutter/material.dart';
import '../../models/company.dart';
import '../../models/company_item_price.dart';
import '../../services/database_service.dart';
import '../../l10n/app_localizations.dart';

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
    final theme = Theme.of(context);
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
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          '${item['name']} - ${l10n.customPrice}',
          style: TextStyle(color: theme.colorScheme.onSurface),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.basePrice}: ${((item['base_price_cents'] as int) / 100).toStringAsFixed(2)} ₺',
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
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
                labelStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
              keyboardType: TextInputType.number,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          if (hasCustomPrice)
            TextButton(
              onPressed: () => Navigator.pop(context, 'delete'),
              child: Text(
                l10n.returnToDefault,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: Text(l10n.save),
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
          SnackBar(
            content: Text(l10n.returnedToDefault),
            backgroundColor: theme.colorScheme.primary,
          ),
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
            SnackBar(
              content: Text(l10n.customPriceSaved),
              backgroundColor: theme.colorScheme.primary,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.company.name,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.primary,
        ),
      )
          : itemsWithPrices.isEmpty
          ? Center(
        child: Text(
          l10n.noItemsYet,
          style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
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
            color: theme.colorScheme.surface,
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
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
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
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
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        l10n.custom,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
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