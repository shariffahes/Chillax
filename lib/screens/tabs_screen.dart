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
        'tabBar': TabBar(
          labelColor: Colors.white,
          tabs: [
            Tab(
              text: 'Movies',
            ),
            Tab(
              text: 'Shows',
            )
          ],
        )
      },
      {'page': SearchScreen(), 'title': 'Discover'},
      {'page': HomeScreen(), 'title': 'Main Home'},
      {
        'page': UpcomingScreen(),
        'title': 'Upcoming',
        'tabBar': TabBar(
          labelColor: Colors.white,
          tabs: [
            Tab(
              text: 'Movies',
            ),
            Tab(
              text: 'Shows',
            )
          ],
        )
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
          bottom: tabBarWidgets[_index].containsKey('tabBar')
              ? tabBarWidgets[_index]['tabBar'] as TabBar
              : null,
          title: Text(tabBarWidgets[_index]['title'] as String),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.orange,
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
