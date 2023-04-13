import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/post_model.dart';
import '../models/tag_model.dart';

class TagController {
  final Dio dio = Dio(
    BaseOptions(
      receiveTimeout: const Duration(minutes: 1),
      connectTimeout: const Duration(minutes: 1),
    ),
  );
  final baseUrl = 'https://kontenation.com/wp-json/wp/v2';

  final numberOfPostsPerRequest = 10;
  final PagingController<int, Post> filteredPostController =
      PagingController(firstPageKey: 1);

  Future<List<Tag>?> getAllTagsFromPost(int postID) async {
    List<Tag>? tagList;
    try {
      var response = await dio.get('$baseUrl/tags?post=$postID');

      List? tagData = response.data;
      tagList = tagData!.map((e) => Tag.fromJson(e)).toList();
    } on DioError catch (e) {
      if (e.response != null) {
        debugPrint('Dio error!');
        debugPrint('STATUS: ${e.response?.statusCode}');
        debugPrint('DATA: ${e.response?.data}');
        debugPrint('HEADERS: ${e.response?.headers}');
      } else {
        debugPrint('Error sending request!');
        debugPrint(e.message);
      }
    }
    return tagList;
  }

  Future<List<Post>?> getTagPost({
    required int pageKey,
    required int tagID,
    required PagingController<int, Post> postPagingController,
  }) async {
    List<Post>? postList;
    try {
      final response =
          await dio.get('$baseUrl/posts?page=$pageKey&tags=$tagID');

      List? postData = response.data;
      postList = postData!.map((e) => Post.fromJson(e)).toList();

      final isLastPage = postList.length < numberOfPostsPerRequest;
      if (isLastPage) {
        postPagingController.appendLastPage(postList);
      } else {
        final nextPageKey = pageKey + 1;
        postPagingController.appendPage(postList, nextPageKey);
      }
    } on DioError catch (e) {
      if (e.response != null) {
        debugPrint('HomeTabController: Dio error!');
        debugPrint('HomeTabController: STATUS: ${e.response?.statusCode}');
        debugPrint('HomeTabController: DATA: ${e.response?.data}');
        debugPrint('HomeTabController: HEADERS: ${e.response?.headers}');
      } else {
        debugPrint('HomeTabController: DIO: Error sending request!');
        debugPrint('HomeTabController: DIO: ${e.message}');
      }
    }
    return postList;
  }
}
