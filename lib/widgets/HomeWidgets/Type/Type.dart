import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import '../../../models/keys.dart';
import '../../../models/providers/Movies.dart';
import '../../../screens/list_all_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Type/PosterList.dart';

class Type extends StatelessWidget {
  final DiscoverTypes type;
  Type(this.type);

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            alignment: AlignmentDirectional.topStart,
            child: Text(
              type.toNormalString(),
              style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                ListAll.route,
                arguments: {
                  'type': type,
                },
              );
            },
            child: Text('View all'),
          ),
        ],
      ),
      FutureBuilder<MovieProvider>(
        future: Provider.of<MovieProvider>(context, listen: false)
            .fetchMovieListBy(type,context),
        builder: (_, snapshot) {
          if (snapshot.hasError)
            //replace by somthing better

            return Universal.failedWidget();
          if (snapshot.connectionState == ConnectionState.waiting)
            return Universal.loadingWidget();

          List<Movie> _movies = snapshot.data!.getMoviesBy(type);
          return Container(
            height: 340,
            child: PosterList(_movies),
          );
        },
      ),
    ]);
  }
}
