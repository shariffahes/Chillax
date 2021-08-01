import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchLists extends StatelessWidget {
  final List<Movie> results;
  const SearchLists(this.results);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.5,
      child: ListView(
        children: results
            .map((movie) => ListTile(
                  onTap: () {
                    Navigator.of(context)
                        .pushNamed(PreviewItem.route, arguments: movie);
                  },
                  leading: Consumer<PhotoProvider>(
                    builder: (ctx, image, _) {
                      final poster =
                          image.getMovieImages(movie.id) ?? [keys.defaultImage];
                      return Image.network(poster[0]);
                    },
                  ),
                  title: Text(movie.name),
                  subtitle: Text(movie.yearOfRelease.toString()),
                ))
            .toList(),
      ),
    );
  }
}
