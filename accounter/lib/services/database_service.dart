import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/company.dart';
import '../models/item.dart';
import '../models/sale.dart';
import '../models/company_item_price.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._privateConstructor();
  static Database? _database;

  DatabaseService._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'accounter.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDb,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE companies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        color TEXT NOT NULL DEFAULT '#2563EB'
      )
    ''');

    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        base_price_cents INTEGER NOT NULL,
        color TEXT NOT NULL DEFAULT '#38A169'
      )
    ''');

    await db.execute('''
      CREATE TABLE sales(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_id INTEGER NOT NULL,
        company_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (item_id) REFERENCES items (id),
        FOREIGN KEY (company_id) REFERENCES companies (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE company_item_prices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        custom_price_cents INTEGER NOT NULL,
        FOREIGN KEY (company_id) REFERENCES companies (id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE,
        UNIQUE(company_id, item_id)
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE company_item_prices(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_id INTEGER NOT NULL,
        item_id INTEGER NOT NULL,
        custom_price_cents INTEGER NOT NULL,
        FOREIGN KEY (company_id) REFERENCES companies (id) ON DELETE CASCADE,
        FOREIGN KEY (item_id) REFERENCES items (id) ON DELETE CASCADE,
        UNIQUE(company_id, item_id)
      )
    ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
      ALTER TABLE companies ADD COLUMN color TEXT NOT NULL DEFAULT '#2563EB'
    ''');
    }

    if (oldVersion < 4) {
      await db.execute('''
      UPDATE sales 
      SET unit_price = (
        SELECT items.base_price_cents / 100.0 
        FROM items 
        WHERE items.id = sales.item_id
      )
      WHERE unit_price IS NULL OR unit_price = 0
    ''');
    }
  }

  Future<int> insertCompany(Company company) async {
    final db = await database;
    return await db.insert('companies', company.toMap());
  }

  Future<List<Company>> getAllCompanies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('companies');
    return List.generate(maps.length, (i) => Company.fromMap(maps[i]));
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

  Future<int> insertItem(Item item) async {
    final db = await database;
    return await db.insert('items', item.toMap());
  }

  Future<List<Item>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) => Item.fromMap(maps[i]));
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

  Future<int> setCompanyItemPrice(CompanyItemPrice price) async {
    final db = await database;
    return await db.insert(
      'company_item_prices',
      price.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCompanyItemPrice(int companyId, int itemId) async {
    final db = await database;
    await db.delete(
      'company_item_prices',
      where: 'company_id = ? AND item_id = ?',
      whereArgs: [companyId, itemId],
    );
  }

  Future<int?> getCompanyItemPrice(int companyId, int itemId) async {
    final db = await database;
    final result = await db.query(
      'company_item_prices',
      where: 'company_id = ? AND item_id = ?',
      whereArgs: [companyId, itemId],
    );

    if (result.isNotEmpty) {
      return result.first['custom_price_cents'] as int;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getCompanyItemsWithPrices(int companyId) async {
    final db = await database;
    return await db.rawQuery('''
    SELECT 
      items.id as item_id,
      items.name,
      items.base_price_cents,
      items.color as item_color,
      company_item_prices.custom_price_cents,
      company_item_prices.id as price_id
    FROM items
    LEFT JOIN company_item_prices 
      ON items.id = company_item_prices.item_id 
      AND company_item_prices.company_id = ?
    ORDER BY items.name
  ''', [companyId]);
  }

  Future<bool> checkDuplicateSale(int itemId, int companyId, String date) async {
    final db = await database;
    final result = await db.query(
      'sales',
      where: 'item_id = ? AND company_id = ? AND date = ?',
      whereArgs: [itemId, companyId, date],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> insertSale(Sale sale) async {
    final db = await database;
    return await db.transaction((txn) async {
      return await txn.insert('sales', sale.toMap());
    });
  }

  Future<List<Map<String, dynamic>>> getDailySales(String date) async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT 
      sales.id,
      sales.item_id as itemId,
      sales.company_id as companyId,
      sales.quantity,
      sales.unit_price,
      items.name as itemName,
      items.base_price_cents as basePriceCents,
      items.color as itemColor,
      companies.name as companyName,
      companies.color as companyColor
    FROM sales
    JOIN items ON sales.item_id = items.id
    JOIN companies ON sales.company_id = companies.id
    WHERE sales.date = ?
    ORDER BY sales.id DESC
  ''', [date]);
    return result;
  }

  Future<int> getDailyTotal(String date) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(sales.quantity * sales.unit_price * 100) as total
      FROM sales
      WHERE sales.date = ?
    ''', [date]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toInt();
    }
    return 0;
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

  Future<Map<String, dynamic>> getStatistics(String startDate, String endDate) async {
    final db = await database;

    final totalResult = await db.rawQuery('''
    SELECT 
      COALESCE(COUNT(*), 0) as totalSales,
      COALESCE(SUM(sales.quantity), 0) as totalQuantity,
      COALESCE(CAST(SUM(sales.quantity * sales.unit_price * 100) AS INTEGER), 0) as totalAmount
    FROM sales
    WHERE sales.date BETWEEN ? AND ?
  ''', [startDate, endDate]);

    final companySales = await db.rawQuery('''
    SELECT 
      companies.name,
      companies.id,
      companies.color,
      COALESCE(CAST(SUM(sales.quantity * sales.unit_price * 100) AS INTEGER), 0) as total,
      COALESCE(SUM(sales.quantity), 0) as quantity
    FROM sales
    JOIN companies ON sales.company_id = companies.id
    WHERE sales.date BETWEEN ? AND ?
    GROUP BY companies.id
    ORDER BY total DESC
  ''', [startDate, endDate]);

    final itemSales = await db.rawQuery('''
    SELECT 
      items.name,
      items.id,
      items.color,
      COALESCE(SUM(sales.quantity), 0) as quantity,
      COALESCE(CAST(SUM(sales.quantity * sales.unit_price * 100) AS INTEGER), 0) as total
    FROM sales
    JOIN items ON sales.item_id = items.id
    WHERE sales.date BETWEEN ? AND ?
    GROUP BY items.id
    ORDER BY total DESC
  ''', [startDate, endDate]);

    final dailySales = await db.rawQuery('''
    SELECT 
      sales.date,
      COALESCE(CAST(SUM(sales.quantity * sales.unit_price * 100) AS INTEGER), 0) as total
    FROM sales
    WHERE sales.date BETWEEN ? AND ?
    GROUP BY sales.date
    ORDER BY sales.date ASC
  ''', [startDate, endDate]);

    return {
      'total': totalResult.first,
      'companies': companySales,
      'items': itemSales,
      'daily': dailySales,
    };
  }

  Future<Map<String, dynamic>> getCompanyMonthlyReport(
      int companyId,
      String startDate,
      String endDate,
      ) async {
    final db = await database;

    final items = await db.rawQuery('''
    SELECT DISTINCT
      items.id,
      items.name,
      items.color,
      items.base_price_cents,
      COALESCE(
        (
          SELECT AVG(sales.unit_price)
          FROM sales
          WHERE sales.item_id = items.id 
            AND sales.company_id = ? 
            AND sales.date BETWEEN ? AND ?
        ),
        items.base_price_cents / 100.0
      ) as avg_unit_price
    FROM sales
    JOIN items ON sales.item_id = items.id
    WHERE sales.company_id = ? AND sales.date BETWEEN ? AND ?
    ORDER BY items.name
  ''', [companyId, startDate, endDate, companyId, startDate, endDate]);

    final dailySales = await db.rawQuery('''
    SELECT 
      sales.date,
      sales.item_id as itemId,
      SUM(sales.quantity) as quantity
    FROM sales
    WHERE sales.company_id = ? AND sales.date BETWEEN ? AND ?
    GROUP BY sales.date, sales.item_id
  ''', [companyId, startDate, endDate]);

    return {
      'items': items,
      'dailySales': dailySales,
    };
  }
}