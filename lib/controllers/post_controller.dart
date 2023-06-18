import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/menu_model.dart';
import '../models/post_model.dart';

class PostController {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: FlavorConfig.instance.variables['apiBaseUrl'],
      receiveTimeout: const Duration(seconds: 20),
      connectTimeout: const Duration(seconds: 20),
    ),
  );

  final numberOfPostsPerRequest = 10;
  final PagingController<int, Post> allPostController =
      PagingController(firstPageKey: 1);

  final PagingController<int, Post> firstCategoryPostController =
      PagingController(firstPageKey: 1);

  final PagingController<int, Post> secondCategoryPostController =
      PagingController(firstPageKey: 1);

  final PagingController<int, Post> thirdCategoryPostController =
      PagingController(firstPageKey: 1);

  final PagingController<int, Post> fourthCategoryPostController =
      PagingController(firstPageKey: 1);

  Future<List<Post>?> getAllPost(int pageKey) async {
    List<Post>? postList;
    try {
      final response = await dio.get('/posts', queryParameters: {
        'page': pageKey,
      });

      List? postData = response.data;
      postList = postData!.map((e) => Post.fromJson(e)).toList();

      final isLastPage = postList.length < numberOfPostsPerRequest;
      if (isLastPage) {
        allPostController.appendLastPage(postList);
      } else {
        final nextPageKey = pageKey + 1;
        allPostController.appendPage(postList, nextPageKey);
      }
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('PostController: Dio error!');
        debugPrint('PostController: STATUS: ${e.response?.statusCode}');
        debugPrint('PostController: DATA: ${e.response?.data}');
        debugPrint('PostController: HEADERS: ${e.response?.headers}');
      } else {
        debugPrint('PostController: DIO: Error sending request!');
        debugPrint('PostController: DIO: ${e.message}');
      }
    }
    return postList;
  }

  Future<Menu?> getAllMenu() async {
    Menu? menu;
    try {
      final response = await dio.get('/menus');
      menu = Menu.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('PostController: Dio error!');
        debugPrint('PostController: STATUS: ${e.response?.statusCode}');
        debugPrint('PostController: DATA: ${e.response?.data}');
        debugPrint('PostController: HEADERS: ${e.response?.headers}');
      } else {
        debugPrint('PostController: DIO: Error sending request!');
        debugPrint('PostController: DIO: ${e.message}');
      }
    }
    return menu;
  }

  Future<List<Post>?> getFilteredPost({
    required int pageKey,
    required int categoryIndex,
    required PagingController<int, Post> postPagingController,
  }) async {
    List<Post>? postList;
    try {
      final menuResponse = await dio.get('/menus');

      Map<String, dynamic> menuData = menuResponse.data;

      Menu menuResult = Menu.fromJson(menuData);

      int categoryID =
          int.parse(menuResult.primary[categoryIndex].parent.itemId);

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
        debugPrint('PostController: Dio error!');
        debugPrint('PostController: STATUS: ${e.response?.statusCode}');
        debugPrint('PostController: DATA: ${e.response?.data}');
        debugPrint('PostController: HEADERS: ${e.response?.headers}');
      } else {
        debugPrint('PostController: DIO: Error sending request!');
        debugPrint('PostController: DIO: ${e.message}');
      }
    }
    return postList;
  }
}
