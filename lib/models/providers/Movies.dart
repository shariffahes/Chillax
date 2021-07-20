import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:discuss_it/models/keys.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Movie {
  final int id;
  final String name;
  final String overview;
  final String posterURL;
  final String backDropURL;

  Movie(this.id, this.name, this.overview, this.posterURL, this.backDropURL);
}

class MovieProvider with ChangeNotifier {
  Map<DiscoverTypes, List<Movie>> _movies = {};
  List<int> currentPage = DiscoverTypes.values.map((e) => 1).toList();

  Future<void> fetchMovieBy(DiscoverTypes type, {int page = 1}) async {
    
    if (_movies[type] != null && _movies[type]!.isNotEmpty) return null;
    final stringURL = _prepareURL(type);
    final decodedData = await _fetchData(stringURL);
    final results = decodedData['results'] as List<dynamic>;
    final movieData = _extractMoviesData(results);
    _movies[type] = movieData;
    notifyListeners();
  }

  String _prepareURL(DiscoverTypes type, {page = 1}) {
    String stringURL = keys.baseURL;
    stringURL = stringURL +
        (type == DiscoverTypes.trending
            ? 'trending/movie/day'
            : 'movie/${type.toShortString()}') +
        '?api_key=${keys.apiKey}&language=en-US&page=$page';
    return stringURL;
  }

  Future<dynamic> _fetchData(String url) async {
    final parsedURL = Uri.parse(url);
    try {
      final response = await http.get(parsedURL);
      print(response.request);
      return json.decode(response.body);
    } catch (error) {
      throw HttpException(error.toString());
    }
  }

  List<Movie> _extractMoviesData(List<dynamic> results) {
    List<Movie> movieData = [];
    results.forEach((movie) {
      final id = movie['id'];
      final title = movie['original_title'];
      final overview = movie['overview'];
      final imageURL = movie['poster_path'] == null
          ? "https://i.postimg.cc/cLWJs6Rb/logo.png"
          : keys.baseImageURL + movie['poster_path'];
      final backDropURL = movie['backdrop_path'] == null
          ? "https://i.postimg.cc/cLWJs6Rb/logo.png"
          : keys.baseImageURL + movie['backdrop_path'];

      movieData.add(Movie(id, title, overview, imageURL, backDropURL));
    });
    return movieData;
  }

  Future<void> loadMore(DiscoverTypes type) async {
    currentPage[type.index]++;
    final url = _prepareURL(type, page: currentPage[type.index]);
    try {
      final decodedData = await _fetchData(url);

      final results = decodedData['results'] as List<dynamic>;

      List<Movie> _movieData = _extractMoviesData(results);
      _movies[type]!.addAll(_movieData);
    } catch (error) {
      print(error);
      throw HttpException(error.toString());
    }
    notifyListeners();
  }

  List<Movie> getMoviesBy(DiscoverTypes type) {
    if (_movies[type] == null) return [];

    return [..._movies[type]!];
  }
}
