import 'package:discuss_it/models/providers/User.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../providers/PhotoProvider.dart';
import '../Global.dart';
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
  late final int tmdb;

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
      this.trailer,
      this.tmdb);

  //special constuctor for filling some data
  Data.compressed(
    this.id,
    this.tmdb,
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
    int tmdb,
    this.duration,
  ) : super(id, name, overview, rate, yearOfRelease, language, genre,
            certification, releasedDate, homePage, trailer, tmdb);

  static Movie fromMap(Map<String, Object?> list) {
    int id = list['id'] as int;
    String name = list['name'] as String;
    String overview = list['overview'] as String;
    String rate = list['rate'] as String;
    int year = list['year'] as int;
    String language = list['language'] as String;
    String releasedDate = list['releaseDate'] as String;
    int duration = list['duration'] as int;
    String namedGenre = list['genre'] as String;
    List<String> genre = namedGenre.split(',');
    String certification = list['certification'] as String;
    String homePage = list['homePage'] as String;
    String trailer = list['trailer'] as String;
    int tmdb = list['tmdb'] as int;
    return Movie(
      id,
      name,
      overview,
      rate,
      year,
      language,
      genre,
      certification,
      releasedDate,
      homePage,
      trailer,
      tmdb,
      duration,
    );
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'tmdb': tmdb,
      'name': name,
      'overview': overview,
      'rate': rate,
      'year': yearOfRelease,
      'language': language,
      'duration': duration,
      'genre': genreToString(),
      'certification': certification,
      'releaseDate': releasedDate,
      'homePage': homePage,
      'trailer': trailer,
      'watched': 0,
    };
  }
}

//show is data with special modification
class Show extends Data {
  final int runTime;
  final String network;
  final String status;
  final int airedEpisode;

  Map<int, List<Episode>>? episodes;
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
      int tmdb,
      this.network,
      this.runTime,
      this.status,
      this.airedEpisode)
      : super(id, name, overview, rate, yearOfRelease, language, genre,
            certification, releasedDate, homepage, trailer, tmdb);

  void setEpisodes(Map<int, List<Episode>> eps) {
    episodes = {...eps};
  }

  static Show fromMap(Map<String, Object?> list) {
    int id = list['id'] as int;
    String name = list['name'] as String;
    String overview = list['overview'] as String;
    String rate = list['rate'] as String;
    int year = list['year'] as int;
    String language = list['language'] as String;
    String releasedDate = list['releaseDate'] as String;
    int runtime = list['runTime'] as int;
    String namedGenre = list['genre'] as String;
    List<String> genre = namedGenre.split(',');
    String certification = list['certification'] as String;
    String homePage = list['homePage'] as String;
    String trailer = list['trailer'] as String;
    String network = list['network'] as String;
    String status = list['status'] as String;
    int airedEpisodes = list['airedEpisodes'] as int;
    int tmdb = list['tmdb'] as int;

    return Show(
        id,
        name,
        overview,
        rate,
        year,
        language,
        genre,
        certification,
        releasedDate,
        homePage,
        trailer,
        tmdb,
        network,
        runtime,
        status,
        airedEpisodes);
  }

  Map<String, Object> toMap() {
    return {
      'id': id,
      'tmdb': tmdb,
      'name': name,
      'overview': overview,
      'rate': rate,
      'year': yearOfRelease,
      'language': language,
      'runTime': runTime,
      'genre': genreToString(),
      'certification': certification,
      'releaseDate': releasedDate,
      'homePage': homePage,
      'trailer': trailer,
      'network': network,
      'status': status,
      'airedEpisodes': airedEpisode,
      'watched': 0,
    };
  }
}

//episodes used to track the episode when added to watch list
class Episode extends Data {
  final int epsId;
  final int number;
  final int season;
  int? seasonId;
  final int runTime;
  Episode(
    this.epsId,
    int showId,
    String name,
    String overview,
    String rate,
    String airedDate,
    int year,
    int tmdbId,
    this.season,
    this.number,
    this.runTime,
  ) : super(showId, name, overview, rate, year, '-', [], '-', airedDate, '-',
            '-', tmdbId);

  void setSeasonId(int id) {
    seasonId = id;
  }
}

