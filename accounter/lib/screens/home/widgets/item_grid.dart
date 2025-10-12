import 'package:flutter/material.dart';
import '../../../models/item.dart';
import '../../../models/company.dart';

class ItemGrid extends StatelessWidget {
  final List<Company> companies;
  final List<Item> items;
  final Company? selectedCompany;
  final Function(Company?) onCompanyChanged;
  final VoidCallback onClose;
  final bool hideCompanySelector;
  final Function(Item, int) onAddItem;

  const ItemGrid({
    super.key,
    required this.companies,
    required this.items,
    required this.selectedCompany,
    required this.onCompanyChanged,
    required this.onClose,
    required this.onAddItem,
    this.hideCompanySelector = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: hideCompanySelector ? 200 : 240,
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 2,
            color: const Color(0xFFE2E8F0),
          ),
          if (!hideCompanySelector)
            Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: companies.isEmpty
                        ? const Text('Şirket yok')
                        : DropdownButtonFormField<Company>(
                      value: selectedCompany,
                      decoration: const InputDecoration(
                        labelText: 'Şirket',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: companies.map((company) {
                        return DropdownMenuItem(
                          value: company,
                          child: Text(company.name),
                        );
                      }).toList(),
                      onChanged: onCompanyChanged,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    color: const Color(0xFF4A5568),
                  ),
                ],
              ),
            ),
          if (hideCompanySelector)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF38A169).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF38A169)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.business, color: Color(0xFF38A169), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            selectedCompany?.name ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF38A169),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: onClose,
                    color: const Color(0xFF4A5568),
                  ),
                ],
              ),
            ),
          Expanded(
            child: items.isEmpty
                ? Center(
              child: Text(
                'Ayarlardan ürün ekleyin',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(12),
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisSpacing: 12,
                childAspectRatio: 0.7,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final itemColor = Color(int.parse('0xFF${item.color.substring(1)}'));

                return _DraggableItemCard(
                  item: item,
                  itemColor: itemColor,
                  selectedCompany: selectedCompany,
                  onAddItem: onAddItem,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DraggableItemCard extends StatelessWidget {
  final Item item;
  final Color itemColor;
  final Company? selectedCompany;
  final Function(Item, int) onAddItem;

  const _DraggableItemCard({
    required this.item,
    required this.itemColor,
    required this.selectedCompany,
    required this.onAddItem,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCompany == null) {
      return _buildItemCard();
    }

    return GestureDetector(
      onTap: () {
        onAddItem(item, selectedCompany!.id!);
      },
      child: LongPressDraggable<Map<String, dynamic>>(
        delay: const Duration(milliseconds: 75),
        hapticFeedbackOnStart: true,
        data: {
          'item': item,
          'companyId': selectedCompany!.id!,
        },
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 140,
            height: 100,
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.basePriceTL.toStringAsFixed(2)} ₺',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        childWhenDragging: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey[400]!,
              width: 2,
            ),
          ),
        ),
        child: _buildItemCard(),
      ),
    );
  }

  Widget _buildItemCard() {
    return Container(
      decoration: BoxDecoration(
        color: itemColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${item.basePriceTL.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}