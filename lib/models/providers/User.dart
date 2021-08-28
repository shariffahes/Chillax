import 'dart:async';
import 'dart:convert';
import 'package:discuss_it/main.dart';
import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Track {
  late int currentEp;
  late int currentSeason;
  late int nextEp;
  late int nextSeason;
  Track(
      {this.currentEp = 0,
      this.currentSeason = 0,
      this.nextEp = 0,
      this.nextSeason = 0});
}

class User with ChangeNotifier {
  Map<int, Movie> _movieWatchList = {};
  Map<int, Movie> _movieWatched = {};
  Map<int, Show> _tvWatchList = {};
  Map<int, Show> _tvWatched = {};
  List<Show> _watching = [];
  Map<int, Track> track = {};

  User() {
    if (!Global.isMovieSet)
      Global.getMovieFromLocalDB(
          setMovieWL: setMovieWatchList, setMovieWatched: setMovieWatchedList);
    if (!Global.isShowSet)
      Global.getShowFromLocalDB(
          setShowWL: setTvWatchList,
          setShowWatched: setTvWatchedList,
          setTrack: setTrack,
          setWatching: setWatching);
  }

  //this used in get schedule to indicate if there is any changes which require rebuild;
  bool isChange = false;

  void addToWatchList(Object item) {
    isChange = true;
    //check if movie or show / add to watch list and update sql.
    if (item is Movie) {
      _movieWatchList[item.id] = item;
      _add(item);
    } else if (item is Show) {
      _tvWatchList[item.id] = item;
      _add(item);
    } else if (item is Episode) {
      //episode extract the show from data base
      Show show = DataProvider.dataDB[item.id]! as Show;
      addToWatchList(show);
    }
    notifyListeners();
  }

//start watching a series
  void startWatching(int id, {int episode = 1, int season = 1}) {
    isChange = true;
    // add to watching / update in sql to -1 and update episodes / remove from wl
    _watching.add(DataProvider.dataDB[id] as Show);
    track[id] = Track(currentEp: episode, currentSeason: season);
    _updateEpisode(id, episode, season);
    _update(id, -1, DataType.tvShow);
    _tvWatchList.remove(id);
    _tvWatched.remove(id);
    
    mapShowToUser(id);
    notifyListeners();
  }

//watch complete toggle for movie or show
  void watchComplete(int id) {
    if (Global.isMovie()) {
      //if id exists in watched then move it to watch list otherwise remove it
      if (_movieWatched[id] != null) {
        final item = _movieWatched[id];
        _movieWatched.remove(id);
        _movieWatchList[id] = item!;
        _update(id, 0, DataType.movie);
      } else {
        _movieWatched[id] = _movieWatchList[id]!;
        _movieWatchList.remove(id);
        _update(id, 1, DataType.movie);
      }
    } else {
      if (_tvWatched[id] != null) {
        final item = _tvWatched[id];
        _tvWatched.remove(id);
        _tvWatchList[id] = item!;
        DataProvider.tvSchedule.remove(id);
        _update(id, 0, DataType.tvShow);
      } else if (_tvWatchList[id] != null) {
        _tvWatched[id] = _tvWatchList[id]!;
        _tvWatchList.remove(id); 
        mapShowToUser(id);
        DataProvider().getLatestEpisode(id).then((trak) {
          if (trak != null) {
            _update(id, 1, DataType.tvShow);
            _updateEpisode(id, trak.currentEp + 1, trak.currentSeason);
            track[id] = Track(
                currentEp: trak.currentEp + 1,
                currentSeason: trak.currentSeason);
          }
        });
      } else {
        //if currently watching move to next episode
        final nextEp = track[id]!.nextEp;
        final nextSeason = track[id]!.nextSeason;
        track[id]!.currentEp = nextEp;
        track[id]!.currentSeason = nextSeason;
        _updateEpisode(id, nextEp, nextSeason);
        return;
      }
    }
    notifyListeners();
  }

//delete item called when swipe the card in watch list screen
  void deleteItem(int id) {
    isChange = true;
    //delete data from everywhere
    if (Global.isMovie()) {
      _movieWatched.remove(id);
      _movieWatchList.remove(id);
      _delete(id, DataType.movie);
    } else {
      print(id);
      _tvWatched.remove(id);
      _watching.removeWhere((element) => element.id == id);
      _tvWatchList.remove(id);
      DataProvider.tvSchedule.remove(id);
      removeUserFromWatchers(id);
      _delete(id, DataType.tvShow);
    }
    notifyListeners();
  }

//helper methods

