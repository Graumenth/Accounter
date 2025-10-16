import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';

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
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          ...sortedDates.map((date) => _buildTableRow(date)),
          _buildTotalRow(),
          _buildPriceRow(),
          _buildTotalPriceRow(),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('Tarih', width: 100),
          ...items.map((item) => _buildHeaderCell(item['name'] as String)),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {double width = 120}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.surface.withOpacity(0.3)),
        ),
      ),
      child: Text(
        text,
        style: AppTextStyles.body.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow(String date) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _buildCell(_formatDate(date), width: 100),
          ...items.map((item) {
            final quantity = salesMap[date]?[item['id'] as int] ?? 0;
            return _buildCell(
              quantity > 0 ? quantity.toString() : '-',
              isHighlighted: quantity > 0,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 2),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          _buildCell('Toplam Birim', width: 100, isBold: true),
          ...items.map((item) {
            final total = itemTotals[item['id'] as int] ?? 0;
            return _buildCell(total.toString(), isBold: true);
          }),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _buildCell('Birim Fiyat', width: 100, isBold: true),
          ...items.map((item) {
            final price = (item['base_price_cents'] as int) / 100;
            return _buildCell('₺${price.toStringAsFixed(2)}');
          }),
        ],
      ),
    );
  }

  Widget _buildTotalPriceRow() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.lg),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          _buildCell('Toplam Fiyat', width: 100, isBold: true),
          ...items.map((item) {
            final total = itemTotals[item['id'] as int] ?? 0;
            final price = (item['base_price_cents'] as int) / 100;
            final totalPrice = total * price;
            return _buildCell(
              '₺${totalPrice.toStringAsFixed(2)}',
              isBold: true,
              color: AppColors.primary,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCell(
      String text, {
        double width = 120,
        bool isBold = false,
        bool isHighlighted = false,
        Color? color,
      }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: AppColors.border),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
          color: color ?? (isHighlighted ? AppColors.primary : AppColors.textPrimary),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}