class DataProvider with ChangeNotifier {
  static Map<int, Data> dataDB = {};
  static Map<int, List<int>> seasonIds = {};
  List<List<int>> _movies = List.filled(MovieTypes.values.length, []);
  //static Map<TvTypes, List<Show>> tvShowsDB = {};
  List<List<int>> _tvShows = List.filled(TvTypes.values.length, []);
  Map<String, List<int>> _myMovieSchedule = {};
  Map<String, List<int>> _myTvSchedule = {};
  //helps store the schedule for movies and show. Used in calendar
  Map<DateTime, List<int>> movieSchedule = {};
  static Map<int, Map<String, Object>> tvSchedule = {};
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
      int ind = type.index;
      //when the movies or shows for this type is already fetched do not
      //fetch them again.
      if (_movies.isNotEmpty && _movies[ind].isNotEmpty) return this;

      MovieTypes localType = type;
      final stringURL = _prepareURL(localType, null);
      final decodedData = await _fetchData(stringURL);

      final data = _extractData(decodedData, ctx);
      _movies[ind] = data.cast<int>();
    } else if (type is TvTypes) {
      int ind = type.index;
      if (_tvShows[ind].isNotEmpty) return this;

      TvTypes localType = type;
      final stringURL = _prepareURL(
        null,
        localType,
      );
      final decodedData = await _fetchData(stringURL);
      final data = _extractData(decodedData, ctx);
      _tvShows[ind] = data.cast<int>();
    } else {
      print('invalid type');
    }

    notifyListeners();
    return this;
  }

//this method is called when user need to get specific genres
  Future<List<int>> fetchDataBy(BuildContext ctx,
      {int? id, String? genre}) async {
    //each time you open a genre, it will be reset to first page
    //movies and shows data are always cleared from the map when we move
    //to the next genre
    currentPage[Global.dataType.index][MovieTypes.genre.index] = 1;
    MovieTypes movieType =
        genre == null ? MovieTypes.similar : MovieTypes.genre;
    TvTypes tvType = genre == null ? TvTypes.similar : TvTypes.genre;

    final url = _prepareURL(movieType, tvType, genre: genre, id: id);

    final decodedData = await _fetchData(url);

    final results = decodedData as List<dynamic>;

    final List<int> _data = _extractData(results, ctx);

    //reminder: clear data after finish
    if (Global.isMovie())
      _movies[MovieTypes.genre.index] = _data;
    else
      _tvShows[TvTypes.genre.index] = _data;

    return _data;
  }

  List<int> getDataBy(MovieTypes? movieType, TvTypes? showType) {
    if (movieType != null) {
      int ind = movieType.index;
      if (_movies[ind].isEmpty) return [];

      return [..._movies[ind]];
    } else {
      if (_tvShows[showType!.index].isEmpty) return [];

      return [..._tvShows[showType.index]];
    }
  }

//called to clear the data in the movie map
  void clearMovieCache(MovieTypes type) {
    if (_movies[type.index].isNotEmpty) _movies[type.index].clear();
  }

//called when need to extract the data from an http request
  List<int> _extractData(
    List<dynamic> results,
    BuildContext ctx,
  ) {
    List<int> itemsInfo = [];

    for (var item in results) {
      dynamic info;

      if (Global.isMovie()) {
        info = item['movie'] ?? item;
      } else {
        info = item['show'] ?? item;
      }

      final id = info['ids']['trakt'] ?? 0;
      final tmdbId = info['ids']['tmdb'] ?? -1;
      //fetch the images from tmdb.
      //fetch is not sync to avoid the long wait to get the image
      //so we fetch the image and notify listeners when finished
      if (tmdbId != -1)
        Provider.of<PhotoProvider>(ctx, listen: false)
            .fetchImagesFor(tmdbId, id, Global.dataType);

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

      if (Global.isMovie()) {
        final duration = info['runtime'] ?? 0;
        final releasedDate = info['released'] ?? '-';
        final movie = Movie(
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
          tmdbId,
          duration,
        );

        dataDB[id] = movie;

        itemsInfo.add(id);
      } else {
        final int runtime = info['runtime'] ?? 0;
        final certification = info['certification'] ?? '-';
        final network = info['network'] ?? '-';
        final status = info['status'] ?? '-';
        final airedEpisode = info['aired_episodes'] ?? 0;
        final releasedDate = info['first_aired'] ?? '-';
        final episodesInfo =
            dataDB[id] != null ? (dataDB[id] as Show).episodes : null;
        final Show show = Show(
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
          tmdbId,
          network,
          runtime,
          status,
          airedEpisode,
        );
        show.episodes = episodesInfo;
        dataDB[id] = show;
        itemsInfo.add(id);
      }
    }

    return itemsInfo;
  }

