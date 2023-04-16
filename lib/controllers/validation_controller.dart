import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';

class ValidationController {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://shop.inito.dev/wp-json/lmfwc/v2/licenses/validate',
      receiveTimeout: const Duration(minutes: 1),
      connectTimeout: const Duration(minutes: 1),
    ),
  );

  Future<Response<void>?> getValidation() async {
    String apiKey = FlavorConfig.instance.variables['apiKey'];
    const String username = 'ck_731e1ecd9f642546b158aba7d160775936cef085';
    const String password = 'cs_bf054dc20ca4f47ea304136c28292ad0f8b290dd';
    final String basicAuth =
        'Basic ${base64.encode(utf8.encode('$username:$password'))}';

    Response<void>? response;
    try {
      response = await dio.get(
        '/$apiKey',
        options: Options(
          headers: {'authorization': basicAuth},
        ),
      );
    } on DioError catch (e) {
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
    return response;
  }
}
