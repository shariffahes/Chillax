import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/keys.dart';
import '../models/providers/Movies.dart';
import '../widgets/item_view.dart';
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
        Provider.of<MovieProvider>(context, listen: true);
    List<Movie> _movies = _movieProvider.getMoviesBy(
      type,
    );

    Future<void> load() async {
      await _movieProvider.loadMore(type, genre: keys.genres[genre] ?? null);
      _controller.loadComplete();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(type.toShortString()),
      ),
      body: FutureBuilder<List<Movie>>(
        future: (genre != null ? _movieProvider.fetchMovieBy(genre) : null),
        builder: (_, snapshot) {
          if (snapshot.hasError) return Text('An error has occured :(');
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          _movies = !snapshot.hasData ? _movies : snapshot.data as List<Movie>;
          return SmartRefresher(
            enablePullDown: false,
            footer: CustomFooter(
              builder: (_, state) {
                Widget body;
                switch (state) {
                  case LoadStatus.idle:
                    body = Icon(Icons.arrow_upward);
                    break;
                  case LoadStatus.loading:
                    body = CircularProgressIndicator();
                    break;
                  case LoadStatus.failed:
                    body = Text('Failed');
                    break;
                  default:
                    body = Icon(Icons.refresh);
                    break;
                }
                return Center(
                  child: body,
                );
              },
            ),
            enablePullUp: true,
            controller: _controller,
            onLoading: load,
            child: ListView.builder(
              padding: const EdgeInsets.all(10),
              itemBuilder: (ctx, index) {
                return Center(
                  child: ItemList(_movies[index]), //_presentPopUp),
                );
              },
              itemCount: _movies.length,
            ),
          );
        },
      ),
    );
  }
}
