import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ini_news_flutter/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/search_result_screen.dart';
import '../screens/home_tab.dart';
import '../screens/category_tab.dart';
import '../screens/bookmark_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getIntroductionState();
    initialization();
  }

  bool isIntroduced = false;

  Future<void> getIntroductionState() async {
    final prefs = await SharedPreferences.getInstance();

/*     setState(() {
      isIntroduced = prefs.getBool('isIntroduced') ?? false;
    }); */

    debugPrint('prefs: ${prefs.getBool('isIntroduced')}');
    debugPrint('isIntroduced: $isIntroduced');
  }

  void initialization() async {
    debugPrint('Initiating...');
    await Future.delayed(const Duration(seconds: 2));
    debugPrint('Removing Splash...');
    FlutterNativeSplash.remove();
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _screens = [
    HomeTab(),
    CategoryTab(),
    BookmarkTab(),
  ];

  TextEditingController searchTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return isIntroduced
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              surfaceTintColor: Colors.white,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Text(
                FlavorConfig.instance.variables['appName']
                    .toString()
                    .toUpperCase(),
                style: TextStyle(
                  color: FlavorConfig.instance.variables['appBlack'],
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  height: 1,
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimSearchBar(
                    width: MediaQuery.of(context).size.width - 40,
                    onSubmitted: (value) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SearchResultScreen(
                            searchKeyword: value,
                          ),
                        ),
                      );
                    },
                    onSuffixTap: () {
                      searchTextEditingController.clear();
                    },
                    textController: searchTextEditingController,
                    boxShadow: false,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: const Icon(Icons.close),
                    searchIconColor:
                        FlavorConfig.instance.variables['appBlack'],
                    textFieldIconColor:
                        FlavorConfig.instance.variables['appBlack'],
                    style: TextStyle(
                      color: FlavorConfig.instance.variables['appBlack'],
                    ),
                  ),
                )
              ],
            ),
            body: _screens.elementAt(_selectedIndex),
            bottomNavigationBar: GNav(
              backgroundColor: Colors.white,
              selectedIndex: _selectedIndex,
              onTabChange: _onItemTapped,
              style: GnavStyle.google,
              color: FlavorConfig.instance.variables['appGrey'],
              textStyle: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
              gap: 8,
              iconSize: 28,
              tabBackgroundColor:
                  FlavorConfig.instance.variables['appPrimaryAccentColor'],
              tabShadow: const [BoxShadow(color: Colors.transparent)],
              tabMargin: const EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              curve: Curves.easeInCirc,
              tabs: [
                GButton(
                  icon: Icons.home_filled,
                  iconActiveColor: Theme.of(context).primaryColor,
                  text: 'Home',
                ),
                GButton(
                  icon: Icons.dashboard,
                  iconActiveColor: Theme.of(context).primaryColor,
                  text: 'Kategori',
                ),
                GButton(
                  icon: Icons.bookmark,
                  iconActiveColor: Theme.of(context).primaryColor,
                  text: 'Bookmark',
                ),
              ],
            ),
          )
        : const OnboardingScreen();
  }
}
