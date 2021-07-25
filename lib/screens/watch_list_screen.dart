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
    final userProv = Provider.of<User>(context);
    Map<int, Movie> _watchList = userProv.watchList;
    Map<int, Movie> _watchedList = userProv.watched;
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
    return Center(child: Text('Shows'));
  }
}
