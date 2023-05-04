import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'globals.dart';
import 'screens/initialization_screen.dart';
import 'screens/post_detail_screen.dart';
import 'globals.dart' as globals;

Future<void> main() async {
  globals.appNavigator = GlobalKey<NavigatorState>();

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  introBox = await Hive.openBox('introductionState');
  themeBox = await Hive.openBox('themeState');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // OneSignal
  OneSignal.shared.setAppId("1f41b0aa-54fe-4ffc-80ae-73aecc2334ea");
  OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
    debugPrint("Accepted permission: $accepted");
  });

  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    var notifData = result.notification;

    globals.appNavigator!.currentState!.push(
      MaterialPageRoute(
        builder: (context) => PostDetailScreen(
          postID: notifData.additionalData!['post_id'],
        ),
      ),
    );
  });

  // AdMob
  MobileAds.instance.initialize();
  RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: ["E8E1B15D5B7D475188AC1CCC9BA5D5B1"]);
  MobileAds.instance.updateRequestConfiguration(configuration);

  // App-wide Config
  FlavorConfig(
    variables: {
      'apiBaseUrl': 'https://dummycontent.inito.dev/wp-json/wp/v2',
      'appName': 'iniNews',
      'appDefaultFont': 'Inter',
      'appPrimarySwatch': Colors.indigo,
      'appPrimaryColor': const Color.fromARGB(255, 60, 95, 150),
      'appPrimaryAccentColor': const Color.fromARGB(255, 220, 230, 240),
      'appSecondaryColor': const Color.fromARGB(255, 255, 150, 40),
      'appSecondaryAccentColor': const Color.fromARGB(255, 255, 230, 200),
      'appLightGrey': const Color.fromARGB(255, 232, 232, 232),
      'appGrey': const Color.fromARGB(255, 192, 192, 192),
      'appDarkGrey': const Color.fromARGB(255, 114, 114, 114),
      'appBlack': const Color.fromARGB(255, 54, 54, 54),
    },
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      debugPrint('Theme changed!');
      setState(() {});
    });
  }

  /* Future<void> _getThemeState() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('isDarkMode') == AppTheme.isDark) {
      setState(() {
        isDarkMode = prefs.getBool('isDarkMode') ?? false;
      });
    }

    debugPrint('AppTheme.isDark: ${AppTheme.isDark}');
    debugPrint('isDarkMoode prefs: ${prefs.getBool('isDarkMode')}');
    debugPrint('isDarkMode: $isDarkMode');
  } */

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: FlavorConfig.instance.variables['appName'],
      themeMode: currentTheme.currentTheme(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
        primaryColor: FlavorConfig.instance.variables['appPrimaryColor'],
        primarySwatch: FlavorConfig.instance.variables['appPrimarySwatch'],
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: FlavorConfig.instance.variables['appSecondaryColor'],
          surfaceVariant: Colors.blue,
          onSurfaceVariant: FlavorConfig.instance.variables['appGrey'],
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          surfaceTintColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
        primaryColor: Colors.red,
        primarySwatch: FlavorConfig.instance.variables['appPrimarySwatch'],
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: FlavorConfig.instance.variables['appSecondaryColor'],
          surfaceVariant: Colors.red,
          onSurfaceVariant: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          surfaceTintColor: Colors.white,
        ),
      ),
      navigatorKey: globals.appNavigator,
      initialRoute: '/',
      routes: {
        '/': (context) => const InitializationScreen(),
      },
    );
  }
}

/* bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _getThemeState();
  }

  Future<void> _getThemeState() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });

    debugPrint('prefs: ${prefs.getBool('isDarkMode')}');
    debugPrint('isDarkMode: $isDarkMode');
  } */
