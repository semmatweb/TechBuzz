import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/post_model.dart';
import '../models/tag_model.dart';

class TagController {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: FlavorConfig.instance.variables['apiBaseUrl'],
      receiveTimeout: const Duration(seconds: 20),
      connectTimeout: const Duration(seconds: 20),
    ),
  );

  final numberOfPostsPerRequest = 10;
  final PagingController<int, Post> filteredPostController =
      PagingController(firstPageKey: 1);

  Future<List<Tag>?> getAllTagsFromPost(int postID) async {
    List<Tag>? tagList;
    try {
      var response = await dio.get('/tags?post=$postID');

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
      final response = await dio.get('/posts', queryParameters: {
        'page': pageKey,
        'tags': tagID,
      });

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
        debugPrint('TagController: Dio error!');
        debugPrint('TagController: STATUS: ${e.response?.statusCode}');
        debugPrint('TagController: DATA: ${e.response?.data}');
        debugPrint('TagController: HEADERS: ${e.response?.headers}');
      } else {
        debugPrint('TagController: DIO: Error sending request!');
        debugPrint('TagController: DIO: ${e.message}');
      }
    }
    return postList;
  }
}
