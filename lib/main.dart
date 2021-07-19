import 'package:discuss_it/screens/list_all_screen.dart';
import 'screens/tabs_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        ListAll.route: (ctx) => ListAll(),
      },
      title: 'Discuss it',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: TabsScreen(),
    );
  }
}
