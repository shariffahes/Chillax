import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../providers/PhotoProvider.dart';
import '/models/keys.dart';
import '/models/providers/People.dart';
import 'dart:convert';
import 'dart:io';
import '../Enums.dart';

class Movie {
  late final int id;
  late final String name;
  late final String overview;
  late final String rate;
  late final int releaseDate;
  late final String language;
  late final int duration;
  late final List<String> genre;
  late final String certification;

  Movie.fromMap(Map<String, Object?> list) {
    this.id = list['id'] as int;
    this.name = list['name'] as String;
    this.overview = list['overview'] as String;
    this.rate = list['rate'] as String;
    this.releaseDate = list['releaseDate'] as int;
    this.language = list['language'] as String;
    this.duration = list['duration'] as int;
    final String genre = list['name'] as String;
    this.genre = genre.split(',');
    this.certification = list['certification'] as String;
  }

  Movie(this.id, this.name, this.overview, this.rate, this.releaseDate,
      this.language, this.duration, this.genre, this.certification);

  String genreToString() {
    return genre.join(", ");
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'name': name,
      'overview': overview,
      'rate': rate,
      'releaseDate': releaseDate,
      'language': language,
      'duration': duration,
      'genre': genreToString(),
      'certification': certification,
      'watched': 0,
    };
  }
}

class Show {
  final int id;
  final String name;
  final int year;
  final String overview;
  final String runTime;
  final String certification;
  final String network;
  final String status;
  final String rate;
  final String lan;
  final List<String> genres;
  final int airedEpisode;

  Show(
      this.id,
      this.name,
      this.year,
      this.overview,
      this.runTime,
      this.certification,
      this.network,
      this.status,
      this.rate,
      this.lan,
      this.genres,
      this.airedEpisode);
}

class DataProvider with ChangeNotifier {
  Map<MovieTypes, List<Movie>> _movies = {};
  Map<TvTypes, List<Show>> _tvShows = {};

  List<int> currentPage = MovieTypes.values.map((e) => 1).toList();

  Future<DataProvider> fetchMovieListBy(MovieTypes type, BuildContext ctx,
      {int page = 1}) async {
    if (_movies[type] != null && _movies[type]!.isNotEmpty) return this;
    final stringURL = _prepareURL(DataType.movie, type, null);
    final decodedData = await _fetchData(stringURL);

    final results = decodedData as List<dynamic>;

    final movieData = _extractMoviesData(results, ctx);

    _movies[type] = movieData;

    notifyListeners();
    return this;
  }

  Future<List<Movie>> fetchMovieBy(String genre, BuildContext ctx) async {
    currentPage[MovieTypes.genre.index] = 1;

    final url =
        _prepareURL(DataType.movie, MovieTypes.genre, null, genre: genre);

    final decodedData = await _fetchData(url);

    final results = decodedData as List<dynamic>;

    final List<Movie> _movieData = _extractMoviesData(results, ctx);
//reminder: clear data after finish
    _movies[MovieTypes.genre] = _movieData;
    return _movieData;
  }

  List<Movie> getMoviesBy(MovieTypes type) {
    if (_movies[type] == null) return [];

    return [..._movies[type]!];
  }

  void clearMovieCache(MovieTypes type) {
    if (_movies[type] != null) _movies[type]!.clear();
  }

