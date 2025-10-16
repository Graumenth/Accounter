import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import '../../services/database_service.dart';
import '../../models/company.dart';
import '../../models/item.dart';
import 'widgets/company_list.dart';
import 'widgets/item_list.dart';
import 'widgets/company_dialog.dart';
import 'widgets/item_dialog.dart';
import 'widgets/profile_manager.dart';

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

  Future<void> backupDatabase(BuildContext context) async {
    var storageStatus = await Permission.storage.request();
    var manageStatus = await Permission.manageExternalStorage.request();

    if (storageStatus.isGranted || manageStatus.isGranted) {
      final databasesPath = await getDatabasesPath();
      final dbPath = p.join(databasesPath, 'accounter.db');
      await Share.shareXFiles([XFile(dbPath)], subject: 'Accounter DB Backup');
    } else {
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
      }
      if (!manageStatus.isGranted) {
        manageStatus = await Permission.manageExternalStorage.request();
      }
      if (storageStatus.isGranted || manageStatus.isGranted) {
        final databasesPath = await getDatabasesPath();
        final dbPath = p.join(databasesPath, 'accounter.db');
        await Share.shareXFiles([XFile(dbPath)], subject: 'Accounter DB Backup');
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dosya paylaşmak için depolama izni gerekli! Ayarlardan izin verin.')),
          );
        }
      }
    }
  }

  Future<void> handleAddCompany() async {
    final result = await showCompanyDialog(context);
    if (result != null && result is Map<String, dynamic> && result['name'] != null) {
      await DatabaseService.instance.insertCompany(
        Company(
          name: result['name'],
          color: result['color'] ?? '#2563EB',
        ),
      );
      loadData();
    }
  }

  Future<void> handleEditCompany(Company company) async {
    final result = await showCompanyDialog(context, company: company);
    if (result != null && result is Map<String, dynamic>) {
      if (result['action'] == 'delete') {
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
      } else if (result['name'] != null) {
        await DatabaseService.instance.updateCompany(
          Company(
            id: company.id,
            name: result['name'],
            color: result['color'] ?? company.color,
          ),
        );
        loadData();
      }
    }
  }

  Future<void> handleAddItem() async {
    final itemData = await showItemDialog(context);
    if (itemData != null) {
      await DatabaseService.instance.insertItem(
        Item(
          name: itemData['name'],
          basePriceCents: itemData['priceCents'],
          color: itemData['color'],
        ),
      );
      loadData();
    }
  }

  Future<void> handleEditItem(Item item) async {
    final result = await showItemDialog(context, item: item);
    if (result == 'delete') {
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
      if (!mounted) return;
      if (confirm == true) {
        await DatabaseService.instance.deleteItem(item.id!);
        loadData();
      }
    } else if (result != null && result is Map<String, dynamic>) {
      await DatabaseService.instance.updateItem(
        Item(
          id: item.id,
          name: result['name'],
          basePriceCents: result['priceCents'],
          color: result['color'],
        ),
      );
      loadData();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Color(0xFF38A169)),
            tooltip: 'Şirket Bilgileri',
            onPressed: () async {
              final name = await showProfileDialog(context);
              if (name != null) {
                await ProfileManager.setCompanyName(name);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Şirket bilgileri kaydedildi')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.backup, color: Color(0xFF38A169)),
            tooltip: 'Backup Database',
            onPressed: () => backupDatabase(context),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _tabController,
        children: [
          CompanyList(
            companies: companies,
            onEdit: handleEditCompany,
          ),
          ItemList(
            items: items,
            onEdit: handleEditItem,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            handleAddCompany();
          } else {
            handleAddItem();
          }
        },
        backgroundColor: const Color(0xFF38A169),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}