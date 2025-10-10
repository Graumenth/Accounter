import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';
import '../models/company.dart';
import '../models/sale.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('accounter.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        basePriceCents INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE companies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemId INTEGER NOT NULL,
        companyId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (itemId) REFERENCES items (id),
        FOREIGN KEY (companyId) REFERENCES companies (id)
      )
    ''');

    await db.execute('CREATE INDEX idx_sales_date ON sales(date)');
    await db.execute('CREATE INDEX idx_sales_company ON sales(companyId)');
  }

  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final result = await db.query('items');
    return result.map((map) => Item.fromMap(map)).toList();
  }

  Future<int> insertCompany(Company company) async {
    final db = await database;
    return await db.insert('companies', company.toMap());
  }

  Future<List<Company>> getAllCompanies() async {
    final db = await database;
    final result = await db.query('companies');
    return result.map((map) => Company.fromMap(map)).toList();
  }

  Future<int> insertSale(Sale sale) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.insert('sales', sale.toMap());
    });
  }

  Future<void> updateSaleQuantity(int saleId, int quantity) async {
    final db = await database;
    await db.update(
      'sales',
      {'quantity': quantity},
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }

  Future<void> deleteSale(int saleId) async {
    final db = await database;
    await db.delete(
      'sales',
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }

  Future<List<Map<String, dynamic>>> getDailySales(String date) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT s.*, i.name as itemName, i.basePriceCents, c.name as companyName
      FROM sales s
      JOIN items i ON i.id = s.itemId
      JOIN companies c ON c.id = s.companyId
      WHERE s.date = ?
      ORDER BY c.name
    ''', [date]);
  }

  Future<int> getDailyTotal(String date) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(s.quantity * i.basePriceCents) as totalCents
      FROM sales s
      JOIN items i ON i.id = s.itemId
      WHERE s.date = ?
    ''', [date]);

    final total = result.first['totalCents'];
    return (total != null) ? (total as num).toInt() : 0;
  }

  Future<Map<int, int>> getDailyCompanyTotals(String date) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT s.companyId, SUM(s.quantity * i.basePriceCents) as totalCents
      FROM sales s
      JOIN items i ON i.id = s.itemId
      WHERE s.date = ?
      GROUP BY s.companyId
    ''', [date]);

    Map<int, int> totals = {};
    for (var row in result) {
      totals[row['companyId'] as int] = (row['totalCents'] as num).toInt();
    }
    return totals;
  }

  Future<int> getMonthlyTotal(int year, int month) async {
    final db = await database;
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0);
    final startStr = Sale.dateToString(start);
    final endStr = Sale.dateToString(end);

    final result = await db.rawQuery('''
      SELECT SUM(s.quantity * i.basePriceCents) as totalCents
      FROM sales s
      JOIN items i ON i.id = s.itemId
      WHERE s.date BETWEEN ? AND ?
    ''', [startStr, endStr]);

    final total = result.first['totalCents'];
    return (total != null) ? (total as num).toInt() : 0;
  }

  Future<int> updateItem(Item item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateCompany(Company company) async {
    final db = await database;
    return await db.update(
      'companies',
      company.toMap(),
      where: 'id = ?',
      whereArgs: [company.id],
    );
  }

  Future<int> deleteCompany(int id) async {
    final db = await database;
    return await db.delete(
      'companies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getDailySalesByCompany(String date, int companyId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT s.*, i.name as itemName, i.basePriceCents, c.name as companyName
    FROM sales s
    JOIN items i ON i.id = s.itemId
    JOIN companies c ON c.id = s.companyId
    WHERE s.date = ? AND s.companyId = ?
    ORDER BY s.id DESC
  ''', [date, companyId]);
  }

  Future<int> getDailyTotalByCompany(String date, int companyId) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT SUM(s.quantity * i.basePriceCents) as totalCents
    FROM sales s
    JOIN items i ON i.id = s.itemId
    WHERE s.date = ? AND s.companyId = ?
  ''', [date, companyId]);

    final total = result.first['totalCents'];
    return (total != null) ? (total as num).toInt() : 0;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}