  List<Movie> _extractMoviesData(List<dynamic> results, BuildContext ctx) {
    List<Movie> movieData = [];

    for (var movie in results) {
      final res = movie['movie'] ?? movie;
      final id = res['ids']['trakt'] ?? 0;
      final tmdbId = res['ids']['tmdb'] ?? -1;
      Provider.of<PhotoProvider>(ctx, listen: false)
          .fetchImagesFor(tmdbId, id, DataType.movie);
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

  String _prepareURL(DataType dataType, MovieTypes? movie, TvTypes? tv,
      {page = 1, String? genre, String? searchName}) {
    String stringURL;
    if (dataType == DataType.movie) {
      switch (movie) {
        case MovieTypes.genre:
          stringURL =
              '${keys.baseURL}movies/recommended/daily?&page=$page&limit=${15}&genres=${genre!.toLowerCase()}&extended=full';
          break;
        case MovieTypes.search:
          stringURL =
              "${keys.baseURL}search/movie?query=$searchName&extended=full&page=$page";
          break;
        default:
          stringURL =
              '${keys.baseURL}movies/${movie!.toShortString()}?page=$page&limit=${15}&extended=full';
          break;
      }
    } else {
      switch (tv) {
        case TvTypes.played:
          stringURL =
              '${keys.apiKey}shows/played/daily?page=$page&limit=${15}&extended=full';
          break;
        case TvTypes.recommended:
          stringURL =
              '${keys.apiKey}shows/recommended/weekly?page=$page&limit=${15}&extended=full';
          break;
        case TvTypes.genre:
          stringURL =
              '${keys.apiKey}shows/recommended/daily?genres=${genre!.toLowerCase()}&page=$page&limit=${15}&extended=full';
          break;
        case TvTypes.search:
          stringURL =
              "${keys.baseURL}search/show?query=$searchName&extended=full&page=$page";
          break;
        default:
          stringURL =
              "${keys.baseURL}search/shows/${tv!.toShortString()}?extended=full&page=$page";
          break;
      }
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

  Future<void> loadMoreMovies(MovieTypes movieType, BuildContext ctx,
      {String? genre, String? searchName}) async {
    currentPage[movieType.index]++;
    final url = _prepareURL(DataType.movie, movieType, null,
        page: currentPage[movieType.index],
        genre: genre,
        searchName: searchName);

    try {
      final decodedData = await _fetchData(url);
      final results = decodedData as List<dynamic>;

      final data = _extractMoviesData(results, ctx);
      _movies[movieType]!.addAll(data);
    } catch (error) {
      print(error);
      throw HttpException(error.toString());
    }
    notifyListeners();
  }

  Future<List<People>> fetchCast(
      int id, DataType type, BuildContext ctx) async {
    final label = type == DataType.movie ? 'movies' : 'shows';
    final stringURL = keys.baseURL + "$label/$id/people?api_key=${keys.apiKey}";

    final decodedData = await _fetchData(stringURL);

    final _results = decodedData['cast'] as List<dynamic>;

    final maxRange = _results.length < 10 ? _results.length : 10;

    List<People> _cast = [];

    _results.getRange(0, maxRange).forEach((actor) {
      final person = actor['person'];

      final id = person['ids']['trakt'] ?? 0;
      final tmdbId = person['ids']['tmdb'] ?? 0;
      Provider.of<PhotoProvider>(ctx, listen: false)
          .fetchImagesFor(tmdbId, id, DataType.person);

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

  Future<List<Movie>> searchFor(String searchName, BuildContext ctx) async {
    final url = _prepareURL(DataType.movie, MovieTypes.search, null,
        searchName: searchName);
    final response = await _fetchData(url);
    final results = response as List<dynamic>;
    List<Movie> _searchData = _extractMoviesData(results, ctx);
    _movies[MovieTypes.search] = _searchData;
    return _searchData;
  }

  List<Show> _extractShowData(List<dynamic> results, BuildContext ctx) {
    List<Show> showsData = [];

    results.forEach((item) {
      final show = item['show'];

      final id = show['ids']['trakt'];
      final tmdbID = show['ids']['tmdb'];
      Provider.of<PhotoProvider>(ctx, listen: false)
          .fetchImagesFor(tmdbID, id, DataType.tvShow);
      final title = show['title'] ?? '-';
      final release = show['year'] ?? '-';
      final overview = show['overview'] ?? '-';
      final runtime = show['runtime'] ?? '-';
      final certification = show['certification'] ?? '-';
      final network = show['network'] ?? '-';
      final status = show['status'] ?? '-';
      final double rating = show['rating'] ?? 0;
      final rate = rating.toStringAsFixed(2);
      final lan = show['language'] ?? '-';
      final List<String> listGenre = show['genres'] ?? [''];
      int maxRange = listGenre.length > 3 ? 3 : listGenre.length;
      final genres = listGenre.getRange(0, maxRange).toList();

      final airedEpisode = show['aired_episodes'];
      showsData.add(Show(
        id,
        title,
        release,
        overview,
        runtime,
        certification,
        network,
        status,
        rate,
        lan,
        genres,
        airedEpisode,
      ));
    });
    return showsData;
  }

  Future<DataProvider> fetchTvShows(TvTypes type, BuildContext ctx) async {
    if (_tvShows[type] != null && _tvShows[type]!.isNotEmpty) return this;

    final url = _prepareURL(DataType.tvShow, null, type);
    final response = await _fetchData(url);
    final results = response as List<dynamic>;
    final List<Show> showsData = _extractShowData(results, ctx);
    _tvShows[type] = showsData;
    notifyListeners();
    return this;
  }

  Future<List<Show>> fetchShowGenre(String genre, BuildContext ctx) async {
    currentPage[MovieTypes.genre.index] = 1;

    final url = _prepareURL(DataType.tvShow, null, TvTypes.genre, genre: genre);

    final decodedData = await _fetchData(url);

    final results = decodedData as List<dynamic>;

    final List<Show> _showData = _extractShowData(results, ctx);
//reminder: clear data after finish
    _tvShows[TvTypes.genre] = _showData;
    return _showData;
  }

  void clearShowCache(TvTypes type) {
    if (_tvShows[type] != null) _tvShows[type]!.clear();
  }

  List<Show> getShowsBy(TvTypes type) {
    if (_tvShows[type] == null) return [];

    return [..._tvShows[type]!];
  }

  Future<void> loadMoreShows(TvTypes showType, BuildContext ctx,
      {String? genre, String? searchName}) async {
    currentPage[showType.index]++;

    final url = _prepareURL(DataType.tvShow, null, showType,
        page: currentPage[showType.index],
        genre: genre,
        searchName: searchName);

    try {
      final decodedData = await _fetchData(url);
      final results = decodedData as List<dynamic>;

      final data = _extractShowData(results, ctx);
      _tvShows[showType]!.addAll(data);
    } catch (error) {
      print(error);
      throw HttpException(error.toString());
    }
    notifyListeners();
  }
}
