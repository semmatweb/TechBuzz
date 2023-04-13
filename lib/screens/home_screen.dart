import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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
  @override
  void initState() {
    super.initState();
    initialization();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          'ININEWS',
          style: TextStyle(
            color: Color.fromARGB(255, 54, 54, 54),
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
              searchIconColor: const Color.fromARGB(255, 54, 54, 54),
              textFieldIconColor: const Color.fromARGB(255, 54, 54, 54),
              style: const TextStyle(color: Color.fromARGB(255, 54, 54, 54)),
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
        color: Colors.grey,
        textStyle: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w600,
        ),
        gap: 8,
        iconSize: 28,
        tabBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.15),
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
    );
  }
}

/* BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedIconTheme: const IconThemeData(color: Colors.red),
            unselectedIconTheme: const IconThemeData(color: Colors.grey),
            selectedItemColor: Colors.red,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category_rounded),
                label: 'Category',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Bookmark',
              )
            ]) */