//it will prepare a url based on data type orif it is genre or search
  String _prepareURL(MovieTypes? movie, TvTypes? tv,
      {page = 1, String? genre, String? searchName, int? id}) {
    String stringURL;
    if (Global.dataType == DataType.movie) {
      switch (movie) {
        case MovieTypes.genre:
          stringURL =
              '${Global.baseURL}movies/recommended/daily?&page=$page&limit=${15}&genres=${genre!.toLowerCase()}&extended=full';
          break;
        case MovieTypes.search:
          stringURL =
              "${Global.baseURL}search/movie?query=$searchName&extended=full&page=$page";
          break;
        case MovieTypes.similar:
          stringURL = '${Global.baseURL}movies/$id/related?extended=full';
          break;
        default:
          stringURL =
              '${Global.baseURL}movies/${movie!.toShortString()}?page=$page&limit=${15}&extended=full';

          break;
      }
    } else {
      switch (tv) {
        case TvTypes.played:
          stringURL =
              '${Global.baseURL}shows/played/daily?page=$page&limit=${15}&extended=full';
          break;
        case TvTypes.recommended:
          stringURL =
              '${Global.baseURL}shows/recommended/weekly?page=$page&limit=${15}&extended=full';
          break;
        case TvTypes.genre:
          stringURL =
              '${Global.baseURL}shows/recommended/daily?genres=${genre!.toLowerCase()}&page=$page&limit=${15}&extended=full';
          break;
        case TvTypes.search:
          stringURL =
              "${Global.baseURL}search/show?query=$searchName&extended=full&page=$page";
          break;
        case TvTypes.similar:
          stringURL = '${Global.baseURL}shows/$id/related?extended=full';
          break;
        default:
          stringURL =
              "${Global.baseURL}shows/${tv!.toShortString()}?extended=full&page=$page&limit${15}";
          break;
      }
    }

    return stringURL;
  }

