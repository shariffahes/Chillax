import 'package:discuss_it/models/providers/User.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
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
  late final int yearOfRelease;
  late final String language;
  late final List<String> genre;
  late final String certification;
  late final String releasedDate;
  late final String homePage;
  late final String trailer;

  Data(
      this.id,
      this.name,
      this.overview,
      this.rate,
      this.yearOfRelease,
      this.language,
      this.genre,
      this.certification,
      this.releasedDate,
      this.homePage,
      this.trailer);

  //special constuctor for filling some data
  Data.compressed(
    this.id,
    this.name,
    this.releasedDate,
  ) {
    overview = '-';
    rate = '-';
    yearOfRelease = 0;
    language = '-';
    genre = [];
    certification = '-';
    trailer = '-';
    homePage = '-';
  }

  String genreToString() {
    return genre.join(", ");
  }
}

//movie is data with special modification
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

  Movie(
    int id,
    String name,
    String overview,
    String rate,
    int yearOfRelease,
    String language,
    List<String> genre,
    String certification,
    String releasedDate,
    String homePage,
    String trailer,
    this.duration,
  ) : super(id, name, overview, rate, yearOfRelease, language, genre,
            certification, releasedDate, homePage, trailer);

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

//show is data with special modification
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
    int yearOfRelease,
    String language,
    List<String> genre,
    String certification,
    String releasedDate,
    String homepage,
    String trailer,
    this.network,
    this.runTime,
    this.status,
    this.airedEpisode,
  ) : super(id, name, overview, rate, yearOfRelease, language, genre,
            certification, releasedDate, homepage, trailer);
}

//episodes used to track the episode when added to watch list
class Episode {
  final int id;
  final int tmdbId;
  final String name;
  final int number;
  final int season;
  Episode(this.id, this.tmdbId, this.name, this.number, this.season);
}

class DataProvider with ChangeNotifier {
  Map<MovieTypes, List<Movie>> _movies = {};
  Map<TvTypes, List<Show>> _tvShows = {};
  List<Map<String, List<Data>>> _mySchedule = [];

  //tracks the list of episode for the movie id
  Map<int, Map<int, List<Episode>>> _seriesEpisodes = {};

  //helps store the schedule for movies and show. Used in calendar
  List<Map<String, List<Data>>> schedule = [Map(), Map()];

