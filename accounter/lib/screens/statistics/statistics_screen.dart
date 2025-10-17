import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../services/database_service.dart';
import '../../models/sale.dart';
import '../../constants/app_colors.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: startDate, end: endDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: isDark ? AppColors.darkPrimary : AppColors.primary,
              onPrimary: AppColors.surface,
              onSurface: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
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
          l10n.statistics,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          PeriodSelector(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: updateDateRange,
          ),
          Expanded(
            child: isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.darkPrimary : AppColors.primary,
              ),
            )
                : statistics == null
                ? Center(
              child: Text(
                l10n.noData,
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            )
                : _buildStatisticsContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsContent() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = statistics!['total'] as Map<String, dynamic>;
    final companies = statistics!['companies'] as List<Map<String, dynamic>>;
    final items = statistics!['items'] as List<Map<String, dynamic>>;
    final daily = statistics!['daily'] as List<Map<String, dynamic>>;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SummaryCards(total: total),
        const SizedBox(height: AppSpacing.xl),
        if (companies.isNotEmpty) ...[
          Text(
            l10n.companySales,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          CompanyStats(
            companies: companies,
            startDate: startDate,
            endDate: endDate,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (items.isNotEmpty) ...[
          Text(
            l10n.productSales,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ItemStats(items: items),
        ],
        const SizedBox(height: AppSpacing.xl),
        if (daily.isNotEmpty) ...[
          Text(
            l10n.dailyDistribution,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DailyChart(daily: daily),
        ],
        const SizedBox(height: 80),
      ],
    );
  }
}