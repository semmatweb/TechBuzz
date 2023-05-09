import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../globals.dart';
import '../theme.dart';
import '../widgets/settings_dropdown.dart';
import '../widgets/settings_link.dart';
import '../widgets/settings_segment.dart';
import '../widgets/settings_switch.dart';

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
    _getArticleSettings();
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

  Future<void> _getArticleSettings() async {
    if (articleBox?.get('articleFontSize') == null) {
      await articleBox?.put('articleFontSize', 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SettingsSegment(segmentName: 'General'),
            const SizedBox(height: 15),
            SettingsSwitch(
              settingName: 'Dark Mode',
              settingicon: Icons.dark_mode,
              settingIconForegroundColor: isDarkMode
                  ? AppTheme.isDark
                      ? FlavorConfig
                          .instance.variables['appSecondaryAccentColor']
                      : Colors.orange[300]
                  : Theme.of(context).iconTheme.color!,
              settingIconBackgroundColor: isDarkMode
                  ? AppTheme.isDark
                      ? Colors.orange[300]
                      : FlavorConfig
                          .instance.variables['appSecondaryAccentColor']
                  : AppTheme.isDark
                      ? Theme.of(context).canvasColor
                      : FlavorConfig.instance.variables['appLightGrey'],
              switchValue: isDarkMode,
              switchDarkTrackColor: Colors.orange[300],
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
            ),
            const SizedBox(height: 15),
            SettingsSwitch(
              settingName: 'Push Notification',
              settingicon: isNotifEnabled
                  ? Icons.notifications_active
                  : Icons.notifications,
              settingIconForegroundColor: isNotifEnabled
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).iconTheme.color!,
              settingIconBackgroundColor: isNotifEnabled
                  ? AppTheme.isDark
                      ? FlavorConfig
                          .instance.variables['appDarkPrimaryAccentColor']
                      : FlavorConfig.instance.variables['appPrimaryAccentColor']
                  : AppTheme.isDark
                      ? Theme.of(context).canvasColor
                      : FlavorConfig.instance.variables['appLightGrey'],
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
                            notifBox!
                                .put('enablePushNotification', promptResult);
                          });

                          debugPrint("Accepted permission: $promptResult");
                          debugPrint(
                              'notifBox: ${notifBox!.get('enablePushNotification')}');
                        },
                      );
                    } else {
                      OneSignal.shared.disablePush(!value);

                      debugPrint(
                          'isPushDisabled: ${!deviceState.pushDisabled}');

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
            const SizedBox(height: 30),
            const SettingsSegment(segmentName: 'Article'),
            const SizedBox(height: 15),
            SettingsDropdown(
              settingName: 'Article Font Size',
              settingIcon: Icons.short_text,
              dropdownHintText:
                  double.parse(articleBox!.get('articleFontSize').toString())
                      .toStringAsFixed(0),
              dropdownList: const [
                DropDownValueModel(name: '8', value: 8.0),
                DropDownValueModel(name: '10', value: 10.0),
                DropDownValueModel(name: '12', value: 12.0),
                DropDownValueModel(name: '14', value: 14.0),
                DropDownValueModel(name: '16', value: 16.0),
                DropDownValueModel(name: '18', value: 18.0),
                DropDownValueModel(name: '20', value: 20.0),
                DropDownValueModel(name: '24', value: 24.0),
              ],
              onChanged: (value) async {
                var onChangedValue = value as DropDownValueModel;
                await articleBox!.put('articleFontSize', onChangedValue.value);
              },
            ),
            const SizedBox(height: 30),
            const SettingsSegment(segmentName: 'Info'),
            const SizedBox(height: 15),
            SettingsLink(
              settingName: 'Terms and Conditions',
              settingIcon: Icons.feed,
              linkUrl: FlavorConfig.instance.variables['termsAndConditionsUrl'],
            ),
            const SizedBox(height: 15),
            SettingsLink(
              settingName: 'Privacy Policy',
              settingIcon: Icons.policy,
              linkUrl: FlavorConfig.instance.variables['privacyPolicyUrl'],
            ),
            const SizedBox(height: 15),
            SettingsLink(
              settingName: 'Contact Us',
              settingIcon: Icons.phone,
              linkUrl: FlavorConfig.instance.variables['contactUsUrl'],
            ),
          ],
        ),
      ],
    );
  }
}
