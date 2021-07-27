import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../providers/PhotoProvider.dart';
import '/models/keys.dart';
import '/models/providers/People.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Movie {
  final int id;
  final String name;
  final String overview;
  final String rate;
  final int releaseDate;
  final String language;
  final int duration;
  final List<String> genre;
  final String certification;

  Movie(
      this.id,
      this.name,
      this.overview,
      this.rate,
      this.releaseDate,
      this.language,
      this.duration,
      this.genre,
      this.certification);

  String genreToString() {
    return genre.join(", ");
  }
}

class MovieProvider with ChangeNotifier {
  Map<DiscoverTypes, List<Movie>> _movies = {};
  Map<int, List<String>> imgs = {};
  

  List<int> currentPage = DiscoverTypes.values.map((e) => 1).toList();

  Future<MovieProvider> fetchMovieListBy(DiscoverTypes type,BuildContext ctx,
      {int page = 1}) async {
    if (_movies[type] != null && _movies[type]!.isNotEmpty) return this;
    final stringURL = _prepareURL(type);
    final decodedData = await _fetchData(stringURL);

    final results = decodedData as List<dynamic>;

    final movieData = await _extractMoviesData(results,ctx);

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

  Future<List<Movie>> _extractMoviesData(List<dynamic> results,BuildContext ctx) async {
    List<Movie> movieData = [];

    for (var movie in results) {
      final res = movie['movie'] ?? movie;
      final id = res['ids']['trakt'] ?? 0;
      final tmdbId = res['ids']['tmdb'] ?? -1;
      Provider.of<PhotoProvider>(ctx, listen: false)
          .fetchImagesFor(tmdbId, id, ImageType.movie);
      print(id);
      final title = res['title'] ?? '-';
      final overview = res['overview'] ?? '-';
      final duration = res['runtime'] ?? 0;
      final rate =
          res['rating'] == null ? '-' : res['rating'].toStringAsFixed(1);
      final certification = res['certification'] ?? '-';

      int releaseDate = res['year'] ?? 0;
      String lan = res['language'] ?? '-';
      lan = lan.isEmpty ? '-' : lan;

      final List<dynamic> extractedGenres = res['genres'] ?? ['-'];
      final List<String> genres = [];
      int maxRange = extractedGenres.length > 3 ? 3 : extractedGenres.length;
      extractedGenres.getRange(0, maxRange).forEach((element) {
        genres.add(element);
      });

      movieData.add(Movie(
        id,
        title,
        overview,
        rate,
        releaseDate,
        lan,
        duration,
        genres,
        certification,
      ));
    }

    return movieData;
  }

  Future<void> loadMore(DiscoverTypes type,BuildContext ctx, {String? genre}) async {
    currentPage[type.index]++;

    final url = _prepareURL(type, page: currentPage[type.index], genre: genre);
    try {
      final decodedData = await _fetchData(url);

      final results = decodedData as List<dynamic>;

      List<Movie> _movieData = await _extractMoviesData(results,ctx);
      _movies[type]!.addAll(_movieData);
    } catch (error) {
      print(error);
      throw HttpException(error.toString());
    }
    notifyListeners();
  }

  Future<List<People>> fetchCast(int id, BuildContext ctx) async {
    final stringURL = keys.baseURL + "movies/$id/people?api_key=${keys.apiKey}";

    final decodedData = await _fetchData(stringURL);

    final _results = decodedData['cast'] as List<dynamic>;

    final maxRange = _results.length < 10 ? _results.length : 10;

    List<People> _cast = [];

    _results.getRange(0, maxRange).forEach((actor) {
      final person = actor['person'];

      final id = person['ids']['trakt'] ?? 0;
      final tmdbId = person['ids']['tmdb'] ?? 0;
      Provider.of<PhotoProvider>(ctx, listen: false)
          .fetchImagesFor(tmdbId, id, ImageType.person);

      final name = person['name'] ?? '-';
      final List<dynamic> characters = actor['characters'] ?? [];

      List<String> chars = [];
      characters.forEach((element) {
        chars.add(element);
      });

      _cast.add(People(name, id, chars));
    });

    return _cast;
  }

  Future<List<Movie>> searchFor(String movieName,BuildContext ctx) async {
    String parsedName = movieName.replaceAll(" ", "+");

    final url =
        "https://api.themoviedb.org/3/search/movie?api_key=${keys.apiKey}&query=$parsedName";
    final response = await _fetchData(url);
    final results = response as List<dynamic>;
    List<Movie> _searchData = await _extractMoviesData(results,ctx);
    return _searchData;
  }

  Future<List<Movie>> fetchMovieBy(String genre, BuildContext ctx) async {
    currentPage[DiscoverTypes.genre.index] = 1;

    final url = _prepareURL(DiscoverTypes.genre, genre: genre);

    final decodedData = await _fetchData(url);

    final results = decodedData as List<dynamic>;

    final List<Movie> _movieData = await _extractMoviesData(results,ctx);

    _movies[DiscoverTypes.genre] = _movieData;
    return _movieData;
  }

  List<Movie> getMoviesBy(DiscoverTypes type) {
    if (_movies[type] == null) return [];

    return [..._movies[type]!];
  }
}
