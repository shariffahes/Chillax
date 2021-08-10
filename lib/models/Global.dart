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
}