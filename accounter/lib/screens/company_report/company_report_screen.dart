import 'package:flutter/material.dart';
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
    showModalBottomSheet(
      context: context,
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
                  color: AppColors.border,
                  borderRadius: AppRadius.smRadius,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  'Rapor Paylaş',
                  style: AppTextStyles.heading3,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: const Icon(
                    Icons.attach_money,
                    color: AppColors.primary,
                  ),
                ),
                title: const Text('Fiyatlarla Birlikte'),
                subtitle: const Text('Birim ve toplam fiyatlar dahil'),
                onTap: () {
                  Navigator.pop(context);
                  _exportPdf(includePrices: true);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: AppRadius.mdRadius,
                  ),
                  child: const Icon(
                    Icons.numbers,
                    color: AppColors.textSecondary,
                  ),
                ),
                title: const Text('Sadece Miktarlar'),
                subtitle: const Text('Fiyat bilgileri olmadan'),
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

    final items = reportData!['items'] as List<Map<String, dynamic>>;
    final dailySales = reportData!['dailySales'] as List<Map<String, dynamic>>;

    await PdfService.exportReport(
      companyName: widget.companyName,
      startDate: startDate,
      endDate: endDate,
      items: items,
      dailySales: dailySales,
      includePrices: includePrices,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.companyName,
          style: AppTextStyles.heading2,
        ),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
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
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Veri yok',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
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
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.share),
        label: const Text('Paylaş'),
      ),
    );
  }

  Widget _buildReport() {
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
              color: AppColors.textDisabled,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Bu şirket için satış yok',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
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
              'Detaylı Tablo',
              style: AppTextStyles.heading3,
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