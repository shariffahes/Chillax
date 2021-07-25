import 'dart:convert';

import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

enum DiscoverTypes {
  trending,
  genre,
  now_playing,
  popular,
  top_rated,
  upcoming
}

extension ParseToString on DiscoverTypes {
  String toShortString() {
    return this.toString().split('.').last;
  }

  String toNormalString() {
    return this.toShortString().toString().replaceAll('_', ' ');
  }
}

class keys {
  static Map<String, int> genres = {
    "Action": 28,
    "Adventure": 12,
    "Animation": 16,
    "Comedy": 35,
    "Crime": 80,
    "Documentary": 99,
    "Drama": 18,
    "Family": 10751,
    "Fantasy": 14,
    "History": 36,
    "Horror": 27,
    "Music": 10402,
    "Mystery": 9648,
    "Romance": 10749,
    "Science Fiction": 878,
    "TV Movie": 10770,
    "Thriller": 53,
    "War": 10752,
    "Western": 37,
  };
  static int mainList = 2;
  static const String apiKey = "dd5468d7aa41e016a24fa6bce058252d";
  static String baseImageURL = "https://image.tmdb.org/t/p/w500";
  static String baseURL = "https://api.themoviedb.org/3/";
  void fetchConfig() async {
    final url =
        Uri.parse("https://api.themoviedb.org/3/configuration?api_key=$apiKey");
    final response = await http.get(url);
    final decodedData = json.decode(response.body);
    baseImageURL = decodedData['images']['base_url'];
  }

  static String reformData(String date) {
    return date == "-" ? date : DateFormat('yyyy').format(DateTime.parse(date));
  }
}
