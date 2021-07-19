import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/category_list.dart';
import 'package:discuss_it/widgets/preview_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final listOfTitles = keys.discover;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // future: Provider.of<MovieProvider>(context, listen: false)
        //  .fetchMovieBy('popular'),
        builder: (ctx, snapshot) => SingleChildScrollView(
          child: Column(children: [
                Container(
                    height: MediaQuery.of(context).size.height * 0.30,
                    child: PreviewCard('Books', Icons.book)),
                ...listOfTitles
                    .map((type) => Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: CategoryList(type),
                        ))
                    .toList(),
              ]),
        ));
  }
}
