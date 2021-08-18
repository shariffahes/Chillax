import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:discuss_it/widgets/WatchList/WatchListCard.dart';
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
  Widget setTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget createListView(List<Data> data, User userProv, BuildContext ctx) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 56.0),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (ctx, index) => GestureDetector(
                onTap: () {
                  Navigator.of(ctx)
                      .pushNamed(PreviewItem.route, arguments: data[index]);
                },
                child: WatchListCard(data[index], userProv))),
      ),
    );
  }

  Widget build(BuildContext context) {
    Global.dataType = DataType.movie;

    return FutureBuilder<void>(
      future:
          Global.isMovieSet ? null : Global.getMovieFromLocalDB(ctx: context),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Universal.loadingWidget();
        if (snapshot.hasError) return Universal.failedWidget();

        return SingleChildScrollView(
          child: Consumer<User>(builder: (ctx, userProv, _) {
            List<Movie> _watchList = userProv.movieWatchList.values.toList();
            List<Movie> _watchedList = userProv.watchedMovies.values.toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_watchList.isNotEmpty) setTitle('Movie WatchList'),
                createListView(_watchList, userProv, context),
                if (_watchedList.isNotEmpty) setTitle('Watch Again'),
                createListView(_watchedList, userProv, context),
              ],
            );
          }),
        );
      },
    );
  }
}

class Shows extends StatelessWidget {
  Widget setTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget createListView(List<Data> data, User userProv, BuildContext ctx) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 56.0),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (ctx, index) => GestureDetector(
                onTap: () {
                  Navigator.of(ctx)
                      .pushNamed(PreviewItem.route, arguments: data[index]);
                },
                child: WatchListCard(data[index], userProv))),
      ),
    );
  }

  Widget build(BuildContext context) {
    Global.dataType = DataType.tvShow;
    return FutureBuilder<void>(
        future:
            Global.isShowSet ? null : Global.getShowFromLocalDB(ctx: context),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Universal.loadingWidget();
          if (snapshot.hasError) {
            print('er: ${snapshot.error}');
            return Universal.failedWidget();
          }

          if (!Global.isMovie()) {
            User userProv = Provider.of<User>(context, listen: false);
            List<Show> watched = userProv.watchedShows.values.toList();

            watched.forEach((show) {
              Provider.of<DataProvider>(context, listen: false)
                  .getLatestEpisode(show.id)
                  .then((track) => track != null
                      ? userProv.checkLatest(track, show.id)
                      : null);
            });
          }

          return SingleChildScrollView(
            child: Consumer<User>(builder: (_, userProv, __) {
              List<Show> shows = userProv.getCurrentlyWatching();
              List<Show> watchList = userProv.showWatchList.values.toList();

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (shows.isNotEmpty) setTitle('Currently Watching'),
                  createListView(shows, userProv, context),
                  if (watchList.isNotEmpty) setTitle('WatchList'),
                  createListView(watchList, userProv, context),
                ],
              );
            }),
          );
        });
  }
}
