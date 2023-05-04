import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ini_news_flutter/globals.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  @override
  void initState() {
    super.initState();
    _initialization();
    _initGoogleMobileAds();
    _getIntroductionState();
  }

  void _initialization() async {
    debugPrint('Initiating...');
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('Removing Splash...');
    FlutterNativeSplash.remove();
  }

  Future<InitializationStatus> _initGoogleMobileAds() {
    return MobileAds.instance.initialize();
  }

  bool isIntroduced = false;

  Future<void> _getIntroductionState() async {
    setState(() {
      isIntroduced = introBox!.get('isIntroduced') ?? false;
    });

    debugPrint('introBox: ${introBox!.get('isIntroduced')}');
    debugPrint('isIntroduced: $isIntroduced');
  }

  TextEditingController searchTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return isIntroduced ? const HomeScreen() : const OnboardingScreen();
  }
}
