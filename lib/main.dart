import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/screens/list_all_screen.dart';
import 'package:discuss_it/widgets/Item_details.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
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
        ChangeNotifierProvider(create: (_) => User()),
      ],
      child: MaterialApp(
        routes: {
          ListAll.route: (ctx) => ListAll(),
          PreviewItem.route: (ctx) => PreviewItem(),
        },
        title: 'Discuss it',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: TabsScreen(),
      ),
    );
  }
}
