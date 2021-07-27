import 'package:discuss_it/widgets/ListWidget/ListItems.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/keys.dart';
import '../models/providers/Movies.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ListAll extends StatelessWidget {
  static const route = "/list_all_screen";
  final _controller = RefreshController();
  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final DiscoverTypes type = data['type'];
    final String? genre = data['genre'] ?? null;

    MovieProvider _movieProvider =
        Provider.of<MovieProvider>(context, listen: false);
    List<Movie> _movies = _movieProvider.getMoviesBy(
      type,
    );

    Future<void> load() async {
      await _movieProvider.loadMore(type,context, genre: genre ?? null);
      _controller.loadComplete();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(type.toShortString()),
      ),
      body: FutureBuilder<List<Movie>>(
        future: (genre != null ? _movieProvider.fetchMovieBy(genre,context) : null),
        builder: (_, snapshot) {
          print(snapshot.error);
          if (snapshot.hasError) return Text('An error has occured :(');

          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          // _movies = !snapshot.hasData ? _movies : snapshot.data as List<Movie>;
          return Consumer<MovieProvider>(
            builder: (_, prov, __) {
              _movies = prov.getMoviesBy(type);
              return ListItems(_movies, _controller, load);
            },
          );
        },
      ),
    );
  }
}