  void completeShow(int id) {
    Show show = _watching.firstWhere((element) => element.id == id);
    _tvWatched[id] = show;
    _watching.remove(show);
    notifyListeners();
    _update(id, 1, DataType.tvShow);
  }

  Future<Episode?> getEpisodeInfo(
    int id,
    BuildContext ctx, {
    int? season,
    int? episode,
  }) async {
    List<int> current = _getNext(id);
    season = season ?? current[1];
    episode = episode ?? current[0];

    _updateNext(id, season, episode + 1);

    Show show = DataProvider.dataDB[id] as Show;

    episode = episode - 1;
    if (show.episodes == null) {
      await Provider.of<DataProvider>(ctx, listen: false).fetchSeasons(
        id,
        ctx,
        season: season,
      );
    }
    final _seriesEpisodes = show.episodes!;

    if (season > _seriesEpisodes.keys.length) {
      return null;
    }

    if (_seriesEpisodes[season]!.isEmpty) {
      await Provider.of<DataProvider>(ctx, listen: false)
          .fetchSeasons(id, ctx, season: season);
    }

    if (episode >= _seriesEpisodes[season]!.length) {
      return getEpisodeInfo(
        id,
        ctx,
        season: season + 1,
        episode: 1,
      );
    }

    DateTime date =
        DateTime.parse(_seriesEpisodes[season]![episode].releasedDate)
            .toLocal();
    if (date.isAfter(DateTime.now())) {
      return null;
    }

    return _seriesEpisodes[season]![episode];
  }

  List<int> _getNext(int id) {
    if (track[id] == null) return [1, 1];
    return [track[id]!.currentEp, track[id]!.currentSeason];
  }

  void _updateNext(int id, int season, int episode) {
    if (track[id] == null) {
      track[id] = Track(
          currentEp: 1, currentSeason: 1, nextEp: episode, nextSeason: season);
    } else {
      track[id]!.nextSeason = season;
      track[id]!.nextEp = episode;
    }
  }

  void removeFromWatchList(int id) {
    isChange = true;
    if (Global.isMovie()) {
      _movieWatchList.remove(id);
      _delete(id, DataType.movie);
    } else {
      _tvWatchList.remove(id);
      _delete(id, DataType.tvShow);
    }
    notifyListeners();
  }

  void removeFromWatched(int id) {
    isChange = true;
    removeUserFromWatchers(id);
    if (Global.isMovie()) {
      _movieWatched.remove(id);
      _delete(id, DataType.movie);
    } else {
      _tvWatched.remove(id);
      _delete(id, DataType.tvShow);
    }
    notifyListeners();
  }

  void removeFromWatching(int id) {
    isChange = true;
    removeUserFromWatchers(id);
    _watching.removeWhere((element) => element.id == id);
    _delete(id, DataType.tvShow);

    notifyListeners();
  }

  Map<int, Data> watchingtoMap() {
    Map<int, Data> map = {};

    _watching.forEach((element) {
      map[element.id] = element;
    });
    return map;
  }

  Status getStatus(int id) {
    if (_movieWatchList[id] != null || _tvWatchList[id] != null)
      return Status.watchList;
    else if (_movieWatched[id] != null || _tvWatched[id] != null)
      return Status.watched;
    else if (isWatching(id)) return Status.watching;
    return Status.none;
  }

  void mapShowToUser(int id) {
    print(id);
    Uri url = Uri.parse(
        'https://chillax-4c80c-default-rtdb.firebaseio.com/shows/$id.json');
    http.get(url).then((response) async {
      final decodeData = json.decode(response.body);
      List<String> watchers = [];
      String? flag;
      if (decodeData == null) {
        final stringURL =
            Global.baseURL + 'shows/$id/next_episode?extended=full';
        url = Uri.parse(stringURL);
        final response = await DataProvider().fetchData(stringURL, uri: url);
        if (response != 'Nan') {
          flag = response['first_aired'];
        }
      } else if (decodeData['watchers'] != null) {
        decodeData['watchers'] as List<dynamic>;
        watchers = decodeData['watchers'].cast<String>();

        print(watchers);
      }
      watchers.add(Global.key!);
      Map content = {'watchers': watchers};
      if (flag != null) content['flag'] = flag;
      if (flag != null || decodeData['flag'] != null) {
        DataProvider.tvSchedule[id] = {};
        var f = flag ?? decodeData['flag'];
        url = Uri.parse(
            'https://chillax-4c80c-default-rtdb.firebaseio.com/schedule/${Global.key}/$id.json');
        http.patch(url, body: json.encode({'flag': f}));
      }
      url = Uri.parse(
          'https://chillax-4c80c-default-rtdb.firebaseio.com/shows/$id.json');
      http.patch(url, body: json.encode(content));
    });
  }

