import 'package:discuss_it/main.dart';
import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:discuss_it/widgets/WatchList/WatchList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchListScreen extends StatelessWidget {
  const WatchListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        Movies(),
        Shows(),
      ],
    );
  }
}

class Movies extends StatelessWidget {
  Future<List<Map<int, Movie>>> getMovieFromLocalDB() async {
    var info = await MyApp.db!.query('MovieWatch', where: 'watched = ${0}');
    Map<int, Movie> wl = {};
    info.forEach((movie) {
      int id = movie['id'] as int;
      wl[id] = Movie.fromMap(movie);
    });
    Map<int, Movie> watched = {};
    info = await MyApp.db!.query('MovieWatch', where: 'watched=${1}');
    info.forEach((movie) {
      int id = movie['id'] as int;
      watched[id] = Movie.fromMap(movie);
    });

    return [wl, watched];
  }

  Widget build(BuildContext context) {
    Global.dataType = DataType.movie;

    return FutureBuilder<List<Map<int, Movie>>>(
      future: getMovieFromLocalDB(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Universal.loadingWidget();
        if (snapshot.hasError || !snapshot.hasData)
          return Universal.failedWidget();

        final user = Provider.of<User>(context, listen: false);
        user.setMovieWatchList(snapshot.data![0]);
        user.setMovieWatchedList(snapshot.data![1]);
        return Consumer<User>(
          builder: (ctx, userProv, _) {
            Map<int, Movie> _watchList = userProv.movieWatchList;
            Map<int, Movie> _watchedList = userProv.watchedMovies;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Movies WatchList ",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    if (_watchList.isEmpty)
                      Center(
                        child: Text('No movies added to Watch List'),
                      ),
                    if (_watchList.isNotEmpty)
                      ...(_watchList.values
                          .map((movie) => WatchList(movie, userProv))
                          .toList()),
                    SizedBox(
                      height: 18,
                    ),
                    if (_watchedList.isNotEmpty)
                      WatchedList(_watchedList, userProv),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class Shows extends StatelessWidget {
  Map<int, Track> track = {};
  List<Show> currWatching = [];
  Future<List<Map<int, Show>>> getShowFromLocalDB() async {

    var info = await MyApp.db!.query('ShowWatch', where: 'watched = ${0}');
    Map<int, Show> wl = {};
    info.forEach((show) {
      int id = show['id'] as int;
      wl[id] = Show.fromMap(show);
    });
    Map<int, Show> watched = {};
    info = await MyApp.db!.query('ShowWatch', where: 'watched=${1}');
    info.forEach((show) {
      int id = show['id'] as int;
      watched[id] = Show.fromMap(show);
    });

    info = await MyApp.db!.query('ShowWatch', where: 'watched=${-1}');
    info.forEach((element) {
      final int id = element['id'] as int;
      final int episode = element['currentEps'] as int;
      final int season = element['currentSeason'] as int;
      track[id] = Track(currentEp: episode, currentSeason: season);
      currWatching.add(Show.fromMap(element));
    });

    return [wl, watched];
  }

  Widget build(BuildContext context) {
    Global.dataType = DataType.tvShow;
    return FutureBuilder<List<Map<int, Show>>>(
        future: getShowFromLocalDB(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Universal.loadingWidget();
          if (snapshot.hasError || !snapshot.hasData)
            return Universal.failedWidget();
          final user = Provider.of<User>(context, listen: false);
          user.setTvWatchList(snapshot.data![0]);
          user.setTvWatchedList(snapshot.data![1]);
          user.setTrack(track);
          user.setWatching(currWatching);

          return SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Shows WatchList",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Consumer<User>(
                  builder: (_, user, __) {
                    List<Show> tvShows = user.showWatchList.values.toList();
                    List<Show> watching = user.getCurrentlyWatching();

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (tvShows.isEmpty) Text('No added shows'),
                          if (tvShows.isNotEmpty)
                            ...tvShows.map((e) => WatchList(e, user)).toList(),
                          SizedBox(
                            height: 20,
                          ),
                          if (watching.isNotEmpty)
                            Text(
                              "Currently Watching",
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          if (watching.isNotEmpty)
                            ...watching
                                .map((e) => WatchList(
                                      e,
                                      user,
                                      isWatching: true,
                                    ))
                                .toList(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ));
        });
  }
}

class WatchedList extends StatelessWidget {
  final Map<int, Movie> watchedList;
  final User userProv;
  const WatchedList(this.watchedList, this.userProv);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Watch Again ",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: 18,
        ),
        if (watchedList.isNotEmpty)
          ...(watchedList.values
              .map((movie) => WatchList(movie, userProv))
              .toList()),
      ],
    );
  }
}
