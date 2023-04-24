import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flavor/flutter_flavor.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          FlavorConfig.instance.variables['appName'].toString().toUpperCase(),
          style: TextStyle(
            color: FlavorConfig.instance.variables['appBlack'],
            fontWeight: FontWeight.w900,
            fontSize: 20,
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
              color: FlavorConfig.instance.variables['appPrimaryAccentColor'],
              boxShadow: false,
              prefixIcon: Icon(
                Icons.search,
                color: Theme.of(context).primaryColor,
              ),
              suffixIcon: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
            text: 'Category',
          ),
          GButton(
            icon: Icons.bookmark,
            iconActiveColor: Theme.of(context).primaryColor,
            text: 'Bookmark',
          ),
        ],
      ),
    );
  }
}
