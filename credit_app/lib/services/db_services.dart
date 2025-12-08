import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/credit_model.dart';
import '../models/installment_model.dart';

class DBService {
  static final DBService instance = DBService._init();
  static Database? _database;

  DBService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("credits.db");
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Incrementado para migración
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE credits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        startDate TEXT NOT NULL,
        amount REAL NOT NULL,
        termMonths INTEGER NOT NULL,
        monthlyInterest REAL NOT NULL
      );
    ''');

    await db.execute('''
      CREATE TABLE installments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        creditId INTEGER NOT NULL,
        number INTEGER NOT NULL,
        monthLabel TEXT NOT NULL,
        dueDate TEXT NOT NULL,
        balance REAL NOT NULL,
        capital REAL NOT NULL,
        interest REAL NOT NULL,
        paid INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (creditId) REFERENCES credits(id) ON DELETE CASCADE
      );
    ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar columna dueDate a la tabla installments
      await db.execute('''
        ALTER TABLE installments ADD COLUMN dueDate TEXT;
      ''');
      
      // Migrar datos existentes: convertir monthLabel a dueDate (primer día del mes)
      final installments = await db.query('installments');
      for (var installment in installments) {
        final monthLabel = installment['monthLabel'] as String;
        final parts = monthLabel.split('/');
        if (parts.length == 2) {
          final month = int.parse(parts[0]);
          final year = int.parse(parts[1]);
          final dueDate = DateTime(year, month, 1).toIso8601String();
          
          await db.update(
            'installments',
            {'dueDate': dueDate},
            where: 'id = ?',
            whereArgs: [installment['id']],
          );
        }
      }
    }
  }

  // ────────────────────────────────────────────────
  // INSERTAR CRÉDITO
  // ────────────────────────────────────────────────
  Future<int> insertCredit(Credit credit) async {
    final db = await instance.database;
    return await db.insert("credits", credit.toMap());
  }

  // INSERTAR TODAS LAS CUOTAS
  Future<void> insertInstallments(List<Installment> installments) async {
    final db = await instance.database;

    for (var i in installments) {
      await db.insert("installments", i.toMap());
    }
  }

  // ────────────────────────────────────────────────
  // OBTENER TODOS LOS CRÉDITOS
  // ────────────────────────────────────────────────
  Future<List<Credit>> getAllCredits() async {
    final db = await instance.database;

    final creditMaps = await db.query("credits", orderBy: "id DESC");

    List<Credit> credits = [];

    for (var creditMap in creditMaps) {
        final installments = await getInstallmentsByCreditId(creditMap["id"] as int);
        credits.add(Credit.fromMap(creditMap, installments));
    }

    return credits;
  }

  // ────────────────────────────────────────────────
  // OBTENER CRÉDITO POR ID
  // ────────────────────────────────────────────────
  Future<Credit?> getCreditById(int id) async {
    final db = await instance.database;

    final data =
        await db.query("credits", where: "id = ?", whereArgs: [id]);

    if (data.isEmpty) return null;

    final installments = await getInstallmentsByCreditId(id);

    return Credit.fromMap(data.first, installments);
  }

  // ────────────────────────────────────────────────
  // OBTENER CUOTAS POR ID DE CRÉDITO
  // ────────────────────────────────────────────────
  Future<List<Installment>> getInstallmentsByCreditId(int creditId) async {
    final db = await instance.database;

    final data = await db.query(
      "installments",
      where: "creditId = ?",
      whereArgs: [creditId],
      orderBy: "number ASC",
    );

    return data.map((e) => Installment.fromMap(e)).toList();
  }

  // ────────────────────────────────────────────────
  // MARCAR CUOTA COMO PAGADA
  // ────────────────────────────────────────────────
  Future<void> markInstallmentPaid(int installmentId) async {
    final db = await instance.database;

    await db.update(
      "installments",
      {"paid": 1},
      where: "id = ?",
      whereArgs: [installmentId],
    );
  }

  // ────────────────────────────────────────────────
  // DESMARCAR CUOTA COMO PAGADA
  // ────────────────────────────────────────────────
  Future<void> unmarkInstallmentPaid(int installmentId) async {
    final db = await instance.database;

    await db.update(
      "installments",
      {"paid": 0},
      where: "id = ?",
      whereArgs: [installmentId],
    );
  }

  // ────────────────────────────────────────────────
  // ELIMINAR CRÉDITO
  // ────────────────────────────────────────────────
  Future<void> deleteCredit(int creditId) async {
    final db = await instance.database;

    // Primero eliminar las cuotas asociadas
    await db.delete(
      "installments",
      where: "creditId = ?",
      whereArgs: [creditId],
    );

    // Luego eliminar el crédito
    await db.delete(
      "credits",
      where: "id = ?",
      whereArgs: [creditId],
    );
  }
}
