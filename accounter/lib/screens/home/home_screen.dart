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

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
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
    loadData();
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
        companyTotal += (sale['quantity'] as int) * (sale['basePriceCents'] as int);
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

  bool _isItemAlreadyAddedToday(int itemId, int companyId) {
    return sales.any((sale) {
      return sale['itemId'] == itemId && sale['companyId'] == companyId;
    });
  }

  Future<void> addSale(Item item, int companyId) async {
    if (_isItemAlreadyAddedToday(item.id!, companyId)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} bu şirkete bugün zaten eklenmiş'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final customPrice = await DatabaseService.instance.getCompanyItemPrice(companyId, item.id!);
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
      body: Column(
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
                      onPressed: () => setState(() => showItemGrid = true),
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
              onAddItem: addSale,
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