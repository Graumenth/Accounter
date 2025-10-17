import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import '../screens/settings/widgets/profile_manager.dart';

class PdfService {
  static Future<void> exportReport({
    required String companyName,
    required DateTime startDate,
    required DateTime endDate,
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> dailySales,
    required bool includePrices,
    required String locale,
    required Map<String, String> translations,
  }) async {
    final pdf = pw.Document();
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
    final fileName = '${myCompanyName}_${companyName}_${shareDate}.pdf'
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

    pw.ImageProvider? logo;
    if (logoPath != null && logoPath.isNotEmpty) {
      final logoFile = File(logoPath);
      if (await logoFile.exists()) {
        final logoBytes = await logoFile.readAsBytes();
        logo = pw.MemoryImage(logoBytes);
      }
    }

    final table = _buildPdfTable(
      ttf: ttf,
      items: items,
      sortedDates: sortedDates,
      salesMap: salesMap,
      itemTotals: itemTotals,
      includePrices: includePrices,
      translations: translations,
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _buildPdfHeader(
              ttf: ttf,
              myCompanyName: myCompanyName,
              companyName: companyName,
              startDate: startDate,
              endDate: endDate,
              logo: logo,
              translations: translations,
            ),
            pw.SizedBox(height: 8),
            pw.Expanded(child: table),
            pw.SizedBox(height: 8),
            _buildPdfSummary(
              ttf: ttf,
              items: items,
              itemTotals: itemTotals,
              includePrices: includePrices,
              translations: translations,
            ),
            pw.SizedBox(height: 8),
            _buildPdfFooter(ttf: ttf, now: now, translations: translations),
          ],
        ),
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    final params = ShareParams(
      files: [XFile(file.path)],
      subject: '${companyName} ${translations['report']}',
      text: translations['report'] ?? 'Report',
    );
    await SharePlus.instance.share(params);
  }

  static pw.Widget _buildPdfHeader({
    required pw.Font ttf,
    required String myCompanyName,
    required String companyName,
    required DateTime startDate,
    required DateTime endDate,
    pw.ImageProvider? logo,
    required Map<String, String> translations,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.green700, PdfColors.green600],
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  myCompanyName,
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  '${translations['selectCompany']}: $companyName',
                  style: pw.TextStyle(
                    font: ttf,
                    fontSize: 8,
                    color: PdfColors.grey100,
                  ),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                translations['report']?.toUpperCase() ?? 'REPORT',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                '${DateFormat('dd.MM.yyyy').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}',
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 7,
                  color: PdfColors.grey100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfTable({
    required pw.Font ttf,
    required List<Map<String, dynamic>> items,
    required List<String> sortedDates,
    required Map<String, Map<int, int>> salesMap,
    required Map<int, int> itemTotals,
    required bool includePrices,
    required Map<String, String> translations,
  }) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Table(
        border: pw.TableBorder(
          horizontalInside: const pw.BorderSide(color: PdfColors.grey300, width: 0.5),
          verticalInside: const pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
        columnWidths: {
          0: const pw.FixedColumnWidth(50),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey800),
            children: [
              _buildPdfCell(ttf, translations['date'] ?? 'Date', isHeader: true),
              ...items.map((item) => _buildPdfCell(ttf, item['name'].toString(), isHeader: true)),
            ],
          ),
          ...sortedDates.asMap().entries.map((entry) {
            final index = entry.key;
            final date = entry.value;
            final isEven = index % 2 == 0;
            return pw.TableRow(
              decoration: pw.BoxDecoration(
                color: isEven ? PdfColors.white : PdfColors.grey50,
              ),
              children: [
                _buildPdfCell(ttf, DateFormat('dd.MM.yyyy').format(DateTime.parse(date))),
                ...items.map((item) {
                  final quantity = salesMap[date]?[item['id'] as int] ?? 0;
                  return _buildPdfCell(
                    ttf,
                    quantity > 0 ? quantity.toString() : '-',
                    isHighlighted: quantity > 0,
                  );
                }),
              ],
            );
          }),
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            children: [
              _buildPdfCell(ttf, translations['total']?.toUpperCase() ?? 'TOTAL', isBold: true),
              ...items.map((item) {
                final total = itemTotals[item['id'] as int] ?? 0;
                return _buildPdfCell(ttf, total.toString(), isBold: true);
              }),
            ],
          ),
          if (includePrices) ...[
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.white),
              children: [
                _buildPdfCell(ttf, translations['unitPrice']?.toUpperCase() ?? 'UNIT PRICE', isBold: true),
                ...items.map((item) {
                  final price = item['avg_unit_price'] as double;
                  return _buildPdfCell(ttf, '₺${price.toStringAsFixed(2)}');
                }),
              ],
            ),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.green50),
              children: [
                _buildPdfCell(ttf, translations['totalPrice']?.toUpperCase() ?? 'TOTAL PRICE', isBold: true),
                ...items.map((item) {
                  final total = itemTotals[item['id'] as int] ?? 0;
                  final price = item['avg_unit_price'] as double;
                  final totalPrice = total * price;
                  return _buildPdfCell(
                    ttf,
                    '₺${totalPrice.toStringAsFixed(2)}',
                    isBold: true,
                    color: PdfColors.green700,
                  );
                }),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildPdfCell(
      pw.Font ttf,
      String text, {
        bool isHeader = false,
        bool isHighlighted = false,
        bool isBold = false,
        PdfColor? color,
      }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: ttf,
          fontSize: isHeader ? 7.5 : 7,
          fontWeight: isHeader || isHighlighted || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: color ?? (isHeader ? PdfColors.white : (isHighlighted ? PdfColors.green700 : PdfColors.grey800)),
        ),
        textAlign: pw.TextAlign.center,
        maxLines: isHeader ? 2 : 1,
        overflow: pw.TextOverflow.clip,
      ),
    );
  }

  static pw.Widget _buildPdfSummary({
    required pw.Font ttf,
    required List<Map<String, dynamic>> items,
    required Map<int, int> itemTotals,
    required bool includePrices,
    required Map<String, String> translations,
  }) {
    if (!includePrices) return pw.SizedBox();

    double grandTotal = 0;
    for (var item in items) {
      final qty = itemTotals[item['id'] as int] ?? 0;
      final price = item['avg_unit_price'] as double;
      grandTotal += qty * price;
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        gradient: const pw.LinearGradient(
          colors: [PdfColors.green700, PdfColors.green600],
        ),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            translations['grandTotal']?.toUpperCase() ?? 'GRAND TOTAL',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
          pw.Text(
            '₺${grandTotal.toStringAsFixed(2)}',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter({
    required pw.Font ttf,
    required DateTime now,
    required Map<String, String> translations,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Icon(
            const pw.IconData(0xe192),
            size: 8,
            color: PdfColors.grey500,
          ),
          pw.SizedBox(width: 4),
          pw.Text(
            '${translations['date']}: ${DateFormat('dd.MM.yyyy HH:mm').format(now)}',
            style: pw.TextStyle(
              font: ttf,
              fontSize: 7,
              color: PdfColors.grey600,
            ),
          ),
        ],
      ),
    );
  }
}