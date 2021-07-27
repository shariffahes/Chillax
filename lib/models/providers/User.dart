import 'package:discuss_it/main.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class User with ChangeNotifier {
  late Map<int, Movie> _watchList;
  late Map<int, Movie> _watched;

  

  User({required Map<int, Movie> wl, required Map<int, Movie> wtched}) {
    _watchList = wl;
    _watched = wtched;
  }

  void addToWatchList(Movie movie) async {
    _watchList[movie.id] = movie;
    notifyListeners();

    var databasePath = await getDatabasesPath();
    String path = databasePath + '/chill_time.db';

    await MyApp.db!.transaction((txn) async {
      int id1 = await txn.insert('WatchList', movie.toMap());
    });
  }

  Map<int, Movie> get watchList {
    return {..._watchList};
  }

  Map<int, Movie> get watched {
    return {..._watched};
  }

  void removeFromList(int id) {
    _watchList.remove(id);
    _delete(id);
    notifyListeners();
  }

  bool isAdded(int id) {
    return _watchList[id] != null || _watched[id] != null;
  }

  void watchComplete(int id) {
    if (_watched[id] != null) {
      final item = _watched[id];
      _watched.remove(id);
      _watchList[id] = item!;
      _update(id, 0);
    } else {
      _watched[id] = _watchList[id]!;
      _update(id, 1);
      removeFromList(id);
    }
    notifyListeners();
    
  }

  void _update(int id, int value) async {
    await MyApp.db!.update('WatchList', {'watched': value}, where: 'id = $id');
  }

  void _delete(int id) async {
    await MyApp.db!.delete('WatchList', where: 'id = $id AND watched = ${0}');
  }

  bool isWatched(int id) {
    return watched[id] != null;
  }

  void deleteItem(int id) {
    if (_watched[id] != null) {
      _watchList[id] = _watched[id]!;
      _watched.remove(id);
      _update(id, 0);
    } else {
      removeFromList(id);
    }
    notifyListeners();
  }
}
