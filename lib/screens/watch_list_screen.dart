import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
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
    List<Movie> _watchList = Provider.of<User>(context).watchList;
    return _watchList.isEmpty
        ? Center(
            child: Text('No added movies'),
          )
        : ListView(
            children: _watchList
                .map((movie) => ListTile(
                      title: Text(movie.name),
                      subtitle: Text(movie.releaseDate),
                      leading: Image.network(movie.posterURL),
                    ))
                .toList(),
          );
  }
}

class Shows extends StatelessWidget {
  Widget build(BuildContext context) {
    return Center(child: Text('Shows'));
  }
}
