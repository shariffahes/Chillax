import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/screens/list_all_screen.dart';
import 'package:discuss_it/widgets/Item_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryList extends StatelessWidget {
  final String type;
  CategoryList(this.type);
  List<Movie> _movies = [];
  Future<void> fetchMovies(BuildContext ctx) async {
    MovieProvider movieProvider =
        Provider.of<MovieProvider>(ctx, listen: false);

    await movieProvider.fetchMovieBy(type);
    _movies = movieProvider.getMoviesBy(type);
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
                    type,
                    style: TextStyle(fontSize: 25),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(ListAll.route, arguments: type);
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
                children:
                    _movies.map((movie) => ItemList(movie, 5 / 7)).toList(),
                scrollDirection: Axis.horizontal,
              ),
            ),
            Divider(
              thickness: 2,
            ),
          ],
        );
      },
    );
  }
}