  void removeUserFromWatchers(int id) {
    print(id);
    Uri url = Uri.parse(
        'https://chillax-4c80c-default-rtdb.firebaseio.com/shows/$id/watchers.json');

    http.get(url).then((response) {
      final decodedData = json.decode(response.body);

      if (decodedData != null) {
        final watchers = (decodedData as List<dynamic>).cast<String>();

        if (watchers.contains(Global.key)) {
          watchers.remove(Global.key);
          url = Uri.parse(
              'https://chillax-4c80c-default-rtdb.firebaseio.com/shows/$id.json');
          http.patch(url, body: json.encode({'watchers': watchers}));
        }
      }
    });

    url = Uri.parse(
        'https://chillax-4c80c-default-rtdb.firebaseio.com/schedule/${Global.key}/$id.json');
    http.delete(url);
  }

//OPTIMIZE SEARCH!!
  bool isWatching(int id) {
    for (var show in _watching) {
      if (show.id == id) return true;
    }
    return false;
  }

//sql methods

  void _updateEpisode(int id, int nextEps, int nextSeason) async {
    await MyApp.db!.update(
        'ShowWatch', {'currentEps': nextEps, 'currentSeason': nextSeason},
        where: 'id = $id');
  }

  void _add(Data data) async {
    if (data is Movie) {
      await MyApp.db!.transaction((txn) async {
        await txn.insert('MovieWatch', data.toMap());
      });
    } else {
      Show show = data as Show;
      await MyApp.db!.transaction((txn) async {
        await txn.insert('ShowWatch', show.toMap());
      });
    }
  }

  void _update(int id, int value, DataType type) async {
    if (type == DataType.movie)
      await MyApp.db!
          .update('MovieWatch', {'watched': value}, where: 'id = $id');
    else
      await MyApp.db!
          .update('ShowWatch', {'watched': value}, where: 'id = $id');
  }

  void _delete(int id, DataType type) async {
    if (type == DataType.movie)
      await MyApp.db!.delete('MovieWatch', where: 'id = $id');
    else
      await MyApp.db!.delete('ShowWatch', where: 'id = $id ');
  }

//getters
  Map<int, Movie> get movieWatchList {
    return {..._movieWatchList};
  }

  Map<int, Movie> get watchedMovies {
    return {..._movieWatched};
  }

  Map<int, Show> get showWatchList {
    return {..._tvWatchList};
  }

  Map<int, Show> get watchedShows {
    return {..._tvWatched};
  }

  List<Show> getCurrentlyWatching() {
    return [..._watching];
  }

//setters
  void setMovieWatchList(Map<int, Movie> movieWl) {
    _movieWatchList = {...movieWl};
    notifyListeners();
  }

  void setMovieWatchedList(Map<int, Movie> watched) {
    _movieWatched = {...watched};
    notifyListeners();
  }

  void setTvWatchList(Map<int, Show> tvWL) {
    _tvWatchList = {...tvWL};
    notifyListeners();
  }

  void setTvWatchedList(Map<int, Show> tvWatched) {
    _tvWatched = {...tvWatched};
    notifyListeners();
  }

  void setTrack(Map<int, Track> trak) {
    track = {...trak};
    notifyListeners();
  }

  void setWatching(List<Show> wtching) {
    _watching = [...wtching];
    notifyListeners();
  }

  void checkLatest(Track trak, int id) {
    if (track[id]!.currentEp == trak.currentEp ||
        track[id]!.currentSeason > trak.currentSeason) {
      startWatching(id, episode: trak.currentEp, season: trak.currentSeason);
    }
  }
}
