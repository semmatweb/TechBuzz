// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://shop.inito.dev/wp-json/lmfwc/v2/licenses/validate',
      receiveTimeout: const Duration(minutes: 1),
      connectTimeout: const Duration(minutes: 1),
    ),
  );

  String apiKey = 'USJF-YPJY-3VTF-QV8J';
  const String username = 'ck_731e1ecd9f642546b158aba7d160775936cef085';
  const String password = 'cs_bf054dc20ca4f47ea304136c28292ad0f8b290dd';
  final String basicAuth =
      'Basic ${base64.encode(utf8.encode('$username:$password'))}';

  var response = await dio.get(
    '/$apiKey',
    options: Options(
      headers: {'authorization': basicAuth},
    ),
  );
  debugPrint('${response.statusCode}');
  debugPrint('${response.data}');
}
