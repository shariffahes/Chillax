import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:flutter/material.dart';

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
                  leading: Image.network(movie.posterURL),
                  title: Text(movie.name),
                  subtitle: Text(keys.reformData(movie.releaseDate.toString())),
                ))
            .toList(),
      ),
    );
  }
}
