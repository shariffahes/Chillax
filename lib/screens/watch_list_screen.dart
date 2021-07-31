import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
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
  Widget build(BuildContext context) {
    keys.dataType = DataType.movie;
    final userProv = Provider.of<User>(context);
    Map<int, Movie> _watchList = userProv.movieWatchList;
    Map<int, Movie> _watchedList = userProv.watchedMovies;
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              "Your WatchList: ",
              style: TextStyle(
                fontSize: 22,
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
            Text(
              'Watch Again: ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 18,
            ),
            if (_watchedList.isEmpty)
              Center(
                child: Text('You still haven not watched any movies'),
              ),
            if (_watchedList.isNotEmpty)
              ...(_watchedList.values
                  .map((movie) => WatchList(movie, userProv))
                  .toList()),
          ],
        ),
      ),
    );
  }
}

class Shows extends StatelessWidget {
  Widget build(BuildContext context) {
    keys.dataType = DataType.tvShow;
    return SingleChildScrollView(
      child: Column(
        children: [
          Text(
            "Currently Watching",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "WatchList",
            style: TextStyle(
              fontSize: 22,
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
                  children: [
                    if (tvShows.isEmpty) Text('No added shows'),
                    if (tvShows.isNotEmpty)
                      ...tvShows.map((e) => WatchList(e, user)).toList(),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Currently Watching",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    if (watching.isEmpty) Text('Not watching any shows'),
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
    );
  }
}
