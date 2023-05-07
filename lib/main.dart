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

Future<void> main() async {
  appNavigator = GlobalKey<NavigatorState>();

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Hive.initFlutter();
  introBox = await Hive.openBox('introductionState');
  themeBox = await Hive.openBox('themeState');
  notifBox = await Hive.openBox('notifState');
  articleBox = await Hive.openBox('articleSettings');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  // OneSignal
  OneSignal.shared.setAppId("1f41b0aa-54fe-4ffc-80ae-73aecc2334ea");

  OneSignal.shared
      .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
    var notifData = result.notification;

    appNavigator!.currentState!.push(
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
      RequestConfiguration(testDeviceIds: ["03ECFD73D1A81042944D176D4DE6C0EA"]);
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
      'appDarkPrimarySwatch': Colors.indigo,
      'appDarkPrimaryAccentColor': const Color.fromARGB(255, 38, 68, 120),
      'appDarkPrimaryColor': const Color.fromARGB(255, 168, 200, 255),
      'appDarkSecondaryColor': const Color.fromARGB(255, 255, 230, 200),
      'appDarkSecondaryAccentColor': const Color.fromARGB(255, 255, 150, 40),
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
          primary: FlavorConfig.instance.variables['appPrimaryColor'],
          secondary: FlavorConfig.instance.variables['appSecondaryColor'],
          surfaceVariant: Colors.transparent,
          onSurfaceVariant: FlavorConfig.instance.variables['appGrey'],
        ),
        canvasColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          iconTheme:
              IconThemeData(color: FlavorConfig.instance.variables['appBlack']),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
            color: FlavorConfig.instance.variables['appBlack'],
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
            color: FlavorConfig.instance.variables['appBlack'],
          ),
          bodySmall: TextStyle(
            fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
            color: FlavorConfig.instance.variables['appDarkGrey'],
          ),
          displayLarge: TextStyle(
            fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
            color: FlavorConfig.instance.variables['appGrey'],
          ),
        ),
        iconTheme: IconThemeData(
          color: FlavorConfig.instance.variables['appGrey'],
        ),
        dividerTheme: DividerThemeData(
          color: FlavorConfig.instance.variables['appLightGrey'],
        ),
        cardTheme: const CardTheme(surfaceTintColor: Colors.transparent),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
        primaryColor: FlavorConfig.instance.variables['appDarkPrimaryColor'],
        primarySwatch: FlavorConfig.instance.variables['appDarkPrimarySwatch'],
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: FlavorConfig.instance.variables['appDarkPrimaryColor'],
          secondary: FlavorConfig.instance.variables['appDarkSecondaryColor'],
          surfaceVariant: Colors.transparent,
          onSurfaceVariant: const Color.fromARGB(255, 140, 140, 140),
        ),
        canvasColor: const Color.fromARGB(255, 40, 40, 40),
        scaffoldBackgroundColor: const Color.fromARGB(255, 24, 24, 24),
        appBarTheme: AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color.fromARGB(255, 24, 24, 24),
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        textTheme: TextTheme(
          bodyMedium: TextStyle(
            fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
            color: Colors.white,
          ),
          bodySmall: TextStyle(
            fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
            color: const Color.fromARGB(255, 140, 140, 140),
          ),
          displayLarge: TextStyle(
            fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
            color: const Color.fromARGB(255, 40, 40, 40),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 140, 140, 140),
        ),
        dividerTheme: const DividerThemeData(
          color: Color.fromARGB(255, 40, 40, 40),
        ),
        cardTheme: const CardTheme(surfaceTintColor: Colors.transparent),
      ),
      navigatorKey: appNavigator,
      initialRoute: '/',
      routes: {
        '/': (context) => const InitializationScreen(),
      },
    );
  }
}
