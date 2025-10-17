import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import 'widgets/report_header.dart';
import 'widgets/report_summary.dart';
import 'widgets/report_table.dart';

class CompanyReportScreen extends StatefulWidget {
  final int companyId;
  final String companyName;
  final DateTime startDate;
  final DateTime endDate;

  const CompanyReportScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    required this.startDate,
    required this.endDate,
  });

  @override
  State<CompanyReportScreen> createState() => _CompanyReportScreenState();
}

class _CompanyReportScreenState extends State<CompanyReportScreen> {
  List<Map<String, dynamic>> reportData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReportData();
  }

  Future<void> loadReportData() async {
    setState(() => isLoading = true);
    reportData = await DatabaseService.instance.getCompanyReport(
      widget.companyId,
      widget.startDate,
      widget.endDate,
    );
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('Rapor Yükleniyor...'),
          backgroundColor: theme.colorScheme.surface,
        ),
        body: Center(
          child: CircularProgressIndicator(color: theme.colorScheme.primary),
        ),
      );
    }

    double totalRevenue = 0;
    double totalCost = 0;
    int totalQuantity = 0;

    for (var row in reportData) {
      totalRevenue += (row['total_revenue'] ?? 0.0) as double;
      totalCost += (row['total_cost'] ?? 0.0) as double;
      totalQuantity += (row['total_quantity'] ?? 0) as int;
    }

    final profit = totalRevenue - totalCost;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.companyName),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReportHeader(
              startDate: widget.startDate,
              endDate: widget.endDate,
            ),
            const SizedBox(height: 16),
            ReportSummary(
              totalRevenue: totalRevenue,
              totalCost: totalCost,
              profit: profit,
              totalQuantity: totalQuantity,
            ),
            const SizedBox(height: 16),
            ReportTable(reportData: reportData),
          ],
        ),
      ),
    );
  }
}