import 'dart:convert';
import 'package:discuss_it/models/Enums.dart';
import 'package:http/http.dart' as http;

class keys {
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
  static int mainList = 3;
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
    return keys.dataType == DataType.movie;
  }
}
