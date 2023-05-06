import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
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
            Text(
              'General'.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1,
                color: FlavorConfig.instance.variables['appDarkGrey'],
              ),
            ),
            const SizedBox(height: 15),
            SettingsSwitch(
              icon: Icons.dark_mode,
              iconForegroundColor: isDarkMode
                  ? AppTheme.isDark
                      ? FlavorConfig
                          .instance.variables['appSecondaryAccentColor']
                      : Colors.orange[300]
                  : Theme.of(context).iconTheme.color!,
              iconBackgroundColor: isDarkMode
                  ? AppTheme.isDark
                      ? Colors.orange[300]
                      : FlavorConfig
                          .instance.variables['appSecondaryAccentColor']
                  : AppTheme.isDark
                      ? Theme.of(context).canvasColor
                      : FlavorConfig.instance.variables['appLightGrey'],
              switchName: 'Dark Mode',
              switchValue: isDarkMode,
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
              icon: isNotifEnabled
                  ? Icons.notifications_active
                  : Icons.notifications,
              iconForegroundColor: isNotifEnabled
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).iconTheme.color!,
              iconBackgroundColor: isNotifEnabled
                  ? AppTheme.isDark
                      ? FlavorConfig
                          .instance.variables['appDarkPrimaryAccentColor']
                      : FlavorConfig.instance.variables['appPrimaryAccentColor']
                  : AppTheme.isDark
                      ? Theme.of(context).canvasColor
                      : FlavorConfig.instance.variables['appLightGrey'],
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
            Text(
              'Article'.toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 1,
                color: FlavorConfig.instance.variables['appDarkGrey'],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      foregroundColor: Theme.of(context).iconTheme.color!,
                      backgroundColor: AppTheme.isDark
                          ? Theme.of(context).canvasColor
                          : FlavorConfig.instance.variables['appLightGrey'],
                      child: const Icon(Icons.short_text),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Article Font Size',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    child: DropDownTextField(
                      textFieldDecoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).canvasColor,
                        hintText: double.parse(
                                articleBox!.get('articleFontSize').toString())
                            .toStringAsFixed(0),
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium!.color,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: AppTheme.isDark
                              ? BorderSide.none
                              : BorderSide(
                                  color: FlavorConfig
                                      .instance.variables['appLightGrey'],
                                  width: 2,
                                ),
                        ),
                      ),
                      clearOption: false,
                      onChanged: (value) async {
                        var onChangedValue = value as DropDownValueModel;
                        await articleBox!
                            .put('articleFontSize', onChangedValue.value);
                      },
                      dropdownColor: Theme.of(context).canvasColor,
                      dropDownIconProperty: IconProperty(
                        icon: Icons.keyboard_arrow_down,
                      ),
                      textStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium!.color,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      listTextStyle: TextStyle(
                        color: AppTheme.isDark
                            ? Colors.white
                            : FlavorConfig.instance.variables['appBlack'],
                        fontWeight: FontWeight.w500,
                      ),
                      dropDownList: const [
                        DropDownValueModel(name: '8', value: 8.0),
                        DropDownValueModel(name: '10', value: 10.0),
                        DropDownValueModel(name: '12', value: 12.0),
                        DropDownValueModel(name: '14', value: 14.0),
                        DropDownValueModel(name: '16', value: 16.0),
                        DropDownValueModel(name: '18', value: 18.0),
                        DropDownValueModel(name: '20', value: 20.0),
                        DropDownValueModel(name: '24', value: 24.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
