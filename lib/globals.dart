library ininews.globals;

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../theme.dart';

GlobalKey<NavigatorState>? appNavigator;

AppTheme currentTheme = AppTheme();
Box? introBox;
Box? themeBox;
Box? notifBox;
Box? articleBox;
