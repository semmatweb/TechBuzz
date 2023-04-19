import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/initialization_screen.dart';

// Build the app into apk with "flutter build apk --flavor iniNews" command in terminal (without quote)

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );

  MobileAds.instance.initialize();
  RequestConfiguration configuration =
      RequestConfiguration(testDeviceIds: ["E8E1B15D5B7D475188AC1CCC9BA5D5B1"]);
  MobileAds.instance.updateRequestConfiguration(configuration);

  // App-wide Config
  FlavorConfig(
    name:
        'iniNews', // IMPORTANT!!! only change this "name:" variable if you renamed the productFlavors at android/app/build.gradle
    location: BannerLocation.topStart,
    color: Colors.blue,
    variables: {
      'apiBaseUrl': 'https://dummycontent.inito.dev/wp-json/wp/v2',
      'appName': 'iniNews',
      'appDefaultFont': 'Inter',
      'appPrimarySwatch': Colors.indigo,
      'appPrimaryColor': const Color.fromARGB(255, 45, 70, 105),
      'appPrimaryAccentColor': const Color.fromARGB(255, 220, 230, 255),
      'appSecondaryColor': const Color.fromARGB(255, 255, 152, 0),
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
      initialRoute: '/',
      routes: {
        '/': (context) => const InitializationScreen(),
      },
    );
  }
}
