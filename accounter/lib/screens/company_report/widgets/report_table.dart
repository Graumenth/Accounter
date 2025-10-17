import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';

class ReportTable extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final List<String> sortedDates;
  final Map<String, Map<int, int>> salesMap;
  final Map<int, int> itemTotals;

  const ReportTable({
    super.key,
    required this.items,
    required this.sortedDates,
    required this.salesMap,
    required this.itemTotals,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.md,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.1)),
          columns: [
            DataColumn(
              label: Text(
                'Tarih',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...items.map((item) => DataColumn(
              label: Text(
                item['name'],
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ],
          rows: [
            ...sortedDates.map((date) {
              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      DateFormat('dd.MM').format(DateTime.parse(date)),
                      style: AppTextStyles.body,
                    ),
                  ),
                  ...items.map((item) {
                    final quantity = salesMap[date]?[item['id'] as int] ?? 0;
                    return DataCell(
                      Text(
                        quantity > 0 ? quantity.toString() : '-',
                        style: AppTextStyles.body.copyWith(
                          color: quantity > 0 ? AppColors.primary : AppColors.textTertiary,
                          fontWeight: quantity > 0 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }),
                ],
              );
            }),
            DataRow(
              color: MaterialStateProperty.all(AppColors.backgroundSecondary),
              cells: [
                DataCell(
                  Text(
                    'TOPLAM',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...items.map((item) {
                  final total = itemTotals[item['id'] as int] ?? 0;
                  return DataCell(
                    Text(
                      total.toString(),
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}