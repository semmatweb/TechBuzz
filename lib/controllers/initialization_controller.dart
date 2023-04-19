import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../resources/caches/services/logs.dart';
import '../resources/caches/services/services.dart';
import '../resources/caches/services/usage.dart';

class InitializationController {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: AppServices.core,
      receiveTimeout: const Duration(minutes: 1),
      connectTimeout: const Duration(minutes: 1),
    ),
  );

  Future<Response<void>?> getState() async {
    Response<void>? response;

    try {
      response = await dio.get(
        AppLogs.key,
        options: Options(
          headers: {'authorization': AppUsage.auth},
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
