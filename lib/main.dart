import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:ini_news_flutter/screens/post_detail_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/initialization_screen.dart';
import 'globals.dart' as globals;

Future<void> main() async {
  globals.appNavigator = GlobalKey<NavigatorState>();

  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  //Remove this method to stop OneSignal Debugging
  OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
  OneSignal.shared.setAppId("1f41b0aa-54fe-4ffc-80ae-73aecc2334ea");

  // The promptForPushNotificationsWithUserResponse function will show the iOS or Android push notification prompt. We recommend removing the following code and instead using an In-App Message to prompt for notification permission
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
          postTitle: notifData.title!,
          postCategory: 'Featured',
          postDateTime: DateTime.now().toIso8601String(),
          postImageUrl: 'https://placehold.co/600x400/EEE/31343C',
        ),
      ),
    );
  });

  MobileAds.instance.initialize();
  RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: ["500433D97FD57BD662DE72EFBD312F5E"]);
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: FlavorConfig.instance.variables['appName'],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: FlavorConfig.instance.variables['appDefaultFont'],
        primaryColor: FlavorConfig.instance.variables['appPrimaryColor'],
        primarySwatch: FlavorConfig.instance.variables['appPrimarySwatch'],
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: FlavorConfig.instance.variables['appSecondaryColor'],
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          surfaceTintColor: Colors.black,
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
