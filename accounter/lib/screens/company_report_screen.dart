import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../services/database_service.dart';
import '../../models/sale.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:pdf/pdf.dart';
import 'settings/widgets/profile_manager.dart';

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

  Future<void> exportTableAsPdf() async {
    if (reportData == null) return;

    final pdf = pw.Document();
    final items = reportData!['items'] as List<Map<String, dynamic>>;
    final dailySales = reportData!['dailySales'] as List<Map<String, dynamic>>;

    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

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

    final tableHeaders = ['Tarih', ...items.map((item) => item['name'].toString())];

    final tableData = <List<String>>[];
    for (final date in sortedDates) {
      final row = <String>[
        DateFormat('dd.MM.yyyy').format(DateTime.parse(date)),
        ...items.map((item) {
          final quantity = salesMap[date]?[item['id'] as int] ?? 0;
          return quantity > 0 ? quantity.toString() : '-';
        }),
      ];
      tableData.add(row);
    }

    tableData.add([
      'Toplam Birim',
      ...items.map((item) => (itemTotals[item['id'] as int] ?? 0).toString()),
    ]);
    tableData.add([
      'Birim Fiyat',
      ...items.map((item) => '₺${((item['base_price_cents'] as int) / 100).toStringAsFixed(2)}'),
    ]);
    tableData.add([
      'Toplam Fiyat',
      ...items.map((item) {
        final total = itemTotals[item['id'] as int] ?? 0;
        final price = (item['base_price_cents'] as int) / 100;
        return '₺${(total * price).toStringAsFixed(2)}';
      }),
    ]);

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${widget.companyName} Satış Raporu',
                style: pw.TextStyle(font: ttf, fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(),
                defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                children: [
                  // Header
                  pw.TableRow(
                    children: tableHeaders
                        .map((header) => pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(header, style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold)),
                    ))
                        .toList(),
                  ),
                  // Data Rows
                  ...tableData.map(
                        (row) => pw.TableRow(
                      children: row
                          .map((cell) => pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(cell, style: pw.TextStyle(font: ttf)),
                      ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final myCompanyName = await ProfileManager.getCompanyName();
    final shareDate = DateFormat('dd_MM_yyyy').format(DateTime.now());
    final fileName = '${myCompanyName}_${widget.companyName}_$shareDate.pdf'
        .replaceAll(' ', '_')
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'I')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C');

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    final params = ShareParams(
      files: [XFile(file.path)],
      subject: '${widget.companyName} Satış Raporu',
      text: 'Satış raporu ektedir.',
    );
    await SharePlus.instance.share(params);
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
          right: BorderSide(color: Colors.white.withAlpha(77)),
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
        color: const Color(0xFF38A169).withAlpha(25),
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
