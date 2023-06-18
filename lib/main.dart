import 'package:facebook_audience_network/facebook_audience_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'globals.dart';
import 'screens/initialization_screen.dart';
import 'screens/post_detail_screen.dart';

// For iOS developer
//
// These packages need to be configured in order for your iOS app build to work.
// Please read the documention on the link below how to configure it.
//
// - flutter_native_splash (https://pub.dev/packages/flutter_native_splash)
// - share_plus (https://pub.dev/packages/share_plus)
// - gallery_saver (https://pub.dev/packages/gallery_saver)
// - google_mobile_ads (https://developers.google.com/admob/flutter/quick-start)
// - facebook_audience_network (https://pub.dev/packages/facebook_audience_network)
// - flutter_launcher_icons (https://pub.dev/packages/flutter_launcher_icons)
// - flutter_web_browser (https://pub.dev/packages/flutter_web_browser)
// - onesignal_flutter (https://documentation.onesignal.com/docs/flutter-sdk-setup)
// - in_app_review (https://pub.dev/packages/in_app_review)

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

  // Google AdMob
  MobileAds.instance.initialize();
  RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: ["03ECFD73D1A81042944D176D4DE6C0EA"]);
  MobileAds.instance.updateRequestConfiguration(configuration);

  // Facebook Ads
  FacebookAudienceNetwork.init(
    testingId: "0c0b2cb3-6217-4263-92e0-0e3ccf57902f",
  );

  // App-wide Config
  FlavorConfig(
    variables: {
      'apiBaseUrl': 'https://dummycontent.inito.dev/wp-json/wp/v2',
      'appName': 'iniNews',
      //By default, this app use 'adProvider': 'Google AdMob' as its ad provider, you can change between Facebook Ads or Google AdMob as your preferred ad provider
      //Change to 'adProvider: 'Facebook Ads' if you want to use Facebook Ads instead
      'adProvider': 'Google AdMob',
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
      'termsAndConditionsUrl': 'https://www.inito.dev/terms.html',
      'privacyPolicyUrl': 'https://www.inito.dev/privacy.html',
      'contactUsUrl': 'https://initodev.freshdesk.com/support/tickets/new',
      //This appleAppStoreID is used for In-App Review.
      //Only change this ID with your Apple ID in App Store Connect under "General > App Information > Apple ID" if you publish this app into App Store.
      //Otherwise, leave it as it is.
      'appleAppStoreID': 'YOUR_APPLE_ID',
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
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'AE'),
        Locale('fa', 'IR'),
        Locale('he', 'IL'),
        Locale('ps', 'AF'),
        Locale('ur', 'PK'),
      ],
    );
  }
}
