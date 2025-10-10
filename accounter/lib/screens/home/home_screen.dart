import 'package:flutter/material.dart';
import '../../../models/pending_sale.dart';
import '../../../models/company.dart';
import '../../../models/item.dart';
import '../../../models/sale.dart';
import '../../../services/database_service.dart';
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
  List<PendingSale> pendingSales = [];
  List<Map<String, dynamic>> savedSales = [];
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
    savedSales = await DatabaseService.instance.getDailySales(dateStr);
    dailyTotal = await DatabaseService.instance.getDailyTotal(dateStr);
    setState(() {});
  }

  void changeDate(int days) {
    setState(() {
      selectedDate = selectedDate.add(Duration(days: days));
      pendingSales.clear();
    });
    loadDailySales();
  }

  void addPendingSale(Item item, int companyId) {
    setState(() {
      pendingSales.add(PendingSale(
        item: item,
        companyId: companyId,
      ));
    });
  }

  void removePendingSale(int index) {
    setState(() => pendingSales.removeAt(index));
  }

  void updateQuantity(int index, int delta) {
    setState(() {
      final newQuantity = pendingSales[index].quantity + delta;
      if (newQuantity > 0) {
        pendingSales[index].quantity = newQuantity;
      }
    });
  }

  Future<void> savePendingSales() async {
    for (final sale in pendingSales) {
      final saleModel = Sale(
        itemId: sale.item.id!,
        date: Sale.dateToString(selectedDate),
        companyId: sale.companyId,
        quantity: sale.quantity,
        unitPrice: sale.item.basePriceTL,
      );
      await DatabaseService.instance.insertSale(saleModel);
    }

    setState(() => pendingSales.clear());
    await loadDailySales();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Satışlar kaydedildi!')),
      );
    }
  }

  int get pendingTotal {
    return pendingSales.fold(0, (sum, sale) =>
    sum + (sale.item.basePriceTL * sale.quantity * 100).toInt()
    );
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
                  savedSales: savedSales,
                  pendingSales: pendingSales,
                  onRemovePending: removePendingSale,
                  onUpdateQuantity: updateQuantity,
                  onAddItem: addPendingSale,
                ),

                if (pendingSales.isNotEmpty)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: ElevatedButton(
                      onPressed: savePendingSales,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38A169),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Kaydet (${pendingSales.length} ürün)',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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

          DailyTotalBar(
            dailyTotal: dailyTotal,
            pendingTotal: pendingTotal,
          ),
        ],
      ),
    );
  }
}