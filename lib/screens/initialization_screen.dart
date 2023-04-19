import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ini_news_flutter/screens/states/loading_state.dart';
import 'package:ini_news_flutter/screens/states/failed_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/initialization_controller.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/states/error_state.dart';

class InitializationScreen extends StatefulWidget {
  const InitializationScreen({super.key});

  @override
  State<InitializationScreen> createState() => _InitializationScreenState();
}

class _InitializationScreenState extends State<InitializationScreen> {
  Future<Response<void>?>? _getState;
  final _controller = InitializationController();

  @override
  void initState() {
    super.initState();
    _getState = _controller.getState();
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
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isIntroduced = prefs.getBool('isIntroduced') ?? false;
    });

    debugPrint('prefs: ${prefs.getBool('isIntroduced')}');
    debugPrint('isIntroduced: $isIntroduced');
  }

  TextEditingController searchTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Response<void>?>(
      future: _getState,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(),
            body: const LoadingState(),
          );
        }

        if (!snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  FailedState(
                    stateIcon: Icons.signal_wifi_connected_no_internet_4,
                    stateText: 'No Internet Connection',
                    onPressed: () {
                      setState(() {
                        _getState = _controller.getState();
                      });
                    },
                  ),
                  const Spacer(),
                  Text(
                    FlavorConfig.instance.variables['appName']
                        .toString()
                        .toUpperCase(),
                    style: TextStyle(
                      color: FlavorConfig.instance.variables['appGrey'],
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const ErrorState();
        }

        return isIntroduced ? const HomeScreen() : const OnboardingScreen();
      },
    );
  }
}
