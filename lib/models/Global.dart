import 'dart:convert';
import 'package:discuss_it/main.dart';
import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// a static class used to get useful info such as api key and urls
//helps in preventing repition
class Global {
  static DataType dataType = DataType.movie;
  static List<String> genres = [
    "Action",
    "Adventure",
    "Animation",
    "Anime",
    "Comedy",
    "Crime",
    "Documentary",
    "Drama",
    "Family",
    "Fantasy",
    "History",
    "Holiday",
    "Horror",
    "Music",
    "Musical",
    "Mystery",
    "None",
    "Romance",
    "Science Fiction",
    "Short",
    "Sporting Event",
    "Superhero",
    "Suspense",
    "Thriller",
    "War",
    "Western"
  ];
  static int mainList = 4;
  static const accent = Colors.amber;
  static const primary = Color.fromRGBO(0, 0, 128, 1);
  static Data get defaultData {
    return isMovie()
        ? Movie(0, '-', '-', '-', 0, '-', [], '-', '-', '-', '-', 0)
        : Show(
            0, '-', '-', '-', 0, '-', [], '-', '-', '-', '-', '-', 0, '-', 0);
  }

  static const String apiKey =
      "4b919f5ec98bd3a8ae5e4603d87a919a22dedbbbb009839540bd43eae25b68f2";
  static String baseImageURL = "https://image.tmdb.org/t/p/";
  static String baseURL = "https://api.trakt.tv/";
  static const String defaultImage = "https://i.postimg.cc/cLWJs6Rb/logo.png";
  void fetchConfig() async {
    final url =
        Uri.parse("https://api.themoviedb.org/3/configuration?api_key=$apiKey");
    final response = await http.get(url);
    final decodedData = json.decode(response.body);
    baseImageURL = decodedData['images']['base_url'];
  }

  static bool isMovie() {
    return Global.dataType == DataType.movie;
  }

  static bool isMovieSet = false;
  static bool isShowSet = false;
  static Future<void> getMovieFromLocalDB(
      {BuildContext? ctx,
      Function? setMovieWL,
      Function? setMovieWatched}) async {
    var info = await MyApp.db!.query('MovieWatch', where: 'watched = ${0}');
    Map<int, Movie> wl = {};
    info.forEach((movie) {
      int id = movie['id'] as int;
      wl[id] = Movie.fromMap(movie);
      DataProvider.dataDB[id] = wl[id]!;
    });
    Map<int, Movie> watched = {};
    info = await MyApp.db!.query('MovieWatch', where: 'watched=${1}');
    info.forEach((movie) {
      int id = movie['id'] as int;
      watched[id] = Movie.fromMap(movie);
      DataProvider.dataDB[id] = watched[id]!;
    });
    isMovieSet = true;
    if (ctx == null) {
      setMovieWL!(wl);
      setMovieWatched!(watched);
    } else {
      final user = Provider.of<User>(ctx, listen: false);
      user.setMovieWatchList(wl);
      user.setMovieWatchedList(watched);
    }
  }

  static Future<void> getShowFromLocalDB(
      {BuildContext? ctx,
      Function? setShowWL,
      Function? setShowWatched,
      Function? setTrack,
      Function? setWatching}) async {
    Map<int, Track> track = {};
    List<Show> currWatching = [];

    var info = await MyApp.db!.query('ShowWatch', where: 'watched = ${0}');
    Map<int, Show> wl = {};
    info.forEach((show) {
      int id = show['id'] as int;
      wl[id] = Show.fromMap(show);
      DataProvider.dataDB[id] = wl[id]!;
    });
    Map<int, Show> watched = {};
    info = await MyApp.db!.query('ShowWatch', where: 'watched=${1}');
    info.forEach((show) {
      int id = show['id'] as int;
      watched[id] = Show.fromMap(show);
      DataProvider.dataDB[id] = watched[id]!;
      DataProvider.tvSchedule[id] = {};
      final int episode = show['currentEps'] as int;
      final int season = show['currentSeason'] as int;
      track[id] = Track(currentEp: episode, currentSeason: season);
    });

    info = await MyApp.db!.query('ShowWatch', where: 'watched=${-1}');
    info.forEach((element) {
      final int id = element['id'] as int;
      final int episode = element['currentEps'] as int;
      final int season = element['currentSeason'] as int;
      track[id] = Track(currentEp: episode, currentSeason: season);
      Show s = Show.fromMap(element);
      currWatching.add(s);

      DataProvider.dataDB[id] = s;
      DataProvider.tvSchedule[id] = {};
    });

    if (ctx == null) {
      setShowWL!(wl);
      setShowWatched!(watched);
      setTrack!(track);
      setWatching!(currWatching);
    } else {
      final user = Provider.of<User>(ctx, listen: false);
      user.setTrack(track);
      user.setWatching(currWatching);
      user.setTvWatchList(wl);
      user.setTvWatchedList(watched);
    }

    isShowSet = true;
  }
}
