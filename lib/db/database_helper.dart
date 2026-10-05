import 'package:sqflite/sqflite.dart';

import '../models/record.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    final path = '$dir/bookkeeping.db';
    return openDatabase(
        path,
        version: 1,
      onCreate: (db,version) async{
          await db.execute('''
           CREATE TABLE records(
           id INTEGER PRIMARY KEY AUTOINCREMENT,
           amount REAL NOT NULL,
           is_expense INTEGER NOT NULL,
           category TEXT NOT NULL,
           note TEXT,
           date TEXT NOT NULL
           )
          ''');
      },
    );
  }

  Future<List<Record>> getRecords() async{
    final db = await database;
    final list = await db.query('records',orderBy: 'date DESC,id DESC');
    return list.map((e)=> Record.fromMap(e)).toList();
  }

  Future<int> insertRecord(Record r) async{
    final db = await database;
    final map = r.toMap()..remove('id');
    return db.insert('records', map);
  }

  Future<int> updateRecord(Record r) async{
    final db = await database;
    return db.update('records', r.toMap(),where: 'id = ?',whereArgs: [r.id]);
  }
}
