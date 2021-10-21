import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:teachers/models/menu.dart';
import 'package:teachers/models/user.dart';
import 'package:sqflite/sqflite.dart';

class DBHandler {
  static const int DB_VERSION = 4;
  static Database _db;
  static const String DB_NAME = 'softcampus_teacher.db';
  static const String TABLE_USER_MASTER = 'user_master';
  static const String TABLE_MENU_MASTER = 'menu_master';
  static const String CREATE_USER_MASTER_TABLE =
      'CREATE TABLE $TABLE_USER_MASTER (' +
          '${UserFieldNames.user_no} INTEGER,' +
          '${UserFieldNames.user_id} TEXT,' +
          '${UserFieldNames.user_password} TEXT,' +
          '${UserFieldNames.emp_no} INTEGER,' +
          '${UserFieldNames.emp_name} TEXT,' +
          '${UserFieldNames.brcode} TEXT,' +
          '${UserFieldNames.interbr_report} TEXT,' +
          '${UserFieldNames.yr_no} INTEGER,' +
          '${UserFieldNames.academic_year} TEXT,' +
          '${UserFieldNames.client_code} TEXT,' +
          '${UserFieldNames.class_id} INTEGER,' +
          '${UserFieldNames.class_name} TEXT,' +
          '${UserFieldNames.division_id} INTEGER,' +
          '${UserFieldNames.division_name} TEXT,' +
          '${UserFieldNames.section_id} INTEGER,' +
          '${UserFieldNames.section_name} TEXT,' +
          '${UserFieldNames.clientName} TEXT,' +
          '${UserFieldNames.is_logged_in} ,' +
          '${UserFieldNames.remember_me} INTEGER)';

  static const String CREATE_MENU_MASTER_TABLE =
      'CREATE TABLE $TABLE_MENU_MASTER (' +
          '${MenuFieldNames.MenuNo} INTEGER,' +
          '${MenuFieldNames.MenuFor} TEXT,' +
          '${MenuFieldNames.MenuName} TEXT,' +
          '${MenuFieldNames.MenuType} TEXT,' +
          '${MenuFieldNames.Status} TEXT)';

  Future<Database> get db async {
    if (_db == null) {
      _db = await _initDatabase();
    }
    return _db;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, DB_NAME);
    var db = await openDatabase(path, version: DB_VERSION, onCreate: _onCreate,onUpgrade: _onUpgrade);
    return db;
  }

  _onCreate(Database db, int version) async {
    //Create User TABLE_USER
    await db.execute(CREATE_USER_MASTER_TABLE);
    await db.execute(CREATE_MENU_MASTER_TABLE);
  }
  _onUpgrade(Database db,  int oldVersion, int newVersion) async {

    await db.execute("DROP TABLE IF EXISTS $TABLE_USER_MASTER");
    await db.execute("DROP TABLE IF EXISTS $TABLE_MENU_MASTER");
    _onCreate(db, newVersion);
  }

  Future<User> saveUser(User user) async {
    try {
      var dbClient = await db;
      await dbClient.insert(
        TABLE_USER_MASTER,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User> login(User user) async {
    try {
      var dbClient = await db;
      user.is_logged_in = 1;
      await dbClient.update(
        TABLE_USER_MASTER,
        user.toJson(),
        where:
            '${UserFieldNames.user_id} = ? AND ${UserFieldNames.user_password} = ?',
        whereArgs: [
          user.user_id,
          user.user_password,
        ],
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      var dbClient = await db;
      await dbClient.delete(TABLE_USER_MASTER);
      return true;
    } catch (e) {
      return null;
    }
  }

  Future<User> updateUser(User user) async {
    try {
      var dbClient = await db;
      await dbClient.update(
        TABLE_USER_MASTER,
        user.toJson(),
        where: '${UserFieldNames.user_id} = ?',
        whereArgs: [
          user.user_id,
        ],
      );
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User> getUser(String userID, String userPassword) async {
    try {
      var dbClient = await db;
      List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_USER_MASTER WHERE ${UserFieldNames.user_id} = ? AND ${UserFieldNames.user_password} = ?",
        [
          userID,
          userPassword,
        ],
      );

      return User.fromJson(maps[0]);
    } catch (e) {
      return null;
    }
  }

  Future<User> getLoggedInUser() async {
    try {
      var dbClient = await db;
      List<Map> maps = await dbClient.rawQuery(
        "SELECT * FROM $TABLE_USER_MASTER WHERE ${UserFieldNames.is_logged_in} = 1",
        null,
      );

      return User.fromJson(maps[0]);
    } catch (e) {
      return null;
    }
  }

  Future<List<User>> getUsersList() async {
    try {
      var dbClient = await db;
      final List<Map<String, dynamic>> maps =
          await dbClient.query(TABLE_USER_MASTER);

      List<User> users = [];
      users = maps
          .map(
            (item) => User.fromJson(item),
          )
          .toList();

      return users;
    } catch (e) {
      return null;
    }
  }

  Future<void> saveMenu(List<Menu> menus) async {
    try {
      var dbClient = await db;
      await deleteAllMenus();
      for (var menu in menus) {
        await dbClient.insert(
          TABLE_MENU_MASTER,
          menu.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> deleteAllMenus() async {
    try {
      var dbClient = await db;
      await dbClient.delete(TABLE_MENU_MASTER);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Menu>> getMenus() async {
    try {
      var dbClient = await db;

      final List<Map<String, dynamic>> maps =
          await dbClient.query(TABLE_MENU_MASTER);

      List<Menu> menus = [];

      menus = maps
          .map(
            (item) => Menu.fromMap(item),
          )
          .toList();

      return menus;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
