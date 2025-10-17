import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../services/database_service.dart';
import '../../models/sale.dart';
import 'widgets/period_selector.dart';
import 'widgets/summary_cards.dart';
import 'widgets/company_stats.dart';
import 'widgets/item_stats.dart';
import 'widgets/daily_chart.dart';

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
        case 'year':
          startDate = DateTime(now.year, 1, 1);
          endDate = now;
          break;
        case 'custom':
          _showCustomDatePicker();
          return;
      }
    });
    loadStatistics();
  }

  Future<void> _showCustomDatePicker() async {
    final theme = Theme.of(context);

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      locale: const Locale('tr', 'TR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: theme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        selectedPeriod = 'custom';
      });
      loadStatistics();
    } else {
      setState(() {
        selectedPeriod = 'today';
        startDate = DateTime.now();
        endDate = DateTime.now();
      });
      loadStatistics();
    }
  }

  Future<void> loadStatistics() async {
    setState(() => isLoading = true);

    final startStr = Sale.dateToString(startDate);
    final endStr = Sale.dateToString(endDate);

    statistics = await DatabaseService.instance.getStatistics(startStr, endStr);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.statistics,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          PeriodSelector(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: updateDateRange,
            todayLabel: l10n.today,
            thisWeekLabel: l10n.thisWeek,
            thisMonthLabel: l10n.thisMonth,
            thisYearLabel: l10n.thisYear,
            selectDateLabel: l10n.selectDate,
          ),
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            )
                : statistics == null
                ? Center(child: Text(l10n.noData))
                : _buildStatisticsContent(l10n, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent(AppLocalizations l10n, ThemeData theme) {
    final total = statistics!['total'] as Map<String, dynamic>;
    final companies = statistics!['companies'] as List<Map<String, dynamic>>;
    final items = statistics!['items'] as List<Map<String, dynamic>>;
    final daily = statistics!['daily'] as List<Map<String, dynamic>>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SummaryCards(total: total),
        const SizedBox(height: 24),
        if (companies.isNotEmpty) ...[
          Text(
            '🏢 ${l10n.companySales}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          CompanyStats(
            companies: companies,
            startDate: startDate,
            endDate: endDate,
          ),
        ],
        const SizedBox(height: 24),
        if (items.isNotEmpty) ...[
          Text(
            '🎯 ${l10n.productSales}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ItemStats(items: items),
        ],
        const SizedBox(height: 24),
        if (daily.isNotEmpty && selectedPeriod != 'today') ...[
          Text(
            '📈 ${l10n.dailyDistribution}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          DailyChart(daily: daily),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}