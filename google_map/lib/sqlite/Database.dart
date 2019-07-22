import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
class DBProvider{
  DBProvider._();
  static final DBProvider db = DBProvider._();

  //set up the database
  static Database _database;
  Future<Database> get database async{
    if(_database != null)
    return _database;

    //if dtb == null =>initialize a new one
    _database = await initDB();
    return _database;
  }
}
initDB() async{
  Directory directory = await getApplicationDocumentsDirectory();
  String path = join(directory.path, 'User.db');
  return await openDatabase(path, version: 1, onOpen: (db) {},
  onCreate: (Database db, int version) async{
    await db.execute('CREATE TABLE Client('
    'id INTEGER PRIMARY KEY,'
    'time TEXT,'
    'location TEXT,');
  });
}