//responsible to get the json data from trakt
  Future<dynamic> _fetchData(String url, {Uri? uri}) async {
    Uri parsedURL = Uri.parse(url);
    if (uri != null) parsedURL = uri;
    try {
      final response = await http.get(
        parsedURL,
        headers: {
          'Content-Type': 'application/json',
          'trakt-api-version': '2',
          'trakt-api-key': Global.apiKey,
        },
      );

      //if ferch data is not found
      if (response.statusCode == 204) {
        return 'Nan';
      }

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
    final index = Global.isMovie() ? movieType!.index : showType!.index;
    //start incrementing the previous value
    currentPage[Global.dataType.index][index]++;

//prepare url and fetch data
    final url = _prepareURL(movieType, showType,
        page: currentPage[Global.dataType.index][index],
        genre: genre,
        searchName: searchName);
    try {
      final decodedData = await _fetchData(url);
      final results = decodedData as List<dynamic>;

      final data = _extractData(results, ctx);
      if (Global.isMovie())
        _movies[movieType!.index].addAll(data.cast<int>());
      else
        _tvShows[showType!.index].addAll(data.cast<int>());
    } catch (error) {
      print(error);
      throw HttpException(error.toString());
    }
    notifyListeners();
  }

//when preview page is opened. you fetch the cast by this method
  Future<List<People>?> fetchCast(int id, BuildContext ctx) async {
    final label = Global.isMovie() ? 'movies' : 'shows';
    final stringURL = Global.baseURL + "$label/$id/people";

    final decodedData;
    try {
      decodedData = await _fetchData(stringURL);
    } catch (error) {
      return null;
    }

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

  Future<List<int>> searchFor(String searchName, BuildContext ctx) async {
    final url =
        _prepareURL(MovieTypes.search, TvTypes.search, searchName: searchName);
    final response = await _fetchData(url);
    final results = response as List<dynamic>;
    List<int> _searchData = _extractData(results, ctx);
    if (Global.isMovie())
      _movies[MovieTypes.search.index] = _searchData;
    else
      _tvShows[TvTypes.search.index] = _searchData;
    return _searchData;
  }

  void clearShowCache(TvTypes type) {
    if (_tvShows[type.index].isNotEmpty) _tvShows[type.index].clear();
  }

  List<int> getShowsBy(TvTypes type) {
    if (_tvShows[type.index].isEmpty) return [];

    return [..._tvShows[type.index]];
  }

  Episode _extractEpisodesData(
    Map info,
    int showId,
    BuildContext ctx,
  ) {
    final int id = info['ids']['trakt'] ?? 0;
    final tmdbId = info['ids']['tmdb'] ?? -1;
    final num = info['number'] ?? -1;
    final season = info['season'] ?? 0;
    String name = info['title'] ?? 'Episode $num';
    name = name.isEmpty ? 'Episode $num' : name;
    final overview = info['overview'] ?? '-';
    final int rate = info['rate'] ?? 0;
    final String first_aired = info['first_aired'] ?? '0';
    final int year = int.parse(first_aired.split('-').first);
    final runTime = info['runtime'] ?? 0;
    fetchImage(
      showId,
      DataType.tvShow,
      ctx,
      season: season,
      episode: num,
      epsId: id,
    );
    return Episode(
      id,
      showId,
      name,
      overview,
      rate.toString(),
      first_aired,
      year,
      tmdbId,
      season,
      num,
      runTime,
    );
  }

  Future<void> fetchImage(int id, DataType type, BuildContext ctx,
      {int? season, int? seasonId, int? episode, int? epsId}) async {
    final tmdbID = dataDB[id]?.tmdb ?? -1;

    if (tmdbID != -1)
      Provider.of<PhotoProvider>(ctx, listen: false).fetchImagesFor(
          tmdbID, id, type,
          season: season, episode: episode, seasonId: seasonId, epsId: epsId);
  }

  Future<void> fetchSeasons(int id, BuildContext ctx, {int? season}) async {
    Show data = dataDB[id] as Show;

    String url = Global.baseURL + 'shows/$id/seasons';
    Uri uri = Uri.parse(url);
    List<dynamic> response;

    if (data.episodes == null) {
      response = await _fetchData(url, uri: uri) as List<dynamic>;
      data.episodes = {};

      response.forEach((item) {
        int num = item['number'] ?? -1;
        int seasonId = item['ids']['trakt'];
        if (num != 0) {
          data.episodes![num] = [];
          if (seasonIds[id] == null)
            seasonIds[id] = [seasonId];
          else
            seasonIds[id]!.add(seasonId);

          fetchImage(id, DataType.tvShow, ctx, season: num, seasonId: seasonId);
        }
      });
    }
    if (season != null) {
      if (data.episodes![season] == null || data.episodes![season]!.isEmpty) {
        url += '/$season?extended=full';
        uri = Uri.parse(url);

        response = await _fetchData(url, uri: uri) as List<dynamic>;
      
        response.forEach(
          (element) {
            Episode eps = _extractEpisodesData(element, id, ctx);
            data.episodes![season]!.add(eps);
          },
        );
      }
    }
  }

  Future<void> fetchSchedule() async {
    List<int> keys = tvSchedule.keys.toList();
    for (int key in keys) {
      if (tvSchedule[key]!.isEmpty) {
        final url = Global.baseURL + 'shows/$key/next_episode?extended=full';
        final parsedURL = Uri.parse(url);
        final response = await _fetchData(url, uri: parsedURL);

        if (response != 'Nan') {
          Map<String, Object> info = {
            'date': response['first_aired'],
            'season': response['season'],
            'number': response['number'],
            'name': response['title'],
            'title': dataDB[key]?.name ?? response['title'],
            'id': key,
            'epsId': response['ids']['trakt']
          };

          tvSchedule[key] = info;
        } else {
          tvSchedule.remove(key);
        }
      }
    }
  }

  Future<Track?> getLatestEpisode(int id) async {
    final url = Global.baseURL + 'shows/$id/last_episode';
    final response = await _fetchData(url, uri: Uri.parse(url));

    if (response != 'Nan') {
      final season = response['season'];
      final episode = response['number'];
      return Track(currentEp: episode, currentSeason: season);
    }
  }

  Future<List<int>> fetchMoviesSchedule(DateTime date, BuildContext ctx) async {
    if (movieSchedule[date] == null) {
      final formattedDate = DateFormat('yyyy-MM-dd').format(date);

      final url =
          'https://api.trakt.tv/calendars/all/movies/$formattedDate/1?extended=full';
      final response =
          await _fetchData(url, uri: Uri.parse(url)) as List<dynamic>;

      final data = _extractData(response, ctx);

      movieSchedule[date] = data;
    }

    return movieSchedule[date]!;
  }

  Future<List<String>> getVideosFor(int tmdbId, DataType type) async {
    final url =
        'https://api.themoviedb.org/3/${type.toShortString()}/$tmdbId/videos?api_key=dd5468d7aa41e016a24fa6bce058252d';
    final response = await http.get(Uri.parse(url));

    final results = json.decode(response.body);
    final data = results['results'];

    List<String> keys = [];
    data.forEach((element) {
      final String types = element['type'];

      if (types.contains('Trailer'))
        keys.insert(0, element['key']);
      else
        keys.add(element['key']);
    });

    return keys;
  }
}
