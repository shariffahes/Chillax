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

class Data {
  late final int id;
  late final String name;
  late final String overview;
  late final String rate;
  late final int releaseDate;
  late final String language;
  late final List<String> genre;
  late final String certification;

  Data(this.id, this.name, this.overview, this.rate, this.releaseDate,
      this.language, this.genre, this.certification);

  String genreToString() {
    return genre.join(", ");
  }
}

class Movie extends Data {
  final int duration;

  // Movie.fromMap(Map<String, Object?> list) {
  //   this.id = list['id'] as int;
  //   this.name = list['name'] as String;
  //   this.overview = list['overview'] as String;
  //   this.rate = list['rate'] as String;
  //   this.releaseDate = list['releaseDate'] as int;
  //   this.language = list['language'] as String;
  //   this.duration = list['duration'] as int;
  //   final String genre = list['name'] as String;
  //   this.genre = genre.split(',');
  //   this.certification = list['certification'] as String;
  // }

  Movie(int id, String name, String overview, String rate, int releaseDate,
      String language, List<String> genre, String certification, this.duration)
      : super(id, name, overview, rate, releaseDate, language, genre,
            certification);

  // Map<String, Object> toMap() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'overview': overview,
  //     'rate': rate,
  //     'releaseDate': releaseDate,
  //     'language': language,
  //     'duration': duration,
  //     'genre': genreToString(),
  //     'certification': certification,
  //     'watched': 0,
  //   };
  // }

}

class Show extends Data {
  final int runTime;
  final String network;
  final String status;
  final int airedEpisode;

  Show(
    int id,
    String name,
    String overview,
    String rate,
    int releaseDate,
    String language,
    List<String> genre,
    String certification,
    this.network,
    this.runTime,
    this.status,
    this.airedEpisode,
  ) : super(id, name, overview, rate, releaseDate, language, genre,
            certification);
}

class DataProvider with ChangeNotifier {
  Map<MovieTypes, List<Movie>> _movies = {};
  Map<TvTypes, List<Show>> _tvShows = {};

  List<List<int>> currentPage = [
    MovieTypes.values.map((e) => 1).toList(),
    TvTypes.values.map((e) => 1).toList()
  ];

  Future<DataProvider> fetchDataListBy(Object type, BuildContext ctx,
      {int page = 1}) async {
    if (type is MovieTypes) {
      if (_movies[type] != null && _movies[type]!.isNotEmpty) return this;

      MovieTypes localType = type;
      final stringURL = _prepareURL(localType, null);
      final decodedData = await _fetchData(stringURL);
      final data = _extractData(decodedData, ctx);
      _movies[localType] = data.cast<Movie>();
    } else if (type is TvTypes) {
      if (_tvShows[type] != null && _tvShows[type]!.isNotEmpty) return this;

      TvTypes localType = type;
      final stringURL = _prepareURL(
        null,
        localType,
      );
      final decodedData = await _fetchData(stringURL);
      final data = _extractData(decodedData, ctx);
      _tvShows[localType] = data.cast<Show>();
    } else {
      print('invalid type');
    }

    notifyListeners();
    return this;
  }

  Future<List<Data>> fetchDataBy(String genre, BuildContext ctx) async {
    currentPage[keys.dataType.index][MovieTypes.genre.index] = 1;

    final url = _prepareURL(MovieTypes.genre, TvTypes.genre, genre: genre);

    final decodedData = await _fetchData(url);

    final results = decodedData as List<dynamic>;

    final List<Data> _data = _extractData(results, ctx);

    //reminder: clear data after finish
    if (keys.isMovie())
      _movies[MovieTypes.genre] = _data.cast<Movie>();
    else
      _tvShows[TvTypes.genre] = _data.cast<Show>();

    return _data;
  }

  List<Data> getDataBy(MovieTypes? movieType, TvTypes? showType) {
    if (movieType != null) {
      if (_movies[movieType] == null) return [];

      return [..._movies[movieType]!];
    } else {
      if (_tvShows[showType] == null) return [];

      return [..._tvShows[showType]!];
    }
  }

  void clearMovieCache(MovieTypes type) {
    if (_movies[type] != null) _movies[type]!.clear();
  }

