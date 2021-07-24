import 'dart:convert';
import 'dart:io';
import '/models/keys.dart';
import '/models/providers/People.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Movie {
  final int id;
  final String name;
  final String overview;
  final String posterURL;
  final String backDropURL;
  final double rate;
  final String releaseDate;
  final String language;

  Movie(
    this.id,
    this.name,
    this.overview,
    this.posterURL,
    this.backDropURL,
    this.rate,
    this.releaseDate,
    this.language,
  );
}

class MovieProvider with ChangeNotifier {
  Map<DiscoverTypes, List<Movie>> _movies = {};
  List<int> currentPage = DiscoverTypes.values.map((e) => 1).toList();

  Future<MovieProvider> fetchMovieListBy(DiscoverTypes type,
      {int page = 1}) async {
    if (_movies[type] != null && _movies[type]!.isNotEmpty) return this;
    final stringURL = _prepareURL(type);
    final decodedData = await _fetchData(stringURL);
    final results = decodedData['results'] as List<dynamic>;

    final movieData = _extractMoviesData(results);
    _movies[type] = movieData;
    notifyListeners();
    return this;
  }

  String _prepareURL(DiscoverTypes type, {page = 1, int? genre}) {
    String stringURL = "";
    if (type == DiscoverTypes.trending) {
      stringURL = '${keys.baseURL}trending/all/day?api_key=${keys.apiKey}';
    } else if (type == DiscoverTypes.genre) {
      stringURL =
          '${keys.baseURL}discover/movie?api_key=${keys.apiKey}&sort_by=popularity.des&page=$page&with_genres=$genre';
    } else {
      stringURL =
          '${keys.baseURL}movie/${type.toShortString()}?api_key=${keys.apiKey}&language=en-US&page=$page';
    }
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
      //deal with empty values
      final id = movie['id'] ?? 0;
      final title = movie['original_title'] ?? '-';
      final overview = movie['overview'] ?? '-';
      final imageURL = movie['poster_path'] == null
          ? "https://i.postimg.cc/cLWJs6Rb/logo.png"
          : keys.baseImageURL + movie['poster_path'];
      final backDropURL = movie['backdrop_path'] == null
          ? "https://i.postimg.cc/cLWJs6Rb/logo.png"
          : keys.baseImageURL + movie['backdrop_path'];

      final rate = movie['vote_average'] == null
          ? 0.0
          : movie['vote_average'].toDouble();

      String releaseDate = movie['release_date'] ?? '-';
      releaseDate = releaseDate.isEmpty ? '-' : releaseDate;

      String lan = movie['original_language'] ?? '-';

      lan = lan.isEmpty ? '-' : lan;

      movieData.add(Movie(
        id,
        title,
        overview,
        imageURL,
        backDropURL,
        rate,
        releaseDate,
        lan,
      ));
    });

    return movieData;
  }

  Future<void> loadMore(DiscoverTypes type, {int? genre}) async {
    currentPage[type.index]++;

    final url = _prepareURL(type, page: currentPage[type.index], genre: genre);
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

  Future<List<People>> fetchCast(int id) async {
    final stringURL = keys.baseURL +
        "/movie/$id/credits?api_key=${keys.apiKey}&language=en-US";
    final decodedData = await _fetchData(stringURL);

    final _results = decodedData['cast'] as List<dynamic>;
    final maxRange = _results.length < 10 ? _results.length : 10;
    List<People> _cast = [];
    for (var actor in _results.getRange(0, maxRange)) {
      final id = actor['id'];
      final name = actor['name'];
      final originalName = actor['original_name'];
      final gender = actor['gender'];
      final character = actor['character'] ?? "-";
      final profileURL = actor['profile_path'] == null
          ? "https://i.postimg.cc/cLWJs6Rb/logo.png"
          : keys.baseImageURL + actor['profile_path'];

      _cast.add(People(name, id, gender, originalName, character, profileURL));
    }

    return _cast;
  }

  Future<List<Movie>> searchFor(String movieName) async {
    String parsedName = movieName.replaceAll(" ", "+");

    final url =
        "https://api.themoviedb.org/3/search/movie?api_key=${keys.apiKey}&query=$parsedName";
    final response = await _fetchData(url);
    final results = response['results'] as List<dynamic>;
    List<Movie> _searchData = _extractMoviesData(results);
    return _searchData;
  }

  Future<List<Movie>> fetchMovieBy(String genre) async {
    currentPage[DiscoverTypes.genre.index] = 1;

    final url = _prepareURL(DiscoverTypes.genre, genre: keys.genres[genre]);
   
    final decodedData = await _fetchData(url);
    final results = decodedData['results'] as List<dynamic>;
    final List<Movie> _movieData = _extractMoviesData(results);
    _movies[DiscoverTypes.genre] = _movieData;
    return _movieData;
  }

  List<Movie> getMoviesBy(DiscoverTypes type) {
    if (_movies[type] == null) return [];

    return [..._movies[type]!];
  }
}
