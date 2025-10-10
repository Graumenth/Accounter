import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/company.dart';
import '../models/item.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Company> companies = [];
  List<Item> items = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    companies = await DatabaseService.instance.getAllCompanies();
    items = await DatabaseService.instance.getAllItems();
    setState(() => isLoading = false);
  }

  Future<void> addCompany() async {
    final controller = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Şirket'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Şirket Adı',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.trim().isNotEmpty) {
      await DatabaseService.instance.insertCompany(
        Company(name: controller.text.trim()),
      );
      loadData();
    }
  }

  Future<void> addItem() async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Ürün'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ürün Adı',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Fiyat (TL)',
                border: OutlineInputBorder(),
                prefixText: '₺ ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty &&
                  priceController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );

    if (result == true &&
        nameController.text.trim().isNotEmpty &&
        priceController.text.trim().isNotEmpty) {
      final price = double.tryParse(priceController.text.trim());
      if (price != null) {
        await DatabaseService.instance.insertItem(
          Item(
            name: nameController.text.trim(),
            basePriceCents: (price * 100).toInt(),
          ),
        );
        loadData();
      }
    }
  }

  Future<void> editItem(Item item) async {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(
      text: item.basePriceTL.toStringAsFixed(2),
    );

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Düzenle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Ürün Adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                labelText: 'Fiyat (TL)',
                border: OutlineInputBorder(),
                prefixText: '₺ ',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty &&
                  priceController.text.trim().isNotEmpty) {
                Navigator.pop(context, 'save');
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result == 'save' &&
        nameController.text.trim().isNotEmpty &&
        priceController.text.trim().isNotEmpty) {
      final price = double.tryParse(priceController.text.trim());
      if (price != null) {
        await DatabaseService.instance.updateItem(
          Item(
            id: item.id,
            name: nameController.text.trim(),
            basePriceCents: (price * 100).toInt(),
          ),
        );
        loadData();
      }
    } else if (result == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Ürünü Sil'),
          content: Text('${item.name} ürününü silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await DatabaseService.instance.deleteItem(item.id!);
        loadData();
      }
    }
  }

  Future<void> editCompany(Company company) async {
    final controller = TextEditingController(text: company.name);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Şirketi Düzenle'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Şirket Adı',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'delete'),
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, 'save');
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );

    if (result == 'save' && controller.text.trim().isNotEmpty) {
      await DatabaseService.instance.updateCompany(
        Company(id: company.id, name: controller.text.trim()),
      );
      loadData();
    } else if (result == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Şirketi Sil'),
          content: Text('${company.name} şirketini silmek istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Sil'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await DatabaseService.instance.deleteCompany(company.id!);
        loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A202C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ayarlar',
          style: TextStyle(
            color: Color(0xFF1A202C),
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF38A169),
          unselectedLabelColor: const Color(0xFF4A5568),
          indicatorColor: const Color(0xFF38A169),
          tabs: const [
            Tab(text: 'Şirketler'),
            Tab(text: 'Ürünler'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          _buildCompanyList(),
          _buildItemList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            addCompany();
          } else {
            addItem();
          }
        },
        backgroundColor: const Color(0xFF38A169),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCompanyList() {
    if (companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Henüz şirket eklenmemiş',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: companies.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final company = companies[index];
        return ListTile(
          title: Text(
            company.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF4A5568)),
          onTap: () => editCompany(company),
        );
      },
    );
  }

  Widget _buildItemList() {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Henüz ürün eklenmemiş',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          title: Text(
            item.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${item.basePriceTL.toStringAsFixed(2)} ₺',
            style: TextStyle(color: Colors.grey[600]),
          ),
          trailing: const Icon(Icons.chevron_right, color: Color(0xFF4A5568)),
          onTap: () => editItem(item),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}