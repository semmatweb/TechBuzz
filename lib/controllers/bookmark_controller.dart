import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../databases/bookmark_database.dart';

class BookmarkController {
  BookmarkDBManager bookmarkDatabase = BookmarkDBManager.instance;

  Future<List<Map<String, dynamic>>> getBookmark() async {
    Database db = await bookmarkDatabase.db;
    List<Map<String, dynamic>> bookmarkList = await db.query(
      "post_bookmark",
      orderBy: "id DESC",
    );
    debugPrint('$bookmarkList');
    return bookmarkList;
  }

  Future<void> addBookmark({
    required int postID,
    required String postTitle,
    required String postCategory,
    required String postDateTime,
    required String postImageUrl,
  }) async {
    Database db = await bookmarkDatabase.db;

    await db.insert(
      "post_bookmark",
      {
        "post_id": postID,
        "post_title": postTitle,
        "post_category": postCategory,
        "post_datetime": postDateTime,
        "post_imageurl": postImageUrl,
        "is_bookmarked": 1,
      },
    );
    var data = await db.query("post_bookmark");
    debugPrint('$data');
  }
}
