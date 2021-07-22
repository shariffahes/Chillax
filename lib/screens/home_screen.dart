import '../models/keys.dart';
import '../models/providers/Movies.dart';
import '../widgets/HomeWidgets/Type/Type.dart';
import '../widgets/HomeWidgets/genre/Genre.dart';
import '../widgets/HomeWidgets/trending/Trending.dart';
import '../widgets/Item_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<DiscoverTypes> listOfTitles =
      DiscoverTypes.values.skip(keys.mainList).toList();

//optimize search in another widget to clean
  void _searchForResults(BuildContext ctx, String input) async {
    showModalBottomSheet(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        context: ctx,
        builder: (_) => FutureBuilder<List<Movie>>(
            future: Provider.of<MovieProvider>(context, listen: false)
                .searchFor(input),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Center(
                  child: CircularProgressIndicator(),
                );

              if (snapshot.hasError)
                return Center(child: Text('No results to show :('));

              final results = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Icon(Icons.space_bar_outlined),
                    ),
                    Container(
                      height: 400,
                      child: ListView(
                        children: results
                            .map((movie) => ListTile(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                        ItemDetails.route,
                                        arguments: movie);
                                  },
                                  leading: Image.network(movie.posterURL),
                                  title: Text(movie.name),
                                  subtitle:
                                      Text(keys.reformData(movie.releaseDate)),
                                ))
                            .toList(),
                      ),
                    )
                  ],
                ),
              );
            }));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search_sharp,
                size: 30,
              ),
              labelText: 'Search for a movie, show, or people ...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onFieldSubmitted: (input) {
              _searchForResults(context, input);
            },
          ),
        ),
        Trending(DiscoverTypes.trending),
        Genre(DiscoverTypes.genre),
        ...listOfTitles.map((type) => Type(type)).toList(),
      ]),
    );
  }
}
