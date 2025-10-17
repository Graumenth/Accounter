import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../../services/database_service.dart';
import '../../../services/pdf_service.dart';
import '../../../models/sale.dart';
import '../../../constants/app_colors.dart';
import 'widgets/report_header.dart';
import 'widgets/report_table.dart';
import 'widgets/report_summary.dart';

class CompanyReportScreen extends StatefulWidget {
  final int companyId;
  final String companyName;
  final String? startDate;
  final String? endDate;

  const CompanyReportScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    this.startDate,
    this.endDate,
  });

  @override
  State<CompanyReportScreen> createState() => _CompanyReportScreenState();
}

class _CompanyReportScreenState extends State<CompanyReportScreen> {
  Map<String, dynamic>? reportData;
  bool isLoading = true;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    super.initState();
    if (widget.startDate != null && widget.endDate != null) {
      startDate = Sale.stringToDate(widget.startDate!);
      endDate = Sale.stringToDate(widget.endDate!);
    } else {
      startDate = DateTime.now().subtract(const Duration(days: 30));
      endDate = DateTime.now();
    }
    loadReport();
  }

  Future<void> loadReport() async {
    setState(() => isLoading = true);

    final startStr = Sale.dateToString(startDate);
    final endStr = Sale.dateToString(endDate);

    reportData = await DatabaseService.instance.getCompanyMonthlyReport(
      widget.companyId,
      startStr,
      endStr,
    );

    setState(() => isLoading = false);
  }

  void _showShareMenu() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                  borderRadius: AppRadius.smRadius,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  l10n.share,
                  style: AppTextStyles.heading3.copyWith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkPrimary : AppColors.primary).withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Icon(
                    Icons.attach_money,
                    color: isDark ? AppColors.darkPrimary : AppColors.primary,
                  ),
                ),
                title: Text(
                  l10n.withPrices,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  l10n.usedInPdfReports,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _exportPdf(includePrices: true);
                },
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.divider,
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary).withValues(alpha: 0.1),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: Icon(
                    Icons.numbers,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                title: Text(
                  l10n.withoutPrices,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  l10n.withoutPrices,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _exportPdf(includePrices: false);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportPdf({required bool includePrices}) async {
    if (reportData == null) return;

    final l10n = AppLocalizations.of(context)!;
    final items = reportData!['items'] as List<Map<String, dynamic>>;
    final dailySales = reportData!['dailySales'] as List<Map<String, dynamic>>;

    await PdfService.exportReport(
      companyName: widget.companyName,
      startDate: startDate,
      endDate: endDate,
      items: items,
      dailySales: dailySales,
      includePrices: includePrices,
      locale: Localizations.localeOf(context).languageCode,
      translations: {
        'report': l10n.report,
        'date': l10n.date,
        'total': l10n.total,
        'unitPrice': l10n.unitPrice,
        'totalPrice': l10n.totalPrice,
        'grandTotal': l10n.grandTotal,
        'selectCompany': l10n.selectCompany,
        'withoutPrices': l10n.withoutPrices,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.companyName,
          style: AppTextStyles.heading2.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: isDark ? AppColors.darkPrimary : AppColors.primary,
        ),
      )
          : reportData == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.noData,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      )
          : _buildReport(),
      floatingActionButton: reportData == null
          ? null
          : FloatingActionButton.extended(
        onPressed: _showShareMenu,
        backgroundColor: isDark ? AppColors.darkPrimary : AppColors.primary,
        foregroundColor: AppColors.surface,
        icon: const Icon(Icons.share),
        label: Text(l10n.share),
      ),
    );
  }

  Widget _buildReport() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = reportData!['items'] as List<Map<String, dynamic>>;
    final dailySales = reportData!['dailySales'] as List<Map<String, dynamic>>;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_outlined,
              size: 64,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.noSales,
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    final dates = <String>{};
    for (var sale in dailySales) {
      dates.add(sale['date'] as String);
    }
    final sortedDates = dates.toList()..sort();

    final salesMap = <String, Map<int, int>>{};
    for (var sale in dailySales) {
      final date = sale['date'] as String;
      final itemId = sale['itemId'] as int;
      final quantity = sale['quantity'] as int;

      if (!salesMap.containsKey(date)) {
        salesMap[date] = {};
      }
      salesMap[date]![itemId] = quantity;
    }

    final itemTotals = <int, int>{};
    for (var item in items) {
      itemTotals[item['id'] as int] = 0;
    }
    for (var sale in dailySales) {
      final itemId = sale['itemId'] as int;
      final quantity = sale['quantity'] as int;
      itemTotals[itemId] = (itemTotals[itemId] ?? 0) + quantity;
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReportHeader(
              companyName: widget.companyName,
              startDate: startDate,
              endDate: endDate,
            ),
            const SizedBox(height: AppSpacing.xl),
            ReportSummary(
              items: items,
              itemTotals: itemTotals,
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.report,
              style: AppTextStyles.heading3.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ReportTable(
                items: items,
                sortedDates: sortedDates,
                salesMap: salesMap,
                itemTotals: itemTotals,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}