import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/search_screen.dart';
import '../screens/watch_list_screen.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _index = 2;
  late List<Map<String, Object>> tabBarWidgets;

  @override
  void initState() {
    super.initState();

    tabBarWidgets = [
      {
        'page': WatchListScreen(),
        'title': 'Watch List',
      },
      {'page': SearchScreen(), 'title': 'Discover'},
      {'page': HomeScreen(), 'title': 'Main Home'},
      {
        'page': UpcomingScreen(),
        'title': 'Upcoming',
      },
      {'page': ProfileScreen(), 'title': 'My Profile'},
    ];
  }

  void selectTab(int indexTab) {
    setState(() {
      _index = indexTab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 10,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(66),
          )),
          toolbarHeight: 100,
          bottom: TabBar(
            labelColor: Colors.white,
            tabs: [
              Tab(
                icon: Icon(Icons.local_movies),
                text: 'Movies',
              ),
              Tab(
                icon: Icon(Icons.tv_rounded),
                text: 'Shows',
              )
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.black,
          currentIndex: _index,
          onTap: selectTab,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.tv),
              label: 'WatchList',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              label: 'Profile',
            ),
          ],
        ),
        body: tabBarWidgets[_index]['page'] as Widget,
      ),
    );
  }
}
