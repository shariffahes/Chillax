import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/screens/list_all_screen.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';
import 'screens/tabs_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static Database? db;

  Future<void> setDB() async {
    var databasePath = await getDatabasesPath();
    String path = databasePath + '/chill_time.db';
    print(path);
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (dataB, version) async {
        await dataB.execute(
            'CREATE TABLE MovieWatch (id INT PRIMARY KEY,name TEXT, overview TEXT, rate TEXT, year INTEGER, language TEXT, duration INTEGER, genre TEXT, certification TEXT,releaseDate TEXT,homePage TEXT,trailer TEXT,watched INTEGER)');
        await dataB.execute(
            'CREATE TABLE ShowWatch (id INT PRIMARY KEY,name TEXT, overview TEXT, rate TEXT, year INTEGER, language TEXT, genre TEXT, certification TEXT,releaseDate TEXT,homePage TEXT,trailer TEXT,network TEXT,runTime INTEGER,status TEXT,airedEpisodes INTEGER,watched INTEGER,currentEps INT,currentSeason INT)');
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
        });
  }
}
