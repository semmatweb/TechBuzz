import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import '../models/post_model.dart';
import '../models/post_detail_model.dart';

class PostDetailController {
  final Dio dio = Dio(
    BaseOptions(
      receiveTimeout: const Duration(minutes: 1),
      connectTimeout: const Duration(minutes: 1),
    ),
  );
  final baseUrl = 'https://kontenation.com/wp-json/wp/v2';

  Future<PostDetail> getPostDetail(int? postID) async {
    var response = await dio.get('$baseUrl/posts/$postID');

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
      final response = await dio.get(
          '$baseUrl/posts?per_page=5&categories=$categoryID&search=$searchKeyword&orderby=relevance&exclude=$excludePostID');

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
