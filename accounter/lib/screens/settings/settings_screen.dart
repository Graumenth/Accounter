import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import '/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
            SnackBar(content: Text(l10n.storagePermissionRequired)),
          );
        }
      }
    }
  }

  Future<void> handleAddCompany(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showCompanyDialog(
      context,
      companyNameLabel: l10n.companyName,
      colorLabel: l10n.color,
      cancelLabel: l10n.cancel,
      saveLabel: l10n.save,
      newCompanyLabel: l10n.newCompany,
      editCompanyLabel: l10n.editCompany,
    );
    if (result != null && result is Map<String, dynamic> && result['name'] != null) {
      await DatabaseService.instance.insertCompany(
        Company(
          name: result['name'],
          color: result['color'] ?? '#38A169',
        ),
      );
      loadData();
    }
  }

  Future<void> handleEditCompany(Company company, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showCompanyDialog(
      context,
      company: company,
      companyNameLabel: l10n.companyName,
      colorLabel: l10n.color,
      cancelLabel: l10n.cancel,
      saveLabel: l10n.save,
      deleteLabel: l10n.delete,
      newCompanyLabel: l10n.newCompany,
      editCompanyLabel: l10n.editCompany,
    );

    if (!mounted) return;

    if (result == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteCompany),
          content: Text(l10n.deleteCompanyConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (confirm == true) {
        await DatabaseService.instance.deleteCompany(company.id!);
        loadData();
      }
    } else if (result != null && result is Map<String, dynamic>) {
      await DatabaseService.instance.updateCompany(
        Company(
          id: company.id,
          name: result['name'],
          color: result['color'],
        ),
      );
      loadData();
    }
  }

  Future<void> handleAddItem(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showItemDialog(
      context,
      itemNameLabel: l10n.itemName,
      priceLabel: l10n.price,
      colorLabel: l10n.color,
      cancelLabel: l10n.cancel,
      saveLabel: l10n.save,
      newItemLabel: l10n.newItem,
      editItemLabel: l10n.editItem,
    );
    if (result != null && result is Map<String, dynamic> && result['name'] != null) {
      await DatabaseService.instance.insertItem(
        Item(
          name: result['name'],
          basePriceCents: result['priceCents'],
          color: result['color'] ?? '#38A169',
        ),
      );
      loadData();
    }
  }

  Future<void> handleEditItem(Item item, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showItemDialog(
      context,
      item: item,
      itemNameLabel: l10n.itemName,
      priceLabel: l10n.price,
      colorLabel: l10n.color,
      cancelLabel: l10n.cancel,
      saveLabel: l10n.save,
      deleteLabel: l10n.delete,
      newItemLabel: l10n.newItem,
      editItemLabel: l10n.editItem,
    );

    if (!mounted) return;

    if (result == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.deleteItem),
          content: Text(l10n.deleteItemConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(l10n.delete),
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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.settings,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: [
            Tab(text: l10n.companies),
            Tab(text: l10n.items),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
            tooltip: l10n.companyInfo,
            onPressed: () async {
              final name = await showProfileDialog(
                context,
                companyInfoLabel: l10n.companyInfo,
                yourCompanyNameLabel: l10n.yourCompanyName,
                usedInPdfReportsLabel: l10n.usedInPdfReports,
                companyLogoLabel: l10n.companyLogo,
                addLogoLabel: l10n.addLogo,
                removeLogoLabel: l10n.removeLogo,
                cancelLabel: l10n.cancel,
                saveLabel: l10n.save,
                darkModeLabel: l10n.darkMode,
                languageLabel: l10n.language,
              );
              if (name != null) {
                await ProfileManager.setCompanyName(name);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.companySaved)),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.backup, color: Theme.of(context).colorScheme.primary),
            tooltip: l10n.backupDatabase,
            onPressed: () => backupDatabase(context),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : TabBarView(
        controller: _tabController,
        children: [
          CompanyList(
            companies: companies,
            onEdit: (company) => handleEditCompany(company, context),
            onRefresh: loadData,
          ),
          ItemList(
            items: items,
            onEdit: (item) => handleEditItem(item, context),
            onRefresh: loadData,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            handleAddCompany(context);
          } else {
            handleAddItem(context);
          }
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}