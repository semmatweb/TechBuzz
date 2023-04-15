import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/post_model.dart';

class SearchController {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: FlavorConfig.instance.variables['apiBaseUrl'],
      receiveTimeout: const Duration(minutes: 1),
      connectTimeout: const Duration(minutes: 1),
    ),
  );

  final numberOfPostsPerRequest = 10;
  final PagingController<int, Post> searchPostController =
      PagingController(firstPageKey: 1);

  Future<List<Post>?> getSearchResult({
    required int pageKey,
    required String searchKeyword,
    required PagingController<int, Post> postPagingController,
  }) async {
    List<Post>? searchResultList;
    try {
      final response = await dio.get('/posts', queryParameters: {
        'page': pageKey,
        'search': searchKeyword,
        'orderby': 'relevance',
      });

      List? searchResultData = response.data;
      searchResultList =
          searchResultData!.map((e) => Post.fromJson(e)).toList();

      final isLastPage = searchResultList.length < numberOfPostsPerRequest;
      if (isLastPage) {
        postPagingController.appendLastPage(searchResultList);
      } else {
        final nextPageKey = pageKey + 1;
        postPagingController.appendPage(searchResultList, nextPageKey);
      }
    } on DioError catch (e) {
      if (e.response != null) {
        debugPrint('SearchController: Dio error!');
        debugPrint('SearchController: STATUS: ${e.response?.statusCode}');
        debugPrint('SearchController: DATA: ${e.response?.data}');
        debugPrint('SearchController: HEADERS: ${e.response?.headers}');
      } else {
        debugPrint('SearchController: DIO: Error sending request!');
        debugPrint('SearchController: DIO: ${e.message}');
      }
    }
    return searchResultList;
  }
}
