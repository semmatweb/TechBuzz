import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../screens/bookmark_tab.dart';
import '../screens/category_tab.dart';
import '../screens/home_tab.dart';
import '../screens/search_result_screen.dart';
import '../screens/settings_screen.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    SettingsScreen(),
  ];

  TextEditingController searchTextEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          FlavorConfig.instance.variables['appName'].toString().toUpperCase(),
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
              color: AppTheme.isDark
                  ? FlavorConfig.instance.variables['appDarkPrimaryAccentColor']
                  : FlavorConfig.instance.variables['appPrimaryAccentColor'],
              boxShadow: false,
              helpText: 'Search...',
              style: Theme.of(context).textTheme.bodyMedium,
              textFieldColor: Theme.of(context).canvasColor,
              textFieldIconColor: Theme.of(context).textTheme.bodyMedium!.color,
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
              suffixIcon: Icon(
                Icons.close,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: _screens.elementAt(_selectedIndex),
      bottomNavigationBar: GNav(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        selectedIndex: _selectedIndex,
        onTabChange: _onItemTapped,
        style: GnavStyle.google,
        color: Theme.of(context).iconTheme.color,
        activeColor: Theme.of(context).primaryColor,
        textStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        ),
        gap: 8,
        iconSize: 28,
        tabBackgroundColor: AppTheme.isDark
            ? FlavorConfig.instance.variables['appDarkPrimaryAccentColor']
            : FlavorConfig.instance.variables['appPrimaryAccentColor'],
        tabShadow: const [BoxShadow(color: Colors.transparent)],
        tabMargin: const EdgeInsets.symmetric(vertical: 20),
        padding: const EdgeInsets.all(10),
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        curve: Curves.easeInCirc,
        tabs: const [
          GButton(
            icon: Icons.home_filled,
            text: 'Home',
          ),
          GButton(
            icon: Icons.dashboard,
            text: 'Category',
          ),
          GButton(
            icon: Icons.bookmark,
            text: 'Bookmark',
          ),
          GButton(
            icon: Icons.settings,
            text: 'Settings',
          ),
        ],
      ),
    );
  }
}
