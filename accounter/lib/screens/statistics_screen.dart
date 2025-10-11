import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../models/sale.dart';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String selectedPeriod = 'today';
  DateTime startDate = DateTime.now();
  DateTime endDate = DateTime.now();
  Map<String, dynamic>? statistics;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    updateDateRange('today');
  }

  void updateDateRange(String period) {
    final now = DateTime.now();
    setState(() {
      selectedPeriod = period;

      switch (period) {
        case 'today':
          startDate = now;
          endDate = now;
          break;
        case 'week':
          startDate = now.subtract(Duration(days: now.weekday - 1));
          endDate = now;
          break;
        case 'month':
          startDate = DateTime(now.year, now.month, 1);
          endDate = now;
          break;
      }
    });
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    setState(() => isLoading = true);

    final startStr = Sale.dateToString(startDate);
    final endStr = Sale.dateToString(endDate);

    statistics = await DatabaseService.instance.getStatistics(startStr, endStr);

    setState(() => isLoading = false);
  }

  Future<void> exportStatisticsAsPdf() async {
    if (statistics == null) return;

    final pdf = pw.Document();
    final total = statistics!['total'] as Map<String, dynamic>;
    final companies = statistics!['companies'] as List<Map<String, dynamic>>;
    final items = statistics!['items'] as List<Map<String, dynamic>>;
    final daily = statistics!['daily'] as List<Map<String, dynamic>>;

    final totalAmount = (total['totalAmount'] ?? 0) as int;
    final totalQuantity = (total['totalQuantity'] ?? 0) as int;
    final totalSales = (total['totalSales'] ?? 0) as int;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          final widgets = <pw.Widget>[];

          widgets.add(pw.Text(
            'Satış İstatistikleri',
            style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
          ));
          widgets.add(pw.SizedBox(height: 8));
          widgets.add(pw.Text(
            _getPeriodText(),
            style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
          ));
          widgets.add(pw.SizedBox(height: 20));

          widgets.add(pw.Text(
            'Özet',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ));
          widgets.add(pw.SizedBox(height: 8));

          widgets.add(pw.Table.fromTextArray(
            headers: ['Toplam (₺)', 'Adet', 'Satış', 'Ortalama (₺)'],
            data: [
              [
                (totalAmount / 100).toStringAsFixed(2),
                totalQuantity.toString(),
                totalSales.toString(),
                totalSales > 0 ? (totalAmount / totalSales / 100).toStringAsFixed(2) : '0.00'
              ]
            ],
            cellAlignment: pw.Alignment.center,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellStyle: const pw.TextStyle(fontSize: 11),
            cellHeight: 30,
            border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
          ));

          if (companies.isNotEmpty) {
            widgets.add(pw.SizedBox(height: 20));
            widgets.add(pw.Text(
              'Şirketlere Göre Satışlar',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ));
            widgets.add(pw.SizedBox(height: 8));

            widgets.add(pw.Table.fromTextArray(
              headers: ['Şirket', 'Adet', 'Toplam (₺)'],
              data: companies.map((c) => [
                c['name'].toString(),
                c['quantity'].toString(),
                ((c['total'] as int) / 100).toStringAsFixed(2)
              ]).toList(),
              cellAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellStyle: const pw.TextStyle(fontSize: 11),
              cellHeight: 30,
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
            ));
          }

          if (items.isNotEmpty) {
            widgets.add(pw.SizedBox(height: 20));
            widgets.add(pw.Text(
              'Ürünlere Göre Satışlar',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ));
            widgets.add(pw.SizedBox(height: 8));

            widgets.add(pw.Table.fromTextArray(
              headers: ['Ürün', 'Adet', 'Toplam (₺)'],
              data: items.map((i) => [
                i['name'].toString(),
                i['quantity'].toString(),
                ((i['total'] as int) / 100).toStringAsFixed(2)
              ]).toList(),
              cellAlignment: pw.Alignment.centerLeft,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellStyle: const pw.TextStyle(fontSize: 11),
              cellHeight: 30,
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
            ));
          }

          if (daily.isNotEmpty && selectedPeriod != 'today') {
            widgets.add(pw.SizedBox(height: 20));
            widgets.add(pw.Text(
              'Günlük Dağılım',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ));
            widgets.add(pw.SizedBox(height: 8));

            widgets.add(pw.Table.fromTextArray(
              headers: ['Tarih', 'Toplam (₺)'],
              data: daily.map((d) => [
                DateFormat('dd.MM.yyyy').format(DateTime.parse(d['date'].toString())),
                ((d['total'] as int) / 100).toStringAsFixed(2)
              ]).toList(),
              cellAlignment: pw.Alignment.center,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellStyle: const pw.TextStyle(fontSize: 11),
              cellHeight: 30,
              border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey400),
            ));
          }

          return widgets;
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/istatistikler_${_getPeriodFileName()}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Satış İstatistikleri - ${_getPeriodText()}');
  }

  String _getPeriodText() {
    switch (selectedPeriod) {
      case 'today':
        return 'Bugün - ${DateFormat('dd.MM.yyyy').format(startDate)}';
      case 'week':
        return 'Bu Hafta - ${DateFormat('dd.MM').format(startDate)} - ${DateFormat('dd.MM.yyyy').format(endDate)}';
      case 'month':
        return 'Bu Ay - ${DateFormat('MMMM yyyy', 'tr_TR').format(startDate)}';
      default:
        return '';
    }
  }

  String _getPeriodFileName() {
    switch (selectedPeriod) {
      case 'today':
        return DateFormat('dd_MM_yyyy').format(startDate);
      case 'week':
        return 'hafta_${DateFormat('dd_MM_yyyy').format(startDate)}';
      case 'month':
        return DateFormat('MM_yyyy').format(startDate);
      default:
        return 'rapor';
    }
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
        title: const Text(
          'İstatistikler',
          style: TextStyle(
            color: Color(0xFF1A202C),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : statistics == null
                ? const Center(child: Text('Veri yok'))
                : _buildStatisticsContent(),
          ),
        ],
      ),
      floatingActionButton: (!isLoading && statistics != null)
          ? FloatingActionButton(
        onPressed: exportStatisticsAsPdf,
        backgroundColor: const Color(0xFF38A169),
        child: const Icon(Icons.share),
        heroTag: "shareStatistics",
      )
          : null,
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildPeriodButton('Bugün', 'today'),
          const SizedBox(width: 8),
          _buildPeriodButton('Bu Hafta', 'week'),
          const SizedBox(width: 8),
          _buildPeriodButton('Bu Ay', 'month'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String period) {
    final isSelected = selectedPeriod == period;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => updateDateRange(period),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF38A169) : Colors.white,
          foregroundColor: isSelected ? Colors.white : const Color(0xFF4A5568),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? const Color(0xFF38A169) : Colors.grey[300]!,
            ),
          ),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildStatisticsContent() {
    final total = statistics!['total'] as Map<String, dynamic>;
    final companies = statistics!['companies'] as List<Map<String, dynamic>>;
    final items = statistics!['items'] as List<Map<String, dynamic>>;
    final daily = statistics!['daily'] as List<Map<String, dynamic>>;

    final totalAmount = (total['totalAmount'] ?? 0) as int;
    final totalQuantity = (total['totalQuantity'] ?? 0) as int;
    final totalSales = (total['totalSales'] ?? 0) as int;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                '💰 Toplam',
                '${(totalAmount / 100).toStringAsFixed(2)} ₺',
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                '📦 Adet',
                '$totalQuantity',
                Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                '🧾 Satış',
                '$totalSales',
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                '📊 Ortalama',
                totalSales > 0
                    ? '${(totalAmount / totalSales / 100).toStringAsFixed(2)} ₺'
                    : '0 ₺',
                Colors.purple,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (companies.isNotEmpty) ...[
          _buildSectionTitle('🏢 Şirketlere Göre Satışlar'),
          const SizedBox(height: 12),
          ...companies.map((company) => _buildCompanyItem(company)),
        ],
        const SizedBox(height: 24),
        if (items.isNotEmpty) ...[
          _buildSectionTitle('🎯 Ürünlere Göre Satışlar'),
          const SizedBox(height: 12),
          ...items.map((item) => _buildItemStat(item)),
        ],
        const SizedBox(height: 24),
        if (daily.isNotEmpty && selectedPeriod != 'today') ...[
          _buildSectionTitle('📈 Günlük Dağılım'),
          const SizedBox(height: 12),
          _buildDailyChart(daily),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.05).round()),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A202C),
      ),
    );
  }

  Widget _buildCompanyItem(Map<String, dynamic> company) {
    final total = (company['total'] as int) / 100;
    final quantity = company['quantity'] as int;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/company-report',
          arguments: {
            'companyId': company['id'],
            'companyName': company['name'],
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$quantity adet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  '${total.toStringAsFixed(2)} ₺',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF38A169),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF4A5568),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemStat(Map<String, dynamic> item) {
    final total = (item['total'] as int) / 100;
    final quantity = item['quantity'] as int;
    final color = Color(int.parse('0xFF${item['color'].toString().substring(1)}'));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity adet',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${total.toStringAsFixed(2)} ₺',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF38A169),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChart(List<Map<String, dynamic>> daily) {
    final maxValue = daily.fold<int>(0, (max, day) {
      final total = day['total'] as int;
      return total > max ? total : max;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: daily.map((day) {
          final date = day['date'] as String;
          final total = (day['total'] as int) / 100;
          final percentage = maxValue > 0 ? (day['total'] as int) / maxValue : 0.0;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    DateFormat('dd MMM').format(DateTime.parse(date)),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: percentage,
                        child: Container(
                          height: 24,
                          decoration: BoxDecoration(
                            color: const Color(0xFF38A169),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: Text(
                    '${total.toStringAsFixed(2)} ₺',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}