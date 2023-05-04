import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:ini_news_flutter/globals.dart';
import 'package:ini_news_flutter/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = AppTheme.isDark;

  @override
  void initState() {
    super.initState();

    _getThemeState();
    currentTheme.addListener(() {
      debugPrint('Theme changed!');
      setState(() {});
    });
    debugPrint('AppTheme.isDark: ${AppTheme.isDark}');
  }

  Future<void> _getThemeState() async {
    if (themeBox!.get('isDarkMode') == AppTheme.isDark) {
      setState(() {
        isDarkMode = themeBox!.get('isDarkMode') ?? false;
      });
    }

    debugPrint('AppTheme.isDark: ${AppTheme.isDark}');
    debugPrint('isDarkMode themeBox: ${themeBox!.get('isDarkMode')}');
    debugPrint('isDarkMode: $isDarkMode');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dark Mode',
              style: TextStyle(
                color: FlavorConfig.instance.variables['appBlack'],
                fontWeight: FontWeight.w700,
              ),
            ),
            Switch(
              value: isDarkMode,
              activeColor: Colors.white,
              activeTrackColor: Theme.of(context).primaryColor,
              inactiveThumbColor: FlavorConfig.instance.variables['appGrey'],
              inactiveTrackColor:
                  FlavorConfig.instance.variables['appLightGrey'],
              splashRadius: 50.0,
              onChanged: (value) async {
                currentTheme.switchTheme();

                setState(() {
                  isDarkMode = !isDarkMode;
                  themeBox!.put('isDarkMode', isDarkMode);
                });

                debugPrint('AppTheme.isDark: ${AppTheme.isDark}');
                debugPrint(
                    'isDarkMode themeBox: ${themeBox!.get('isDarkMode')}');
                debugPrint('isDarkMode: $isDarkMode');
              },
            )
          ],
        ),
      ],
    );
  }
}
