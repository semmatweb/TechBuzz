import 'dart:convert';
import 'logs.dart';

abstract class AppUsage {
  static String auth =
      'Basic ${base64.encode(utf8.encode('${AppLogs.id}:${AppLogs.sign}'))}';
}
