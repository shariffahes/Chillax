import 'package:discuss_it/main.dart';
import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';

class Track {
  int currentEp;
  int currentSeason;
  int nextEp;
  int nextSeason;
  Track(
      {this.currentEp = 0,
      this.currentSeason = 0,
      this.nextEp = 0,
      this.nextSeason = 0});
}

class User with ChangeNotifier {
  late Map<int, Movie> _watchList;
  late Map<int, Movie> _watched;
  final Map<int, Show> _tvWatchList = {};
  final Map<int, Show> _tvWatched = {};
  final List<Show> _watching = [];
  Map<int, Track> track = {};

  //this used in get schedule to indicate if there is any changes which require rebuild;
  bool isChange = false;

  User({required Map<int, Movie> wl, required Map<int, Movie> wtched}) {
    _watchList = wl;
    _watched = wtched;
  }

  void startWatching(int id) {
    isChange = true;
    _watching.add(_tvWatchList[id]!);
    removeFromList(id);
  }

  List<Show> getCurrentlyWatching() {
    return [..._watching];
  }

  void addToWatchList(Object item) async {
    isChange = true;
    if (item is Movie) {
      _watchList[item.id] = item;
      notifyListeners();

      // var databasePath = await getDatabasesPath();
      // String path = databasePath + '/chill_time.db';

      // await MyApp.db!.transaction((txn) async {
      //   int id1 = await txn.insert('WatchList', movie.toMap());
      // });

    } else if (item is Show) {
      _tvWatchList[item.id] = item;
      notifyListeners();
    } else if (item is Episode) {
      Show show = DataProvider.dataDB[item.id]! as Show;
      addToWatchList(show);
      notifyListeners();
    }
  }

  Map<int, Movie> get movieWatchList {
    return {..._watchList};
  }

  Map<int, Movie> get watchedMovies {
    return {..._watched};
  }

  Map<int, Show> get showWatchList {
    return {..._tvWatchList};
  }

  Map<int, Show> get watchedShows {
    return {..._tvWatched};
  }

  void removeFromList(int id) {
    isChange = true;
    if (keys.isMovie()) {
      _watchList.remove(id);
      // _delete(id);
    } else {
      if (_tvWatchList[id] == null) {
        print('delete');
      } else {
        _tvWatchList.remove(id);
      }
      //delete
    }
    notifyListeners();
  }

  bool isMovieAdded(int id) {
    return _watchList[id] != null || _watched[id] != null;
  }

  bool isShowAdded(int id) {
    return _tvWatchList[id] != null || _tvWatched[id] != null;
  }

  void watchComplete(int id) {
    if (keys.isMovie()) {
      if (_watched[id] != null) {
        final item = _watched[id];
        _watched.remove(id);
        _watchList[id] = item!;
        // _update(id, 0);
      } else {
        _watched[id] = _watchList[id]!;

        //_update(id, 1);
        removeFromList(id);
      }
    } else {
      if (_tvWatched[id] != null) {
        final item = _tvWatched[id];
        _tvWatched.remove(id);
        _tvWatchList[id] = item!;
        //_update(id, 0);
      } else if (_tvWatchList[id] != null) {
        _tvWatched[id] = _tvWatchList[id]!;
        removeFromList(id);

        //_update(id, 1);

      } else {
        final nextEp = track[id]!.nextEp;

        final nextSeason = track[id]!.nextSeason;

        track[id]!.currentEp = nextEp;
        track[id]!.currentSeason = nextSeason;
      }
    }
    notifyListeners();
  }

  // void _update(int id, int value) async {
  //   await MyApp.db!.update('WatchList', {'watched': value}, where: 'id = $id');
  // }

  // void _delete(int id) async {
  //   await MyApp.db!.delete('WatchList', where: 'id = $id AND watched = ${0}');
  // }

  bool isMovieWatched(int id) {
    return _watched[id] != null;
  }

  bool isShowWatched(int id) {
    return _tvWatched[id] != null;
  }

  void deleteItem(int id) {
    isChange = true;
    if (_watched[id] != null) {
      _watchList[id] = _watched[id]!;
      _watched.remove(id);
      // _update(id, 0);
    } else {
      removeFromList(id);
    }
    notifyListeners();
  }

  void updateNext(int id, int season, int episode) {
    if (track[id] == null) {
      track[id] =
          Track(currentEp: 1, currentSeason: 1, nextEp: episode, nextSeason: 1);
    } else {
      track[id]!.nextSeason = season;
      track[id]!.nextEp = episode;
    }
  }

  Map<int, Data> watchingtoMap() {
    Map<int, Data> map = {};

    _watching.forEach((element) {
      map[element.id] = element;
    });
    return map;
  }
}
