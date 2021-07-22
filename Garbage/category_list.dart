import 'package:discuss_it/models/providers/Movies.dart';
import '../lib/models/keys.dart';
import '../lib/models/providers/Movies.dart' as m;
import '../lib/screens/list_all_screen.dart';
import '../lib/widgets/Item_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'poster_item.dart';

class CategoryList extends StatelessWidget {
  final DiscoverTypes type;
  CategoryList(this.type);
  List<m.Movie> _movies = [];
  Future<void> fetchMovies(BuildContext ctx) async {
    m.MovieProvider movieProvider =
        Provider.of<m.MovieProvider>(ctx, listen: false);

    await movieProvider.fetchMovieListBy(type);
    _movies = movieProvider.getMoviesBy(type);
  }

  void _presentPopUp(BuildContext ctx, m.Movie movie) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        titlePadding: const EdgeInsets.only(top: 0, right: 0, left: 0),
        title: Stack(
          children: [
            Image.network(
              movie.backDropURL,
              colorBlendMode: BlendMode.darken,
              color: Colors.black26,
            ),
            Container(
              color: Colors.white60,
              padding: const EdgeInsets.all(6.0),
              child: Text(
                movie.name,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              bottom: 2,
              child: Text(
                '2020-08-08',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(movie.overview),
          ]),
        ),
        actions: [
          Container(
            margin: EdgeInsets.zero,
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pushReplacementNamed(ItemDetails.route,
                      arguments: movie);
                },
                child: Text('See more')),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchMovies(context),
      builder: (_, snapshot) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type.toShortString(),
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(ListAll.route, arguments: {
                        'type': type,
                        'method': _presentPopUp,
                      });
                    },
                    child: Text('See all'),
                  ),
                ],
              ),
            ),
            Container(
              //fix later to box constraint
              height: 270,
              child: ListView(
                clipBehavior: Clip.none,
                children: _movies
                    .map((movie) => PosterItem(movie, 5 / 7, _presentPopUp))
                    .toList(),
                scrollDirection: Axis.horizontal,
              ),
            ),
            SizedBox(height: 10),
            Divider(
              thickness: 2,
            ),
          ],
        );
      },
    );
  }
}
