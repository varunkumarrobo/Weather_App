import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/data_model.dart';



class DatabaseManager {
  late Database _database;

  Future<Database> initDb() async {
    _database = await openDatabase(join(await getDatabasesPath(), "weather.db"),
        version: 1, onCreate: (Database db, int version) async {
      await db.execute(
        "CREATE TABLE favourites(place TEXT NOT NULL, region TEXT NOT NULL, PRIMARY KEY(place, region))",
      );
      await db.execute(
        "CREATE TABLE recent(place TEXT NOT NULL, region TEXT NOT NULL, PRIMARY KEY(place, region))",
      );
    });
    return _database;
  }

  Future<void> insertFav(DataModel model) async {
    await initDb();
    await _database.insert('favourites', model.toJson());
  }

  Future<void> insertRecent(DataModel model) async {
    await initDb();
    await _database.insert('recent', model.toJson());
  }

  Future<void> deleteAllFav() async {
    await initDb();
    await _database.rawQuery("DELETE FROM favourites");
  }

  Future<void> deleteAllRecent() async {
    await initDb();
    await _database.rawQuery("DELETE FROM recent");
  }

  Future<void> deleteFav(DataModel model) async {
    await initDb();
    await _database.delete('favourites',
        where: "place = ? AND region = ?",
        whereArgs: [model.place, model.region]);
  }

  Future<void> deleteRecent(DataModel model) async {
    await initDb();
    await _database.delete('recent',
        where: "place = ? AND region = ?",
        whereArgs: [model.place, model.region]);
  }

  Future<List<DataModel>> getRecentFilterLike(String search) async {
    final db = await initDb();
    final List<Map<String, dynamic>> queryResult = await db
        .rawQuery("SELECT * FROM recent WHERE place LIKE '%$search%'");
    return List.generate(queryResult.length, (i) {
      return DataModel(
          place: queryResult[i]['place'], region: queryResult[i]['region']);
    });
  }

  Future<List<DataModel>> getFavFilterLike(String search) async {
    final db = await initDb();
    final List<Map<String, dynamic>> queryResult = await db
        .rawQuery("SELECT * FROM favourites WHERE place LIKE '%$search%'");
    return List.generate(queryResult.length, (i) {
      return DataModel(
          place: queryResult[i]['place'], region: queryResult[i]['region']);
    });
  }

  Future<List<DataModel>> getFav() async {
    final db = await initDb();
    final List<Map<String, dynamic>> queryResult = await db.query('favourites');
    return List.generate(queryResult.length, (i) {
      return DataModel(
          place: queryResult[i]['place'], region: queryResult[i]['region']);
    });
  }

  Future<List<DataModel>> getRecent() async {
    final db = await initDb();
    final List<Map<String, dynamic>> queryResult = await db.query('recent');
    return List.generate(queryResult.length, (i) {
      return DataModel(
          place: queryResult[i]['place'], region: queryResult[i]['region']);
    });
  }
}
