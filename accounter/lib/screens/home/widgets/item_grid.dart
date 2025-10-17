import 'package:flutter/material.dart';
import '../../../models/item.dart';
import '../../../models/company.dart';
import '../../../constants/app_colors.dart';
import '../../../services/database_service.dart';

class ItemGrid extends StatelessWidget {
  final List<Company> companies;
  final List<Item> items;
  final Company? selectedCompany;
  final Function(Company?) onCompanyChanged;
  final VoidCallback onClose;
  final bool hideCompanySelector;
  final Function(Item) onAddItem;
  final String selectCompanyLabel;
  final String closeLabel;

  const ItemGrid({
    super.key,
    required this.companies,
    required this.items,
    required this.selectedCompany,
    required this.onCompanyChanged,
    required this.onClose,
    required this.onAddItem,
    required this.selectCompanyLabel,
    required this.closeLabel,
    this.hideCompanySelector = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTabletOrDesktop = MediaQuery.of(context).size.width >= 600;
    final gridHeight = isTabletOrDesktop ? 300.0 : 240.0;
    final crossAxisCount = isTabletOrDesktop ? 2 : 1;

    return Container(
      height: gridHeight,
      color: AppColors.surface,
      child: Column(
        children: [
          Container(
            height: 2,
            color: AppColors.divider,
          ),
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: hideCompanySelector
                ? Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: AppRadius.mdRadius,
                      border: Border.all(color: AppColors.primary),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.business,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            selectedCompany?.name ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            )
                : Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.mdRadius,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Company>(
                        value: selectedCompany,
                        isExpanded: true,
                        hint: Text(selectCompanyLabel),
                        items: companies.map((company) {
                          return DropdownMenuItem<Company>(
                            value: company,
                            child: Text(company.name),
                          );
                        }).toList(),
                        onChanged: onCompanyChanged,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedCompany == null
                ? Center(
              child: Text(
                selectCompanyLabel,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 3,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Draggable<Map<String, dynamic>>(
                  data: {
                    'item': item,
                    'companyId': selectedCompany!.id!,
                  },
                  feedback: Material(
                    elevation: 4,
                    borderRadius: AppRadius.mdRadius,
                    child: _ItemCard(item: item, isDragging: true),
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: _ItemCard(item: item),
                  ),
                  child: GestureDetector(
                    onTap: () => onAddItem(item),
                    child: _ItemCard(item: item),
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

class _ItemCard extends StatelessWidget {
  final Item item;
  final bool isDragging;

  const _ItemCard({
    required this.item,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = Color(int.parse(item.color.replaceFirst('#', '0xFF')));

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: itemColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: itemColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${item.basePriceTL.toStringAsFixed(2)} ₺',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}