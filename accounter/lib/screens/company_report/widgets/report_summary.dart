import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';

class ReportSummary extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Map<int, int> itemTotals;

  const ReportSummary({
    super.key,
    required this.items,
    required this.itemTotals,
  });

  @override
  Widget build(BuildContext context) {
    int grandTotal = 0;
    int totalQuantity = 0;

    for (var item in items) {
      final qty = itemTotals[item['id'] as int] ?? 0;
      final price = item['avg_unit_price'] as double;
      grandTotal += (qty * price * 100).toInt();
      totalQuantity += qty;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.md,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toplam Adet',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalQuantity.toString(),
                    style: AppTextStyles.heading2,
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Genel Toplam',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(grandTotal / 100).toStringAsFixed(2)} ₺',
                    style: AppTextStyles.priceLarge.copyWith(
                      color: AppColors.primary,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}