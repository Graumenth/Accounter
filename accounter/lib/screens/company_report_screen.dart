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

  Future<void> exportTableAsPdf({required bool includePrices}) async {
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

      salesMap.putIfAbsent(date, () => {});
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

    final myCompanyName = await ProfileManager.getCompanyName();
    final logoPath = await ProfileManager.getCompanyLogo();
    final now = DateTime.now();
    final shareDate = DateFormat('dd_MM_yyyy').format(now);
    final priceTag = includePrices ? '' : '_fiyatsiz';
    final fileName = '${myCompanyName}_${widget.companyName}_${shareDate}$priceTag.pdf'
        .replaceAll(' ', '_')
        .replaceAll('ı', 'i').replaceAll('İ', 'I')
        .replaceAll('ş', 's').replaceAll('Ş', 'S')
        .replaceAll('ğ', 'g').replaceAll('Ğ', 'G')
        .replaceAll('ü', 'u').replaceAll('Ü', 'U')
        .replaceAll('ö', 'o').replaceAll('Ö', 'O')
        .replaceAll('ç', 'c').replaceAll('Ç', 'C');

    pw.ImageProvider? logo;
    if (logoPath != null && logoPath.isNotEmpty) {
      final logoFile = File(logoPath);
      if (await logoFile.exists()) {
        final logoBytes = await logoFile.readAsBytes();
        logo = pw.MemoryImage(logoBytes);
      }
    }

    final table = pw.Table(
      border: pw.TableBorder(
        horizontalInside: const pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        verticalInside: const pw.BorderSide(color: PdfColors.grey300, width: 0.5),
      ),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColors.green700,
          ),
          children: [
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'TARİH',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),
            ...items.map((item) => pw.Container(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                item['name'].toString(),
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
            )),
          ],
        ),
        ...sortedDates.map((date) {
          final isEven = sortedDates.indexOf(date) % 2 == 0;
          return pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.grey50 : PdfColors.white,
            ),
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  DateFormat('dd.MM.yyyy').format(DateTime.parse(date)),
                  style: pw.TextStyle(font: ttf, fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              ...items.map((item) {
                final quantity = salesMap[date]?[item['id'] as int] ?? 0;
                return pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    quantity > 0 ? quantity.toString() : '-',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      fontWeight: quantity > 0 ? pw.FontWeight.bold : pw.FontWeight.normal,
                      color: quantity > 0 ? PdfColors.green700 : PdfColors.grey400,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                );
              }),
            ],
          );
        }),
      ],
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'SATIŞ RAPORU',
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 24,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green700,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Container(
                            width: 80,
                            height: 3,
                            color: PdfColors.green700,
                          ),
                          pw.SizedBox(height: 16),
                          pw.Text(
                            myCompanyName,
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (logo != null)
                      pw.Container(
                        width: 80,
                        height: 80,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                        ),
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Image(logo, fit: pw.BoxFit.contain),
                      ),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'MÜŞTERİ',
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 9,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            widget.companyName,
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'TARİH ARALIĞI',
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 9,
                              color: PdfColors.grey600,
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
                            style: pw.TextStyle(
                              font: ttf,
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 24),
          pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            ),
            child: pw.Column(
              children: [
                table,
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              border: pw.Border.all(color: PdfColors.grey300, width: 1),
            ),
            child: pw.Column(
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'TOPLAM BİRİM',
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.Row(
                      children: items.map((item) {
                        return pw.Container(
                          margin: const pw.EdgeInsets.only(left: 16),
                          child: pw.Column(
                            children: [
                              pw.Text(
                                item['name'].toString().length > 8
                                    ? '${item['name'].toString().substring(0, 8)}...'
                                    : item['name'].toString(),
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 8,
                                  color: PdfColors.grey600,
                                ),
                              ),
                              pw.SizedBox(height: 2),
                              pw.Text(
                                '${itemTotals[item['id'] as int]}',
                                style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                if (includePrices) ...[
                  pw.Divider(height: 24, color: PdfColors.grey300),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'BİRİM FİYAT',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Row(
                        children: items.map((item) {
                          final price = (item['base_price_cents'] as int) / 100;
                          return pw.Container(
                            margin: const pw.EdgeInsets.only(left: 16),
                            width: 60,
                            child: pw.Text(
                              '₺${price.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 10,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  pw.Divider(height: 24, color: PdfColors.grey300),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'TOPLAM FİYAT',
                        style: pw.TextStyle(
                          font: ttf,
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                      pw.Row(
                        children: items.map((item) {
                          final total = itemTotals[item['id'] as int] ?? 0;
                          final price = (item['base_price_cents'] as int) / 100;
                          final totalPrice = total * price;
                          return pw.Container(
                            margin: const pw.EdgeInsets.only(left: 16),
                            width: 60,
                            child: pw.Text(
                              '₺${totalPrice.toStringAsFixed(2)}',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                font: ttf,
                                fontSize: 10,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.green700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (includePrices) ...[
            pw.SizedBox(height: 16),
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.green700,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'GENEL TOPLAM',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.Text(
                    '₺${(() {
                      double genelToplam = 0;
                      for (var item in items) {
                        final total = itemTotals[item['id'] as int] ?? 0;
                        final price = (item['base_price_cents'] as int) / 100;
                        genelToplam += total * price;
                      }
                      return genelToplam.toStringAsFixed(2);
                    })()}',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
          pw.SizedBox(height: 32),
          pw.Container(
            padding: const pw.EdgeInsets.only(top: 16),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text(
                  'Rapor Tarihi: ${DateFormat('dd.MM.yyyy HH:mm').format(now)}',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

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

  void _showShareMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.attach_money, color: Color(0xFF38A169)),
                title: const Text('Fiyatlarla Birlikte Paylaş'),
                subtitle: const Text('Birim ve toplam fiyatlar dahil'),
                onTap: () {
                  Navigator.pop(context);
                  exportTableAsPdf(includePrices: true);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.money_off, color: Color(0xFF4A5568)),
                title: const Text('Sadece Miktarları Paylaş'),
                subtitle: const Text('Fiyat bilgileri olmadan'),
                onTap: () {
                  Navigator.pop(context);
                  exportTableAsPdf(includePrices: false);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
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
        onPressed: _showShareMenu,
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