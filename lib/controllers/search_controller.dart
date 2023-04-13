import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../models/post_model.dart';

class SearchController {
  final Dio dio = Dio(
    BaseOptions(
      receiveTimeout: const Duration(minutes: 1),
      connectTimeout: const Duration(minutes: 1),
    ),
  );
  final baseUrl = 'https://kontenation.com/wp-json/wp/v2';

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
      final response = await dio.get(
          '$baseUrl/posts?page=$pageKey&search=$searchKeyword&orderby=relevance');

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
        debugPrint('HomeTabController: Dio error!');
        debugPrint('HomeTabController: STATUS: ${e.response?.statusCode}');
        debugPrint('HomeTabController: DATA: ${e.response?.data}');
        debugPrint('HomeTabController: HEADERS: ${e.response?.headers}');
      } else {
        debugPrint('HomeTabController: DIO: Error sending request!');
        debugPrint('HomeTabController: DIO: ${e.message}');
      }
    }
    return searchResultList;
  }
}
