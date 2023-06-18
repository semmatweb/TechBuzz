import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/category_model.dart';
import '../models/post_model.dart';

class CategoryController {
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

  Future<List<Category>?> getAllCategories() async {
    List<Category>? categoryList;
    try {
      var response = await dio.get('/categories');

      List? categoryData = response.data;
      categoryList = categoryData!.map((e) => Category.fromJson(e)).toList();
    } on DioException catch (e) {
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
    return categoryList;
  }

  Future<List<Post>?> getCategoryPost({
    required int pageKey,
    required int categoryID,
    required PagingController<int, Post> postPagingController,
  }) async {
    List<Post>? postList;
    try {
      final response = await dio.get('/posts', queryParameters: {
        'page': pageKey,
        'categories': categoryID,
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
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('CategoryController: Dio error!');
        debugPrint('CategoryController: STATUS: ${e.response?.statusCode}');
        debugPrint('CategoryController: DATA: ${e.response?.data}');
        debugPrint('CategoryController: HEADERS: ${e.response?.headers}');
      } else {
        debugPrint('CategoryController: DIO: Error sending request!');
        debugPrint('CategoryController: DIO: ${e.message}');
      }
    }
    return postList;
  }
}
