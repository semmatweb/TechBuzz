import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:ini_news_flutter/theme.dart';

class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.icon,
    required this.iconForegroundColor,
    required this.iconBackgroundColor,
    required this.switchName,
    required this.switchValue,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconForegroundColor;
  final Color iconBackgroundColor;
  final String switchName;
  final bool switchValue;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              foregroundColor: iconForegroundColor,
              backgroundColor: iconBackgroundColor,
              child: Icon(icon),
            ),
            const SizedBox(width: 10),
            Text(
              switchName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Switch(
          value: switchValue,
          activeColor: Colors.white,
          activeTrackColor: AppTheme.isDark
              ? FlavorConfig.instance.variables['appDarkPrimaryAccentColor']
              : Theme.of(context).primaryColor,
          inactiveThumbColor: AppTheme.isDark
              ? Theme.of(context).iconTheme.color
              : FlavorConfig.instance.variables['appGrey'],
          inactiveTrackColor: AppTheme.isDark
              ? Theme.of(context).canvasColor
              : FlavorConfig.instance.variables['appLightGrey'],
          splashRadius: 50.0,
          onChanged: onChanged,
        )
      ],
    );
  }
}
