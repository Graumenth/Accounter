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
  List<Company> companies = [];
  List<Item> items = [];
  Company? selectedCompany;

  bool showItemGrid = false;
  bool isLoading = true;
  int dailyTotal = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);

    companies = await DatabaseService.instance.getAllCompanies();
    items = await DatabaseService.instance.getAllItems();

    if (companies.isNotEmpty) {
      selectedCompany = companies.first;
    }

    await loadDailySales();
    setState(() => isLoading = false);
  }

  Future<void> loadDailySales() async {
    final dateStr = Sale.dateToString(selectedDate);
    sales = await DatabaseService.instance.getDailySales(dateStr);
    dailyTotal = await DatabaseService.instance.getDailyTotal(dateStr);
    setState(() {});
  }

  void changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
    });
    loadDailySales();
  }

  Future<void> addSale(Item item, int companyId) async {
    final sale = Sale(
      itemId: item.id!,
      date: Sale.dateToString(selectedDate),
      companyId: companyId,
      quantity: 1,
      unitPrice: item.basePriceTL,
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
          const AppHeader(),
          DateSelector(
            selectedDate: selectedDate,
            onDateChanged: changeDate,
          ),
          const CategoryTabs(),

          Expanded(
            child: Stack(
              children: [
                SalesList(
                  isLoading: isLoading,
                  sales: sales,
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
              selectedCompany: selectedCompany,
              onCompanyChanged: (company) => setState(() => selectedCompany = company),
              onClose: () => setState(() => showItemGrid = false),
            ),

          DailyTotalBar(dailyTotal: dailyTotal),
        ],
      ),
    );
  }
}