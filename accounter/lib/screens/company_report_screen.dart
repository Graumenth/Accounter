import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/sale.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';

class CompanyReportScreen extends StatefulWidget {
  final int companyId;
  final String companyName;

  const CompanyReportScreen({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  State<CompanyReportScreen> createState() => _CompanyReportScreenState();
}

class _CompanyReportScreenState extends State<CompanyReportScreen> {
  Map<String, dynamic>? reportData;
  bool isLoading = true;
  DateTime startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
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

  Future<void> exportTableAsPdf() async {
    if (reportData == null) return;

    final pdf = pw.Document();
    final items = reportData!['items'] as List<Map<String, dynamic>>;
    final dailySales = reportData!['dailySales'] as List<Map<String, dynamic>>;

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

    final tableHeaders = ['Tarih'] + items.map((item) => item['name'].toString()).toList();
    final tableRows = <List<String>>[];
    for (final date in sortedDates) {
      final row = <String>[];
      row.add(DateFormat('dd.MM.yyyy').format(DateTime.parse(date)));
      for (final item in items) {
        final quantity = salesMap[date]?[item['id'] as int] ?? 0;
        row.add(quantity > 0 ? quantity.toString() : '-');
      }
      tableRows.add(row);
    }

    final totalRow = ['Toplam Birim'] +
        items.map((item) => (itemTotals[item['id'] as int] ?? 0).toString()).toList();
    final priceRow = ['Birim Fiyat'] +
        items
            .map((item) => '₺${((item['base_price_cents'] as int) / 100).toStringAsFixed(2)}')
            .toList();
    final totalPriceRow = [
      'Toplam Fiyat'
    ]..addAll(items.map((item) {
      final total = itemTotals[item['id'] as int] ?? 0;
      final price = (item['base_price_cents'] as int) / 100;
      final totalPrice = total * price;
      return '₺${totalPrice.toStringAsFixed(2)}';
    }));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Text(widget.companyName, style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 16),
          pw.Table.fromTextArray(
            headers: tableHeaders,
            data: tableRows,
            cellAlignment: pw.Alignment.center,
          ),
          pw.Table.fromTextArray(
            headers: tableHeaders,
            data: [totalRow],
            cellAlignment: pw.Alignment.center,
          ),
          pw.Table.fromTextArray(
            headers: tableHeaders,
            data: [priceRow],
            cellAlignment: pw.Alignment.center,
          ),
          pw.Table.fromTextArray(
            headers: tableHeaders,
            data: [totalPriceRow],
            cellAlignment: pw.Alignment.center,
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/rapor.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: '${widget.companyName} Satış Raporu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.companyName,
          style: const TextStyle(
            color: Color(0xFF1A202C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : reportData == null
          ? const Center(child: Text('Veri yok'))
          : _buildReport(),
      floatingActionButton: reportData == null
          ? null
          : FloatingActionButton(
        onPressed: exportTableAsPdf,
        backgroundColor: const Color(0xFF38A169),
        child: const Icon(Icons.share),
        heroTag: "shareCompanyReport",
      ),
    );
  }

  Widget _buildReport() {
    final items = reportData!['items'] as List<Map<String, dynamic>>;
    final dailySales = reportData!['dailySales'] as List<Map<String, dynamic>>;

    if (items.isEmpty) {
      return const Center(
        child: Text('Bu şirket için satış yok'),
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
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTableHeader(items),
                ...sortedDates.map((date) => _buildTableRow(
                  date,
                  items,
                  salesMap[date] ?? {},
                )),
                _buildTotalRow(items, itemTotals),
                _buildPriceRow(items),
                _buildTotalPriceRow(items, itemTotals),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF38A169),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withAlpha((0.3).round())),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableRow(
      String date,
      List<Map<String, dynamic>> items,
      Map<int, int> daySales,
      ) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          _buildCell(
            DateFormat('dd.MM.yyyy').format(DateTime.parse(date)),
            width: 100,
            isBold: false,
          ),
          ...items.map((item) {
            final quantity = daySales[item['id'] as int] ?? 0;
            return _buildCell(
              quantity > 0 ? quantity.toString() : '-',
              isBold: false,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
      List<Map<String, dynamic>> items,
      Map<int, int> itemTotals,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        border: Border(
          top: BorderSide(color: Colors.grey[400]!, width: 2),
          bottom: BorderSide(color: Colors.grey[300]!),
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

  Widget _buildPriceRow(List<Map<String, dynamic>> items) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          _buildCell('Birim Fiyat', width: 100, isBold: true),
          ...items.map((item) {
            final price = (item['base_price_cents'] as int) / 100;
            return _buildCell('₺${price.toStringAsFixed(2)}', isBold: false);
          }),
        ],
      ),
    );
  }

  Widget _buildTotalPriceRow(
      List<Map<String, dynamic>> items,
      Map<int, int> itemTotals,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF38A169).withAlpha((0.1).round()),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
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
              color: const Color(0xFF38A169),
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
        Color? color,
      }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
          color: color ?? const Color(0xFF1A202C),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}