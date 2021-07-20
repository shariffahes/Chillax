import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/screens/list_all_screen.dart';
import 'package:discuss_it/widgets/Item_details.dart';
import 'package:provider/provider.dart';
import 'screens/tabs_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MovieProvider()),
      ],
      child: MaterialApp(
        routes: {
          ListAll.route: (ctx) => ListAll(),
          ItemDetails.route : (ctx) => ItemDetails(),
        },
        title: 'Discuss it',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: TabsScreen(),
      ),
    );
  }
}
