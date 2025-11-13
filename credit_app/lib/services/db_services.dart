import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/credit_model.dart';
import '../models/installment_model.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'credits.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE credits(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            startDate TEXT,
            amount REAL,
            termMonths INTEGER,
            monthlyInterest REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE installments(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            creditId INTEGER,
            number INTEGER,
            monthLabel TEXT,
            balance REAL,
            capital REAL,
            interest REAL,
            paid INTEGER,
            FOREIGN KEY(creditId) REFERENCES credits(id) ON DELETE CASCADE
          )
        ''');
      },
    );
  }

  Future<int> insertCredit(Credit credit) async {
    final db = await database;
    return await db.insert('credits', credit.toMap());
  }

  Future<void> insertInstallments(List<Installment> installments) async {
    final db = await database;
    for (var inst in installments) {
      await db.insert('installments', inst.toMap());
    }
  }

  Future<List<Credit>> getCredits() async {
    final db = await database;
    final creditMaps = await db.query('credits');

    List<Credit> credits = [];
    for (var creditMap in creditMaps) {
      final id = creditMap['id'] as int;
      final installments = await getInstallmentsByCredit(id);
      credits.add(Credit.fromMap(creditMap, installments));
    }

    return credits;
  }

  Future<List<Installment>> getInstallmentsByCredit(int creditId) async {
    final db = await database;
    final maps = await db.query(
      'installments',
      where: 'creditId = ?',
      whereArgs: [creditId],
    );
    return List.generate(maps.length, (i) => Installment.fromMap(maps[i]));
  }

  Future<void> updateInstallmentPaid(int installmentId, bool paid) async {
    final db = await database;
    await db.update(
      'installments',
      {'paid': paid ? 1 : 0},
      where: 'id = ?',
      whereArgs: [installmentId],
    );
  }

  Future<void> deleteCredit(int id) async {
    final db = await database;
    await db.delete('credits', where: 'id = ?', whereArgs: [id]);
  }
}
