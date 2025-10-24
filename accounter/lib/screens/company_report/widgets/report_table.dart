import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '/l10n/app_localizations.dart';

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

  static String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'tr_TR');
    return '${formatter.format(amount)} ₺';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppShadows.md,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderRow(context),
            ...sortedDates.map((date) => _buildDateRow(context, date)),
            _buildTotalRow(context),
            _buildPriceRow(context),
            _buildTotalPriceRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkPrimary : AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.lg),
          topRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          _buildCell(context, l10n.date, width: 100, isHeader: true),
          ...items.map((item) => _buildCell(
            context,
            item['name'],
            isHeader: true,
          )),
        ],
      ),
    );
  }

  Widget _buildDateRow(BuildContext context, String date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildCell(context, _formatDate(date), width: 100),
          ...items.map((item) {
            final quantity = salesMap[date]?[item['id'] as int] ?? 0;
            return _buildCell(
              context,
              quantity > 0 ? quantity.toString() : '-',
              isHighlighted: quantity > 0,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 2,
          ),
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildCell(context, l10n.total, width: 100, isBold: true),
          ...items.map((item) {
            final total = itemTotals[item['id'] as int] ?? 0;
            return _buildCell(context, total.toString(), isBold: true);
          }),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildCell(context, l10n.unitPrice, width: 100, isBold: true),
          ...items.map((item) {
            final price = item['avg_unit_price'] as double;
            return _buildCell(context, _formatCurrency(price));
          }),
        ],
      ),
    );
  }

  Widget _buildTotalPriceRow(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.lg),
          bottomRight: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          _buildCell(context, l10n.totalPrice, width: 100, isBold: true),
          ...items.map((item) {
            final total = itemTotals[item['id'] as int] ?? 0;
            final price = item['avg_unit_price'] as double;
            final totalPrice = total * price;
            return _buildCell(
              context,
              _formatCurrency(totalPrice),
              isBold: true,
              color: isDark ? AppColors.darkPrimary : AppColors.primary,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCell(
      BuildContext context,
      String text, {
        double width = 120,
        bool isBold = false,
        bool isHighlighted = false,
        bool isHeader = false,
        Color? color,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: isHeader
                ? (isDark ? AppColors.darkPrimary : AppColors.primary).withOpacity(0.3)
                : (isDark ? AppColors.darkBorder : AppColors.border),
          ),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold || isHeader ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
          color: isHeader
              ? AppColors.surface
              : (color ?? (isHighlighted
              ? (isDark ? AppColors.darkPrimary : AppColors.primary)
              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary))),
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