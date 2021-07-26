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
  String posterURL;
  String backDropURL;
  final String rate;
  final int releaseDate;
  final String language;
  final int duration;

  Movie(this.id, this.name, this.overview, this.rate, this.releaseDate,
      this.language, this.duration, this.posterURL, this.backDropURL);
}

class MovieProvider with ChangeNotifier {
  Map<DiscoverTypes, List<Movie>> _movies = {};
  Map<int, List<String>> imgs = {};

  List<int> currentPage = DiscoverTypes.values.map((e) => 1).toList();

  Future<MovieProvider> fetchMovieListBy(DiscoverTypes type,
      {int page = 1}) async {
    if (_movies[type] != null && _movies[type]!.isNotEmpty) return this;
    final stringURL = _prepareURL(type);
    final decodedData = await _fetchData(stringURL);

    final results = decodedData as List<dynamic>;

    final movieData = await _extractMoviesData(results);

    _movies[type] = movieData;

    notifyListeners();
    return this;
  }

  String _prepareURL(DiscoverTypes type, {page = 1, String? genre}) {
    String stringURL;
    if (type == DiscoverTypes.genre) {
      stringURL =
          '${keys.baseURL}movies/recommended/daily?&page=$page&limit=${15}&genres=${genre!.toLowerCase()}&extended=full';
    } else {
      stringURL =
          '${keys.baseURL}movies/${type.toShortString()}?api_key=${keys.apiKey}&page=$page&limit=${15}&extended=full';
    }
    return stringURL;
  }

  Future<dynamic> _fetchData(String url) async {
    final parsedURL = Uri.parse(url);
    try {
      final response = await http.get(
        parsedURL,
        headers: {
          'Content-Type': 'application/json',
          'trakt-api-version': '2',
          'trakt-api-key': keys.apiKey,
        },
      );

      return json.decode(response.body);
    } catch (error) {
      throw HttpException(error.toString());
    }
  }

  Future<List<Movie>> _extractMoviesData(List<dynamic> results) async {
    List<Movie> movieData = [];
    for (var movie in results) {
      final res = movie['movie'] ?? movie;
      final id = res['ids']['trakt'] ?? 0;
      print(id);
      final title = res['title'] ?? '-';
      final overview = res['overview'] ?? '-';
      final duration = res['runtime'] ?? 0;
      final rate =
          res['rating'] == null ? '-' : res['rating'].toStringAsFixed(1);

      int releaseDate = res['year'] ?? 0;
      String lan = res['language'] ?? '-';
      lan = lan.isEmpty ? '-' : lan;

      final tmdbId = res['ids']['tmdb'] ?? -1;

      final url = Uri.parse(
          'https://api.themoviedb.org/3/movie/$tmdbId/images?api_key=dd5468d7aa41e016a24fa6bce058252d');

      final response = await http.get(url);

      final images = json.decode(response.body);

      final posterImages = images['posters'] != null
          ? (images['posters'].isNotEmpty ? images['posters'][0] : {})
          : {};
      final imageURL = posterImages['file_path'] == null
          ? "https://i.postimg.cc/cLWJs6Rb/logo.png"
          : keys.baseImageURL + '/w500' + posterImages['file_path'];

      final backdropImages = images['backdrops'] != null
          ? (images['backdrops'].isNotEmpty ? images['backdrops'][0] : {})
          : {};
      final backDropURL = backdropImages['file_path'] == null
          ? "https://i.postimg.cc/cLWJs6Rb/logo.png"
          : keys.baseImageURL + '/w1280' + backdropImages['file_path'];

      movieData.add(Movie(
        id,
        title,
        overview,
        rate,
        releaseDate,
        lan,
        duration,
        imageURL,
        backDropURL,
      ));
    }

    return movieData;
  }

  Future<void> loadMore(DiscoverTypes type, {String? genre}) async {
    currentPage[type.index]++;

    final url = _prepareURL(type, page: currentPage[type.index], genre: genre);
    try {
      final decodedData = await _fetchData(url);

      final results = decodedData as List<dynamic>;

      List<Movie> _movieData = await _extractMoviesData(results);
      _movies[type]!.addAll(_movieData);
    } catch (error) {
      print(error);
      throw HttpException(error.toString());
    }
    notifyListeners();
  }

  Future<List<People>> fetchCast(int id) async {
    final stringURL = keys.baseURL + "movies/$id/people?api_key=${keys.apiKey}";

    final decodedData = await _fetchData(stringURL);

    final _results = decodedData['cast'] as List<dynamic>;

    final maxRange = _results.length < 10 ? _results.length : 10;

    List<People> _cast = [];

    _results.getRange(0, maxRange).forEach((actor) {
      final person = actor['person'];

      final id = person['ids']['trakt'] ?? 0;
      final name = person['name'] ?? '-';

      final List<dynamic> characters = actor['characters'] ?? [];


      List<String> chars = [];
      characters.forEach((element) {
        chars.add(element);
      });

      final profileURL = "https://i.postimg.cc/cLWJs6Rb/logo.png";

      _cast.add(People(name, id, chars, profileURL));
    });

    return _cast;
  }

  Future<List<Movie>> searchFor(String movieName) async {
    String parsedName = movieName.replaceAll(" ", "+");

    final url =
        "https://api.themoviedb.org/3/search/movie?api_key=${keys.apiKey}&query=$parsedName";
    final response = await _fetchData(url);
    final results = response as List<dynamic>;
    List<Movie> _searchData = await _extractMoviesData(results);
    return _searchData;
  }

  Future<List<Movie>> fetchMovieBy(String genre) async {
    currentPage[DiscoverTypes.genre.index] = 1;

    final url = _prepareURL(DiscoverTypes.genre, genre: genre);

    final decodedData = await _fetchData(url);

    final results = decodedData as List<dynamic>;

    final List<Movie> _movieData = await _extractMoviesData(results);

    _movies[DiscoverTypes.genre] = _movieData;
    return _movieData;
  }

  List<Movie> getMoviesBy(DiscoverTypes type) {
    if (_movies[type] == null) return [];

    return [..._movies[type]!];
  }
}
