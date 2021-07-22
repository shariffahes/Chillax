import 'package:discuss_it/models/providers/Movies.dart';
import 'package:flutter/material.dart';

class User with ChangeNotifier {
  List<Movie> _watchList = [];

  void addToWatchList(Movie movie) {
    _watchList.add(movie);
    notifyListeners();
  }

  List<Movie> get watchList {
    return [..._watchList];
  }
}