  List<Data> _extractData(List<dynamic> results, BuildContext ctx) {
    List<Data> itemsInfo = [];

    for (var item in results) {
      dynamic info;
      if (keys.isMovie()) {
        info = item['movie'] ?? item;
      } else {
        info = item['show'] ?? item;
      }

      final id = info['ids']['trakt'] ?? 0;
      final tmdbId = info['ids']['tmdb'] ?? -1;
      Provider.of<PhotoProvider>(ctx, listen: false)
          .fetchImagesFor(tmdbId, id, keys.dataType);

      print(id);
      final title = info['title'] ?? '-';
      final overview = info['overview'] ?? '-';

      final double rating = info['rating'] ?? 0;
      final rate = rating.toStringAsFixed(1);

      final lan = info['language'] ?? '-';
      final certification = info['certification'] ?? '-';
      final int releaseDate = info['year'] ?? 0;

      final List<dynamic> extractedGenres = info['genres'] ?? ['-'];
      int maxRange = extractedGenres.length > 3 ? 3 : extractedGenres.length;
      final List<String> genres =
          extractedGenres.getRange(0, maxRange).toList().cast<String>();

      if (keys.isMovie()) {
        final duration = info['runtime'] ?? 0;
        itemsInfo.add(Movie(
          id,
          title,
          overview,
          rate,
          releaseDate,
          lan,
          genres,
          certification,
          duration,
        ));
      } else {
        final int runtime = info['runtime'] ?? 0;
        final certification = info['certification'] ?? '-';
        final network = info['network'] ?? '-';
        final status = info['status'] ?? '-';
        final airedEpisode = info['aired_episodes'] ?? 0;

        itemsInfo.add(Show(
          id,
          title,
          overview,
          rate,
          releaseDate,
          lan,
          genres,
          certification,
          network,
          runtime,
          status,
          airedEpisode,
        ));
      }
    }

    return itemsInfo;
  }

  String _prepareURL(MovieTypes? movie, TvTypes? tv,
      {page = 1, String? genre, String? searchName}) {
    String stringURL;
    if (keys.dataType == DataType.movie) {
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
              '${keys.baseURL}shows/played/daily?page=$page&limit=${15}&extended=full';
          break;
        case TvTypes.recommended:
          stringURL =
              '${keys.baseURL}shows/recommended/weekly?page=$page&limit=${15}&extended=full';
          break;
        case TvTypes.genre:
          stringURL =
              '${keys.baseURL}shows/recommended/daily?genres=${genre!.toLowerCase()}&page=$page&limit=${15}&extended=full';
          break;
        case TvTypes.search:
          stringURL =
              "${keys.baseURL}search/show?query=$searchName&extended=full&page=$page";
          break;
        default:
          stringURL =
              "${keys.baseURL}shows/${tv!.toShortString()}?extended=full&page=$page&limit${15}";
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

  Future<void> loadMore(
      MovieTypes? movieType, TvTypes? showType, BuildContext ctx,
      {String? genre, String? searchName}) async {
    final index = keys.isMovie() ? movieType!.index : showType!.index;
    currentPage[keys.dataType.index][index]++;

    final url = _prepareURL(movieType, showType,
        page: currentPage[keys.dataType.index][index],
        genre: genre,
        searchName: searchName);
    try {
      final decodedData = await _fetchData(url);
      final results = decodedData as List<dynamic>;

      final data = _extractData(results, ctx);
      if (keys.isMovie())
        _movies[movieType]!.addAll(data.cast<Movie>());
      else
        _tvShows[showType]!.addAll(data.cast<Show>());
    } catch (error) {
      print(error);
      throw HttpException(error.toString());
    }
    notifyListeners();
  }

  Future<List<People>> fetchCast(int id, BuildContext ctx) async {
    final label = keys.isMovie() ? 'movies' : 'shows';
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

  Future<List<Data>> searchFor(String searchName, BuildContext ctx) async {
    final url =
        _prepareURL(MovieTypes.search, TvTypes.search, searchName: searchName);
    final response = await _fetchData(url);
    final results = response as List<dynamic>;
    List<Data> _searchData = _extractData(results, ctx);
    if (keys.isMovie())
      _movies[MovieTypes.search] = _searchData.cast<Movie>();
    else
      _tvShows[TvTypes.search] = _searchData.cast<Show>();
    return _searchData;
  }

  void clearShowCache(TvTypes type) {
    if (_tvShows[type] != null) _tvShows[type]!.clear();
  }

  List<Show> getShowsBy(TvTypes type) {
    if (_tvShows[type] == null) return [];

    return [..._tvShows[type]!];
  }
}
