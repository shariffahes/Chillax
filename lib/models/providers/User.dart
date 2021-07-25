import 'package:discuss_it/models/providers/Movies.dart';
import 'package:flutter/material.dart';

class User with ChangeNotifier {
  Map<int, Movie> _watchList = {};
  Map<int, Movie> _watched = {};

  void addToWatchList(Movie movie) {
    _watchList[movie.id] = movie;
    notifyListeners();
  }

  Map<int, Movie> get watchList {
    return {..._watchList};
  }

  Map<int, Movie> get watched {
    return {..._watched};
  }

  void removeFromList(int id) {
    _watchList.remove(id);
    notifyListeners();
  }

  bool isAdded(int id) {
    return _watchList[id] != null || _watched[id] != null;
  }

  void watchComplete(int id) {
    _watched[id] = _watchList[id]!;
    removeFromList(id);
    notifyListeners();
  }

  bool isWatched(int id) {
    return watched[id] != null;
  }
}
