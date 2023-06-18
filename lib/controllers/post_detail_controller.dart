import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import '../models/post_model.dart';
import '../models/post_detail_model.dart';

class PostDetailController {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: FlavorConfig.instance.variables['apiBaseUrl'],
      receiveTimeout: const Duration(seconds: 20),
      connectTimeout: const Duration(seconds: 20),
    ),
  );

  Future<PostDetail?> getPostDetail(int? postID) async {
    PostDetail? postDetail;
    try {
      final response = await dio.get('/posts/$postID');
      postDetail = PostDetail.fromJson(response.data);
    } on DioException catch (e) {
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
    return postDetail;
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
    } on DioException catch (e) {
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