  //current page keeps track of which page the system should request
  //this is used in view all screen when user needs to load more than 15 items
  //each page loads 15 items
  List<List<int>> currentPage = [
    MovieTypes.values.map((e) => 1).toList(),
    TvTypes.values.map((e) => 1).toList()
  ];

//this is called at the start of the page
  Future<DataProvider> fetchDataListBy(Object type, BuildContext ctx,
      {int page = 1}) async {
    if (type is MovieTypes) {
      //when the movies or shows for this type is already fetched do not
      //fetch them again.
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

//this method is called when user need to get specific genres
  Future<List<Data>> fetchDataBy(String genre, BuildContext ctx) async {
    //each time you open a genre, it will be reset to first page
    //movies and shows data are always cleared from the map when we move
    //to the next genre
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

//called to clear the data in the movie map
  void clearMovieCache(MovieTypes type) {
    if (_movies[type] != null) _movies[type]!.clear();
  }

//called when need to extract the data from an http request
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

      //fetch the images from tmdb.
      //fetch is not sync to avoid the long wait to get the image
      //so we fetch the image and notify listeners when finished
      Provider.of<PhotoProvider>(ctx, listen: false)
          .fetchImagesFor(tmdbId, id, keys.dataType);

      print(id);
      final title = info['title'] ?? '-';
      final overview = info['overview'] ?? '-';

      final double rating = info['rating'] ?? 0;
      final rate = rating.toStringAsFixed(1);

      final lan = info['language'] ?? '-';
      final certification = info['certification'] ?? '-';
      final int year = info['year'] ?? 0;
      final homePage = info['homepage'] ?? '-';
      final trailer = info['trailer'] ?? '-';

      final List<dynamic> extractedGenres = info['genres'] ?? ['-'];
      int maxRange = extractedGenres.length > 3 ? 3 : extractedGenres.length;
      final List<String> genres =
          extractedGenres.getRange(0, maxRange).toList().cast<String>();

      if (keys.isMovie()) {
        final duration = info['runtime'] ?? 0;
        final releasedDate = info['released'] ?? '-';

        itemsInfo.add(Movie(id, title, overview, rate, year, lan, genres,
            certification, releasedDate, homePage, trailer, duration));
      } else {
        final int runtime = info['runtime'] ?? 0;
        final certification = info['certification'] ?? '-';
        final network = info['network'] ?? '-';
        final status = info['status'] ?? '-';
        final airedEpisode = info['aired_episodes'] ?? 0;
        final releasedDate = info['first_aired'] ?? '-';

        itemsInfo.add(Show(
          id,
          title,
          overview,
          rate,
          year,
          lan,
          genres,
          certification,
          releasedDate,
          homePage,
          trailer,
          network,
          runtime,
          status,
          airedEpisode,
        ));
      }
    }

    return itemsInfo;
  }

//it will prepare a url based on data type orif it is genre or search
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

//responsible to get the json data from trakt
  Future<dynamic> _fetchData(String url) async {
    final parsedURL = Uri.parse(url);
    print('fetch');
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

//the method that loads more data from the another page.

  Future<void> loadMore(
      MovieTypes? movieType, TvTypes? showType, BuildContext ctx,
      {String? genre, String? searchName}) async {
    //find if it is movie or show list
    final index = keys.isMovie() ? movieType!.index : showType!.index;
    //start incrementing the previous value
    currentPage[keys.dataType.index][index]++;

//prepare url and fetch data
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

//when preview page is opened. you fetch the cast by this method
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

      //responsible to fetch the images
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

  Future<DataProvider> fetchEpisodes(int id) async {
    if (_seriesEpisodes[id] != null) return this;
    final url =
        Uri.parse('https://api.trakt.tv/shows/$id/seasons?extended=episodes');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'trakt-api-version': '2',
        'trakt-api-key': keys.apiKey,
      },
    );
    final results = json.decode(response.body) as List<dynamic>;
    Map<int, List<Episode>> info = {};
    for (var season in results) {
      final number = season['number'];
      if (number == 0) continue;
      final episodes = season['episodes'] as List<dynamic>;
      List<Episode> ep = [];

      episodes.forEach(
        (episode) {
          final int id = episode['ids']['trakt'] ?? 0;
          final tmdbId = episode['ids']['tmdb'] ?? -1;
          final name = episode['title'] ?? '-';
          final num = episode['number'] ?? -1;

          ep.add(Episode(id, tmdbId, name, num, number));
        },
      );
      info[number] = ep;
    }
    _seriesEpisodes[id] = info;

    return this;
  }

  Episode? getEpisodeInfo(int id, int season, int episode, BuildContext ctx) {
    Provider.of<User>(ctx, listen: false).updateNext(id, season, episode + 1);
    episode = episode - 1;
    if (_seriesEpisodes[id] == null) return null;
    if (season > _seriesEpisodes[id]!.keys.length) return null;

    if (episode >= _seriesEpisodes[id]![season]!.length)
      return getEpisodeInfo(id, season + 1, 1, ctx);

    return _seriesEpisodes[id]![season]![episode];
  }

  Future<List<Data>> getScheduleFor(
      String date, bool isAll, BuildContext ctx) async {
    final ind = keys.dataType.index;

    if (schedule.isEmpty) {
      schedule.add(Map());
      schedule.add(Map());
    }
    if (_mySchedule.isEmpty) {
      _mySchedule.add(Map());
      _mySchedule.add(Map());
    }

    if (schedule[ind][date] != null) {
      //isAll helps to know if the user wants to see if there is new seasons coming for
      //his show or wants to see all shows/movies.
      if (!isAll && _mySchedule[ind][date] == null) return [];

      return isAll ? schedule[ind][date]! : _mySchedule[ind][date]!;
    }

    final label = keys.isMovie() ? 'movies' : 'shows';
    final url = 'https://api.trakt.tv/calendars/all/$label/$date/1';

    final response = await _fetchData(url);
    final decodedData = response as List<dynamic>;

    decodedData.forEach(
      (element) {
        if (keys.isMovie()) {
          final dateOfRelease = element['released'] ?? date;
          final title = element['movie']['title'] ?? '-';
          final id = element['movie']['ids']['trakt'] ?? 0;
          final bool isFirst =
              Provider.of<User>(ctx, listen: false).movieWatchList['id'] !=
                  null;
          final tmdbId = element['movie']['ids']['tmdb'] ?? -1;
          if (tmdbId != -1)
            Provider.of<PhotoProvider>(ctx, listen: false)
                .fetchImagesFor(tmdbId, id, keys.dataType);
          Data data = Data.compressed(id, title, dateOfRelease);
          if (schedule[ind][dateOfRelease] == null) {
            schedule[ind][dateOfRelease] = [data];
          } else {
            schedule[ind][dateOfRelease]!.add(data);
          }
          if (isFirst) {
            if (_mySchedule[ind][dateOfRelease] == null)
              _mySchedule[ind][dateOfRelease] = [data];
            else
              _mySchedule[ind][dateOfRelease]!.add(data);
          }
        } else {
          final String firstAired = element['first_aired'];
          final title = element['show']['title'] ?? '-';
          final id = element['show']['ids']['trakt'] ?? 0;
          final tmdbId = element['show']['ids']['tmdb'] ?? -1;
          print(tmdbId);
          if (tmdbId != -1)
            Provider.of<PhotoProvider>(ctx, listen: false)
                .fetchImagesFor(tmdbId, id, keys.dataType);

          final dateOfRelease = firstAired.split('T').first;
          final user = Provider.of<User>(ctx, listen: false);
          Map<int, Data> watchingMap = {};

          //loop just one time on watching.
          //this helps by decreasing the number of looping each time we want
          //to check if the show is currently watching or not
          if (watchingMap.isEmpty) watchingMap = user.WatchingtoMap();

          //if the show has been watched, in the watching list, or currently watching
          //turn is First to true which will notify that this show should be in my schedule
          final isFirst = user.showWatchList[id] != null ||
              user.watchedShows[id] != null ||
              watchingMap[id] != null;

          Data data = Data.compressed(id, title, firstAired);
          if (schedule[ind][dateOfRelease] == null) {
            schedule[ind]
                [dateOfRelease] = [Data.compressed(id, title, firstAired)];
          } else {
            schedule[ind][dateOfRelease]!
                .add(Data.compressed(id, title, firstAired));
          }
          if (isFirst) {
            if (_mySchedule[ind][dateOfRelease] == null)
              _mySchedule[ind][dateOfRelease] = [data];
            else
              _mySchedule[ind][dateOfRelease]!.add(data);
          }
        }
      },
    );

    return isAll ? schedule[ind][date]! : (_mySchedule[ind][date] ?? []);
  }
}
