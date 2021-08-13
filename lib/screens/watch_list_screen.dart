import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
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

  Widget createListView(List<Data> data, User userProv) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 56.0),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (ctx, index) => WatchListCard(data[index], userProv)),
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
                setTitle('Movie WatchList'),
                createListView(_watchList, userProv),
                setTitle('Watch Again'),
                createListView(_watchedList, userProv),
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

  Widget createListView(List<Data> data, User userProv) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 56.0),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        child: ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: data.length,
            itemBuilder: (ctx, index) => WatchListCard(data[index], userProv)),
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
          if (snapshot.hasError) return Universal.failedWidget();

          return SingleChildScrollView(
            child: Consumer<User>(builder: (_, userProv, __) {
              List<Show> shows = userProv.getCurrentlyWatching();
              List<Show> watchList = userProv.showWatchList.values.toList();
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  setTitle('Currently Watching'),
                  createListView(shows, userProv),
                  setTitle('WatchList'),
                  createListView(watchList, userProv),
                ],
              );
            }),
          );
        });
  }
}
