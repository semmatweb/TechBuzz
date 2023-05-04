library ininews.globals;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:ini_news_flutter/theme.dart';

GlobalKey<NavigatorState>? appNavigator;

AppTheme currentTheme = AppTheme();
Box? introBox;
Box? themeBox;
