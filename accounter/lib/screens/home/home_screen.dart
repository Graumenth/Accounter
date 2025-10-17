import 'package:flutter/material.dart';
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
    setState(() {
      selectedCompany = company;
    });
  }

  Future<void> addSaleFromGrid(Item item) async {
    _checkAndUpdateDate();
    if (selectedCompany == null) return;

    final customPrice = await DatabaseService.instance.getCompanyItemPrice(
      selectedCompany!.id!,
      item.id!,
    );

    final unitPrice = customPrice != null ? customPrice / 100 : item.basePriceTL;

    final sale = Sale(
      itemId: item.id!,
      date: Sale.dateToString(selectedDate),
      companyId: selectedCompany!.id!,
      quantity: 1,
      unitPrice: unitPrice,
    );

    await DatabaseService.instance.insertSale(sale);
    await loadDailySales();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} eklendi'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> addSale(Item item, int companyId) async {
    _checkAndUpdateDate();
    final customPrice = await DatabaseService.instance.getCompanyItemPrice(
      companyId,
      item.id!,
    );

    final unitPrice = customPrice != null ? customPrice / 100 : item.basePriceTL;

    final sale = Sale(
      itemId: item.id!,
      date: Sale.dateToString(selectedDate),
      companyId: companyId,
      quantity: 1,
      unitPrice: unitPrice,
    );

    await DatabaseService.instance.insertSale(sale);
    await loadDailySales();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} eklendi'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> updateSaleQuantity(int saleId, int newQuantity) async {
    _checkAndUpdateDate();
    if (newQuantity <= 0) {
      await DatabaseService.instance.deleteSale(saleId);
    } else {
      await DatabaseService.instance.updateSaleQuantity(saleId, newQuantity);
    }
    await loadDailySales();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(color: Color(0xFF38A169)),
      )
          : Column(
        children: [
          AppHeader(
            onSettingsChanged: () => loadData(),
          ),
          DateSelector(
            selectedDate: selectedDate,
            onDateChanged: changeDate,
          ),
          CategoryTabs(
            companies: companies,
            selectedCompanyId: selectedCompanyFilter,
            onCompanySelected: onCompanyFilterChanged,
          ),
          Expanded(
            child: Stack(
              children: [
                SalesList(
                  isLoading: isLoading,
                  sales: filteredSales,
                  onUpdateQuantity: updateSaleQuantity,
                  onAddItem: addSale,
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
                      label: const Text('Satış Ekle'),
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
            ),
          DailyTotalBar(
            dailyTotal: dailyTotal,
            companyTotal: selectedCompanyFilter != null ? companyTotal : null,
            companyName: selectedCompanyFilter != null
                ? companies.firstWhere((c) => c.id == selectedCompanyFilter).name
                : null,
          ),
        ],
      ),
    );
  }
}