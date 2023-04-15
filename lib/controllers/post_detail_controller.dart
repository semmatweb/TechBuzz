import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import '../models/post_model.dart';
import '../models/post_detail_model.dart';

class PostDetailController {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: FlavorConfig.instance.variables['apiBaseUrl'],
      receiveTimeout: const Duration(minutes: 1),
      connectTimeout: const Duration(minutes: 1),
    ),
  );

  Future<PostDetail> getPostDetail(int? postID) async {
    var response = await dio.get('/posts/$postID');

    Map<String, dynamic> postDetailData = response.data;

    return PostDetail.fromJson(postDetailData);
  }

  Future<List<Post>?> getRelatedPost({
    required int categoryID,
    required int excludePostID,
    required String searchKeyword,
  }) async {
    List<Post>? postList;
    try {
      final response = await dio.get('/posts', queryParameters: {
        'search': searchKeyword,
        'categories': categoryID,
        'per_page': 5,
        'orderby': 'relevance',
        'exclude': excludePostID,
      });

      List? postData = response.data;
      postList = postData!.map((e) => Post.fromJson(e)).toList();
    } on DioError catch (e) {
      if (e.response != null) {
        debugPrint('PostDetailController: Dio error!');
        debugPrint('PostDetailController: STATUS: ${e.response?.statusCode}');
        debugPrint('PostDetailController: DATA: ${e.response?.data}');
        debugPrint('PostDetailController: HEADERS: ${e.response?.headers}');
      } else {
        debugPrint('PostDetailController: DIO: Error sending request!');
        debugPrint('PostDetailController: DIO: ${e.message}');
      }
    }
    return postList;
  }
}
