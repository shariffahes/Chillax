import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/schedule_screen.dart';
import '../screens/watch_list_screen.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  @override
  TabsScreenState createState() => TabsScreenState();
}

class TabsScreenState extends State<TabsScreen> {
  int _index = 1;
  late List<Map<String, Object>> tabBarWidgets;

  @override
  void initState() {
    super.initState();

    tabBarWidgets = [
      {
        'page': WatchListScreen(),
      },
      // {
      //   'page': SearchScreen(),
      // },
      {
        'page': HomeScreen(),
      },
      {
        'page': UpcomingScreen(),
      },
      {
        'page': ProfileScreen(),
      },
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
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          elevation: _index == 2 ? 0 : 10,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(_index == 2 ? 0 : 66),
          )),
          toolbarHeight: 100,
          bottom: _index == 3
              ? null
              : TabBar(
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
          selectedItemColor: Color.fromRGBO(0, 0, 128, 1),
          unselectedItemColor: Colors.black,
          currentIndex: _index,
          onTap: selectTab,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.tv),
              label: 'WatchList',
            ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.search),
            //   label: 'Search',
            // ),
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
