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

  Future<List<Map<int, Movie>>> setDB() async {
    var databasePath = await getDatabasesPath();
    String path = databasePath + '/chill_time.db';
    db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
            'CREATE TABLE WatchList (id INT PRIMARY KEY,name TEXT, overview TEXT, rate TEXT, releaseDate INTEGER, language TEXT, duration INTEGER, genre TEXT, certification TEXT,watched INTEGER)');
      },
    );

    var info = await db!.query('WatchList', where: 'watched = ${0}');
    final Map<int, Movie> watchList = {};
    info.forEach((element) {
      watchList[element['id'] as int] = Movie.fromMap(element);
    });
    final Map<int, Movie> watched = {};
    info = await db!.query('WatchList', where: 'watched = ${1}');
    info.forEach((element) {
      watched[element['id'] as int] = Movie.fromMap(element);
    });
    final list = [watchList, watched];
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<int, Movie>>>(
        future: setDB(),
        builder: (ctx, snapshot) {
          if (snapshot.hasError)
            return AlertDialog(
              title: Text('An error has occured'),
              content: Text(
                'An error has occured retrieving local data. Please try again',
              ),
              actions: [
                TextButton(
                  onPressed: () {},
                  child: Text('Try again'),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('close app'),
                ),
              ],
            );
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MovieProvider()),
              ChangeNotifierProvider(create: (_) => User(wl: snapshot.data![0],wtched: snapshot.data![1])),
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
