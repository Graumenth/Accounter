import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/company.dart';
import '../models/item.dart';
import '../models/sale.dart';

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
      version: 2,
      onCreate: _createDb,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS sales');
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
        }
      },
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE companies(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        base_price_cents INTEGER NOT NULL
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
        sales.quantity,
        sales.unit_price,
        items.name as itemName,
        items.base_price_cents as basePriceCents,
        companies.name as companyName
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
      SELECT SUM(sales.quantity * items.base_price_cents) as total
      FROM sales
      JOIN items ON sales.item_id = items.id
      WHERE sales.date = ?
    ''', [date]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return result.first['total'] as int;
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
}