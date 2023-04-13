import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class BookmarkDBManager {
  BookmarkDBManager._private();

  static BookmarkDBManager instance = BookmarkDBManager._private();

  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDB();
    return _db!;
  }

  Future _initDB() async {
    Directory documentDir = await getApplicationDocumentsDirectory();

    String path = join(documentDir.path, "post_bookmark.db");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (database, version) async {
        return await database.execute('''
            CREATE TABLE post_bookmark (
              id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
              post_id INTEGER NOT NULL,
              post_title TEXT NOT NULL,
              post_category TEXT NOT NULL,
              post_datetime TEXT NOT NULL,
              post_imageurl TEXT NOT NULL,
              is_bookmarked INTEGER DEFAULT 0
            )
          ''');
      },
    );
  }

  Future closeDB() async {
    _db = await instance.db;
    _db!.close();
  }
}
