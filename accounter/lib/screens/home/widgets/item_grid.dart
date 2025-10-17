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
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  color: AppColors.textSecondary,
                ),
              ],
            )
                : Row(
              children: [
                Expanded(
                  child: companies.isEmpty
                      ? Center(
                    child: const Text(
                      'Şirket yok',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  )
                      : DropdownButtonFormField<Company>(
                    value: selectedCompany,
                    decoration: const InputDecoration(
                      labelText: 'Şirket',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
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
                SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
              child: const Text(
                'Ayarlardan ürün ekleyin',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              scrollDirection: Axis.horizontal,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
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

class _DraggableItemCard extends StatefulWidget {
  final Item item;
  final Color itemColor;
  final Company? selectedCompany;
  final Function(Item) onAddItem;

  const _DraggableItemCard({
    required this.item,
    required this.itemColor,
    required this.selectedCompany,
    required this.onAddItem,
  });

  @override
  State<_DraggableItemCard> createState() => _DraggableItemCardState();
}

class _DraggableItemCardState extends State<_DraggableItemCard> {
  int? customPriceCents;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomPrice();
  }

  @override
  void didUpdateWidget(_DraggableItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedCompany?.id != widget.selectedCompany?.id) {
      _loadCustomPrice();
    }
  }

  Future<void> _loadCustomPrice() async {
    if (widget.selectedCompany != null) {
      setState(() => isLoading = true);
      final priceCents = await DatabaseService.instance.getCompanyItemPrice(
        widget.selectedCompany!.id!,
        widget.item.id!,
      );
      if (mounted) {
        setState(() {
          customPriceCents = priceCents;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        customPriceCents = null;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selectedCompany == null) {
      return _buildItemCard();
    }

    return GestureDetector(
      onTap: () {
        widget.onAddItem(widget.item);
      },
      child: LongPressDraggable<Map<String, dynamic>>(
        delay: const Duration(milliseconds: 75),
        hapticFeedbackOnStart: true,
        data: {
          'item': widget.item,
          'companyId': widget.selectedCompany!.id!,
        },
        feedback: Material(
          elevation: 8,
          borderRadius: AppRadius.lgRadius,
          child: Container(
            width: 140,
            height: 100,
            decoration: BoxDecoration(
              color: widget.itemColor,
              borderRadius: AppRadius.lgRadius,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.item.name,
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${_getDisplayPrice().toStringAsFixed(2)} ₺',
                  style: TextStyle(
                    color: AppColors.surface.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        childWhenDragging: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: AppRadius.lgRadius,
            border: Border.all(
              color: AppColors.border,
              width: 2,
            ),
          ),
        ),
        child: _buildItemCard(),
      ),
    );
  }

  double _getDisplayPrice() {
    if (customPriceCents != null) {
      return customPriceCents! / 100;
    }
    return widget.item.basePriceTL;
  }

  Widget _buildItemCard() {
    final displayPrice = _getDisplayPrice();
    final hasCustomPrice = customPriceCents != null;

    return Container(
      decoration: BoxDecoration(
        color: widget.itemColor,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.item.name,
            style: const TextStyle(
              color: AppColors.surface,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
          if (hasCustomPrice && widget.selectedCompany != null) ...[
            Text(
              '${widget.item.basePriceTL.toStringAsFixed(2)} ₺',
              style: TextStyle(
                color: AppColors.surface.withOpacity(0.5),
                fontSize: 10,
                decoration: TextDecoration.lineThrough,
              ),
            ),
            Text(
              '${displayPrice.toStringAsFixed(2)} ₺',
              style: const TextStyle(
                color: AppColors.surface,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else
            Text(
              '${displayPrice.toStringAsFixed(2)} ₺',
              style: TextStyle(
                color: AppColors.surface.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}