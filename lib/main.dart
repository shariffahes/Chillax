import 'dart:convert';

import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/screens/list_all_screen.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'screens/tabs_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

class MyApp extends StatefulWidget {
  static Database? db;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> setDB() async {
    var databasePath = await getDatabasesPath();
    SharedPreferences.getInstance().then((prefs) async {
      String? value = prefs.getString('key');
      print(value);
      if (value == null) {
        final response = await post(
            Uri.parse(
                'https://chillax-4c80c-default-rtdb.firebaseio.com/schedule.json'),
            body: json.encode({'initial': -1}));
        final id = json.decode(response.body);
        value = id['name'];
        prefs.setString('key', value!);
      } else
        Global.key = value;
    });
    String path = databasePath + '/chill_time.db';
    print(path);
    MyApp.db = await openDatabase(
      path,
      version: 1,
      onCreate: (dataB, version) async {
        await dataB.execute(
            'CREATE TABLE MovieWatch (id INT PRIMARY KEY,name TEXT, overview TEXT, rate TEXT, year INTEGER, language TEXT, duration INTEGER, genre TEXT, certification TEXT,releaseDate TEXT,homePage TEXT,trailer TEXT,tmdb INTEGER,watched INTEGER)');
        await dataB.execute(
            'CREATE TABLE ShowWatch (id INT PRIMARY KEY,name TEXT, overview TEXT, rate TEXT, year INTEGER, language TEXT, genre TEXT, certification TEXT,releaseDate TEXT,homePage TEXT,trailer TEXT,tmdb INTEGER,network TEXT,runTime INTEGER,status TEXT,airedEpisodes INTEGER,watched INTEGER,currentEps INTEGER,currentSeason INTEGER)');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: setDB(),
        builder: (ctx, _) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => DataProvider()),
              ChangeNotifierProvider(create: (_) => User()),
              ChangeNotifierProvider(create: (_) => PhotoProvider()),
            ],
            child: ResponsiveSizer(
              builder: (ctx, orientation, _) => MaterialApp(
                routes: {
                  ListAll.route: (ctx) => ListAll(),
                  PreviewItem.route: (ctx) => PreviewItem(),
                },
                title: 'Discuss it',
                theme: ThemeData(
                  accentColor: Global.accent,
                  primaryColor: Global.primary,
                ),
                home: TabsScreen(),
              ),
            ),
          );
        });
  }
}
