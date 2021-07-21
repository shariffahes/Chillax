import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/People.dart';
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
    print('the type $type');
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

      final rate = movie['vote_average'].toDouble();
      final releaseDate = movie['release_date'] ?? "-";
      final lan = movie['original_language'] ?? "-";
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

  Future<List<Map<String, Object>>> searchFor(String movieName) async {
    String parsedName = movieName.replaceAll(" ", "+");

    final url =
        "https://api.themoviedb.org/3/search/movie?api_key=${keys.apiKey}&query=$parsedName";
    final response = await _fetchData(url);
    final results = response['results'] as List<dynamic>;

    List<Map<String, Object>> _searchData = [];

    results.forEach((movie) {
      Map<String, Object> _movieData = {};
      _movieData['name'] = movie['title'];
      _movieData['poster'] = movie['poster_path'] == null
          ? "https://i.postimg.cc/cLWJs6Rb/logo.png"
          : keys.baseImageURL + movie['poster_path'];

      _movieData['id'] = movie['id'];
      _searchData.add(_movieData);
    });

    return _searchData;
  }

  Future<Movie> fetchDetails(int movieID) async {
    final url =
        "https://api.themoviedb.org/3/movie/$movieID?api_key=${keys.apiKey}";
    final decodedData = await _fetchData(url);
    final id = decodedData['id'];

    final name = decodedData['original_title'];
    final overview = decodedData['overview'];
    final imageURL = decodedData['poster_path'] == null
        ? "https://i.postimg.cc/cLWJs6Rb/logo.png"
        : keys.baseImageURL + decodedData['poster_path'];
    final backDropURL = decodedData['backdrop_path'] == null
        ? "https://i.postimg.cc/cLWJs6Rb/logo.png"
        : keys.baseImageURL + decodedData['backdrop_path'];
    final rate = decodedData['vote_average'].toDouble();
    final releaseDate = decodedData['release_date'] ?? "-";
    final lan = decodedData['original_language'] ?? "-";
    Movie movie = Movie(
        id, name, overview, imageURL, backDropURL, rate, releaseDate, lan);
    return movie;
  }

  List<Movie> getMoviesBy(DiscoverTypes type) {
    if (_movies[type] == null) return [];

    return [..._movies[type]!];
  }
}
