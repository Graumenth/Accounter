import 'package:flutter/material.dart';
import '../../../models/item.dart';
import '../../../constants/app_colors.dart';
import 'item_detail_screen.dart';
import '/l10n/app_localizations.dart';

class ItemList extends StatelessWidget {
  final List<Item> items;
  final Function(Item) onEdit;
  final VoidCallback onRefresh;

  const ItemList({
    super.key,
    required this.items,
    required this.onEdit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (items.isEmpty) {
      return Center(
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
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final itemColor = Color(int.parse('0xFF${item.color.substring(1)}'));
        final isTabletOrDesktop = MediaQuery.of(context).size.width >= 600;

        return InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(item: item),
              ),
            );
            onRefresh();
          },
          child: Container(
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
                        item.name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        '${item.basePriceTL.toStringAsFixed(2)} ₺',
                        style: AppTextStyles.bodySecondary.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}