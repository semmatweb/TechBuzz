import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:ini_news_flutter/theme.dart';

class RefreshState extends StatelessWidget {
  const RefreshState({
    super.key,
    required this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.isDark
              ? FlavorConfig.instance.variables['appDarkPrimaryAccentColor']
              : FlavorConfig.instance.variables['appPrimaryAccentColor'],
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        icon: Icon(
          Icons.refresh,
          color: Theme.of(context).primaryColor,
        ),
        label: Text(
          'Retry',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
