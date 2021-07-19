import 'dart:convert';
import 'package:discuss_it/models/keys.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Movie {
  final int id;
  final String name;
  final String overview;
  final String posterURL;

  Movie(this.id, this.name, this.overview, this.posterURL);
}

class MovieProvider with ChangeNotifier {
  Map<String, List<Movie>> _movies = {'popular': [], 'now_playing': []};

  // List<Movie> get getMovies {
  //   return [..._movies];
  // }

  Future<void> fetchMovieBy(String type, {int page = 1}) async {
    final url = Uri.parse(
        "https://api.themoviedb.org/3/movie/$type?api_key=${keys.apiKey}&language=en-US&page=$page");

    final response = await http.get(url);

    final decodedData = json.decode(response.body);
    final results = decodedData['results'] as List<dynamic>;

    List<Movie> movieData = [];
    results.forEach((movie) {
      final id = movie['id'];
      final title = movie['original_title'];
      final overview = movie['overview'];
      final imageURL = keys.baseURL + movie['poster_path'];
      movieData.add(Movie(id, title, overview, imageURL));
    });

    _movies[type] = movieData;

    notifyListeners();
  }

  List<Movie> getMoviesBy(String type) {
    if (_movies[type] == null) return [];

    return [..._movies[type]!];
  }
}
