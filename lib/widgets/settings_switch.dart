import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import '../theme.dart';

class SettingsSwitch extends StatelessWidget {
  const SettingsSwitch({
    super.key,
    required this.settingicon,
    required this.settingIconForegroundColor,
    required this.settingIconBackgroundColor,
    required this.settingName,
    required this.switchValue,
    this.switchLightTrackColor,
    this.switchDarkTrackColor,
    required this.onChanged,
  });

  final IconData settingicon;
  final Color settingIconForegroundColor;
  final Color settingIconBackgroundColor;
  final String settingName;
  final bool switchValue;
  final Color? switchLightTrackColor;
  final Color? switchDarkTrackColor;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              foregroundColor: settingIconForegroundColor,
              backgroundColor: settingIconBackgroundColor,
              child: Icon(settingicon),
            ),
            const SizedBox(width: 10),
            Text(
              settingName,
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
              ? switchDarkTrackColor ??
                  FlavorConfig.instance.variables['appDarkPrimaryAccentColor']
              : switchLightTrackColor ?? Theme.of(context).primaryColor,
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
