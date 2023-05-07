import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import '../theme.dart';

class SettingsLink extends StatelessWidget {
  const SettingsLink({
    super.key,
    required this.settingName,
    required this.settingIcon,
    required this.linkUrl,
  });

  final String settingName;
  final IconData settingIcon;
  final String linkUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              foregroundColor: Theme.of(context).iconTheme.color!,
              backgroundColor: AppTheme.isDark
                  ? Theme.of(context).canvasColor
                  : FlavorConfig.instance.variables['appLightGrey'],
              child: Icon(settingIcon),
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
        IconButton(
          onPressed: () {
            FlutterWebBrowser.openWebPage(
              url: linkUrl,
              customTabsOptions: CustomTabsOptions(
                defaultColorSchemeParams: CustomTabsColorSchemeParams(
                  toolbarColor: Theme.of(context).primaryColor,
                ),
                showTitle: true,
              ),
            );
          },
          icon: const Icon(Icons.open_in_new),
        )
      ],
    );
  }
}
