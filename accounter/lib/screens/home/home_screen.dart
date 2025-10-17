import 'package:flutter/material.dart';
import '/l10n/app_localizations.dart';
import '../../models/company.dart';
import '../../models/item.dart';
import '../../models/sale.dart';
import '../../services/database_service.dart';
import 'widgets/app_header.dart';
import 'widgets/date_selector.dart';
import 'widgets/category_tabs.dart';
import 'widgets/sales_list.dart';
import 'widgets/item_grid.dart';
import 'widgets/daily_total_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime selectedDate = DateTime.now();
  DateTime _lastCheckedDate = DateTime.now();
  List<Map<String, dynamic>> sales = [];
  List<Map<String, dynamic>> filteredSales = [];
  List<Company> companies = [];
  List<Item> items = [];
  Company? selectedCompany;
  int? selectedCompanyFilter;

  bool showItemGrid = false;
  bool isLoading = true;
  int dailyTotal = 0;
  int companyTotal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastCheckedDate = DateTime.now();
    loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAndUpdateDate();
    }
  }

  void _checkAndUpdateDate() {
    final now = DateTime.now();
    final lastDate = DateTime(_lastCheckedDate.year, _lastCheckedDate.month, _lastCheckedDate.day);
    final todayDate = DateTime(now.year, now.month, now.day);

    if (!lastDate.isAtSameMomentAs(todayDate)) {
      final currentSelectedDate = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

      if (currentSelectedDate.isAtSameMomentAs(lastDate)) {
        setState(() {
          selectedDate = now;
          _lastCheckedDate = now;
        });
        loadDailySales();
      } else {
        _lastCheckedDate = now;
      }
    }
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    try {
      companies = await DatabaseService.instance.getAllCompanies();
      items = await DatabaseService.instance.getAllItems();

      if (companies.isNotEmpty) {
        selectedCompany = companies.first;
      }

      await loadDailySales();
    } catch (e) {
      print('Error loadData: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> loadDailySales() async {
    try {
      final dateStr = Sale.dateToString(selectedDate);

      sales = await DatabaseService.instance.getDailySales(dateStr);
      dailyTotal = await DatabaseService.instance.getDailyTotal(dateStr);

      filterSales();
    } catch (e) {
      print('Error loadDailySales: $e');
    }
  }

  void filterSales() {
    if (selectedCompanyFilter == null) {
      filteredSales = sales;
      companyTotal = dailyTotal;
    } else {
      final companyName = companies.firstWhere((c) => c.id == selectedCompanyFilter).name;
      filteredSales = sales.where((sale) => sale['companyName'] == companyName).toList();

      companyTotal = 0;
      for (var sale in filteredSales) {
        final unitPrice = (sale['unit_price'] as double);
        companyTotal += (sale['quantity'] as int) * (unitPrice * 100).toInt();
      }
    }
    setState(() {});
  }

  void changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
    loadDailySales();
  }

  void onCompanyFilterChanged(int? companyId) {
    setState(() {
      selectedCompanyFilter = companyId;
    });
    filterSales();
  }

  void onCompanyChanged(Company? company) {
    setState(() => selectedCompany = company);
  }

  Future<void> updateSaleQuantity(int saleId, int newQuantity) async {
    if (newQuantity <= 0) {
      await DatabaseService.instance.deleteSale(saleId);
    } else {
      await DatabaseService.instance.updateSaleQuantity(saleId, newQuantity);
    }
    await loadDailySales();
  }

  Future<void> addSale(Item item, int companyId) async {
    final customPrice = await DatabaseService.instance.getCompanyItemPrice(companyId, item.id!);
    final unitPrice = customPrice != null ? customPrice / 100 : item.basePriceTL;

    final sale = Sale(
      itemId: item.id!,
      companyId: companyId,
      quantity: 1,
      unitPrice: unitPrice,
      date: Sale.dateToString(selectedDate),
    );

    await DatabaseService.instance.insertSale(sale);
    await loadDailySales();
  }

  Future<void> addSaleFromGrid(Item item) async {
    if (selectedCompany == null) return;

    final companyId = selectedCompanyFilter ?? selectedCompany!.id!;
    await addSale(item, companyId);
    setState(() => showItemGrid = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF38A169)),
      )
          : Column(
        children: [
          AppHeader(
            title: l10n.accounter,
            statisticsTooltip: l10n.statistics,
            settingsTooltip: l10n.settings,
            onSettingsChanged: () => loadData(),
          ),
          DateSelector(
            selectedDate: selectedDate,
            onDateChanged: changeDate,
            todayLabel: l10n.today,
            yesterdayLabel: l10n.yesterday,
            tomorrowLabel: l10n.tomorrow,
          ),
          CategoryTabs(
            companies: companies,
            selectedCompanyId: selectedCompanyFilter,
            onCompanySelected: onCompanyFilterChanged,
            allLabel: l10n.all,
          ),
          Expanded(
            child: Stack(
              children: [
                SalesList(
                  isLoading: isLoading,
                  sales: filteredSales,
                  onUpdateQuantity: updateSaleQuantity,
                  onAddItem: addSale,
                  noSalesText: l10n.noSales,
                  dragItemText: l10n.dragItemHere,
                ),
                if (!showItemGrid)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton.extended(
                      onPressed: () {
                        _checkAndUpdateDate();
                        setState(() => showItemGrid = true);
                      },
                      backgroundColor: const Color(0xFF38A169),
                      icon: const Icon(Icons.add),
                      label: Text(l10n.addSale),
                    ),
                  ),
              ],
            ),
          ),
          if (showItemGrid)
            ItemGrid(
              companies: companies,
              items: items,
              selectedCompany: selectedCompanyFilter != null
                  ? companies.firstWhere((c) => c.id == selectedCompanyFilter)
                  : selectedCompany,
              onCompanyChanged: (company) => setState(() => selectedCompany = company),
              onClose: () => setState(() => showItemGrid = false),
              hideCompanySelector: selectedCompanyFilter != null,
              onAddItem: addSaleFromGrid,
              selectCompanyLabel: l10n.selectCompany,
              closeLabel: l10n.close,
            ),
          DailyTotalBar(
            dailyTotal: dailyTotal,
            companyTotal: selectedCompanyFilter != null ? companyTotal : null,
            companyName: selectedCompanyFilter != null
                ? companies.firstWhere((c) => c.id == selectedCompanyFilter).name
                : null,
            dailyTotalLabel: l10n.dailyTotal,
            grandTotalLabel: l10n.grandTotal,
          ),
        ],
      ),
    );
  }
}