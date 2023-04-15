import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final introKey = GlobalKey<IntroductionScreenState>();

  void _onIntroEnd(context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isIntroduced', true);
    debugPrint('prefs: ${prefs.getBool('isIntroduced')}');
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: introKey,
      curve: Curves.fastLinearToSlowEaseIn,
      globalBackgroundColor: Colors.white,
      showSkipButton: true,
      onSkip: () => _onIntroEnd(context),
      skip: Text(
        'Skip',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
      skipOrBackFlex: 0,
      showDoneButton: true,
      onDone: () => _onIntroEnd(context),
      done: Text(
        'Done',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
      showNextButton: true,
      next: Icon(
        Icons.arrow_forward,
        color: Theme.of(context).primaryColor,
      ),
      nextFlex: 0,
      controlsPadding: const EdgeInsets.all(20),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10),
        color: FlavorConfig.instance.variables['appGrey'],
        activeSize: const Size(24, 10),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      pages: [
        PageViewModel(
          useScrollView: true,
          title: 'Lorem Ipsum',
          body:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id euismod lectus, non tempor felis. Nam rutrum rhoncus est ac venenatis.',
          image: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage(
                  'assets/images/intro/preview_failed.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            imagePadding: EdgeInsets.all(20),
          ),
        ),
        PageViewModel(
            image: Image.network(
              'https://images.unsplash.com/photo-1681159003722-201aaa0bf9c6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            title: 'Lorem Ipsum',
            body:
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id euismod lectus, non tempor felis. Nam rutrum rhoncus est ac venenatis.',
            decoration: PageDecoration(
              titleTextStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              bodyTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              bodyPadding: const EdgeInsets.all(20),
              contentMargin: const EdgeInsets.all(20),
              fullScreen: true,
              boxDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
            )),
        PageViewModel(
          reverse: true,
          title: 'Lorem Ipsum',
          body:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc id euismod lectus, non tempor felis. Nam rutrum rhoncus est ac venenatis.',
          image: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage(
                    'https://images.unsplash.com/photo-1681159003722-201aaa0bf9c6?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          decoration: const PageDecoration(
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            bodyTextStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            imagePadding: EdgeInsets.all(20),
          ),
        ),
      ],
    );
  }
}
