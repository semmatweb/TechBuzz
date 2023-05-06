import 'package:flutter/material.dart';
import 'package:ini_news_flutter/widgets/settings_switch.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../globals.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = AppTheme.isDark;
  bool isNotifEnabled = notifBox?.get('enablePushNotification') ?? false;

  @override
  void initState() {
    super.initState();
    _getThemeState();
    _getPushNotifState();
    debugPrint('AppTheme.isDark: ${AppTheme.isDark}');
  }

  Future<void> _getThemeState() async {
    if (themeBox!.get('isDarkMode') == AppTheme.isDark) {
      if (mounted) {
        setState(() {
          isDarkMode = themeBox!.get('isDarkMode') ?? false;
        });
      }
    }

    debugPrint('AppTheme.isDark: ${AppTheme.isDark}');
    debugPrint('isDarkMode themeBox: ${themeBox!.get('isDarkMode')}');
    debugPrint('isDarkMode: $isDarkMode');
  }

  Future<void> _getPushNotifState() async {
    await OneSignal.shared.getDeviceState().then((deviceState) {
      debugPrint(
          "Is device has notification permission: ${deviceState!.hasNotificationPermission}");

      if (!deviceState.hasNotificationPermission) {
        setState(() {
          isNotifEnabled = false;
          notifBox!.put('enablePushNotification', false);
        });
      } else {
        setState(() {
          isNotifEnabled = notifBox!.get('enablePushNotification') ?? false;
        });
      }
    });

    debugPrint('notifBox: ${notifBox!.get('enablePushNotification')}');
    debugPrint('isNotifEnabled: $isNotifEnabled');
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SettingsSwitch(
          switchName: 'Dark Mode',
          switchValue: isDarkMode,
          onChanged: (value) async {
            currentTheme.switchTheme();

            setState(() {
              isDarkMode = !isDarkMode;
              themeBox!.put('isDarkMode', isDarkMode);
            });

            debugPrint('AppTheme.isDark: ${AppTheme.isDark}');
            debugPrint('isDarkMode themeBox: ${themeBox!.get('isDarkMode')}');
            debugPrint('isDarkMode: $isDarkMode');
          },
        ),
        SettingsSwitch(
          switchName: 'Push Notification',
          switchValue: isNotifEnabled,
          onChanged: (value) async {
            await OneSignal.shared.getDeviceState().then(
              (deviceState) async {
                debugPrint(
                    "Is device has notification permission: ${deviceState!.hasNotificationPermission}");

                if (isNotifEnabled == false &&
                    !deviceState.hasNotificationPermission) {
                  await OneSignal.shared
                      .promptUserForPushNotificationPermission()
                      .then(
                    (promptResult) {
                      setState(() {
                        isNotifEnabled = promptResult;
                        notifBox!.put('enablePushNotification', promptResult);
                      });

                      debugPrint("Accepted permission: $promptResult");
                      debugPrint(
                          'notifBox: ${notifBox!.get('enablePushNotification')}');
                    },
                  );
                } else {
                  OneSignal.shared.disablePush(!value);

                  debugPrint('isPushDisabled: ${!deviceState.pushDisabled}');

                  setState(() {
                    isNotifEnabled = value;
                    notifBox!.put('enablePushNotification', value);
                  });
                }

                debugPrint('isNotifEnabled: $isNotifEnabled');
                debugPrint(
                    'notifBox: ${notifBox!.get('enablePushNotification')}');
              },
            );
          },
        ),
      ],
    );
  }
}
