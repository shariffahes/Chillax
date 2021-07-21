import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/Item_details.dart';
import 'package:discuss_it/widgets/category_list.dart';
import 'package:discuss_it/widgets/preview_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<DiscoverTypes> listOfTitles = DiscoverTypes.values;

  void _searchForResults(BuildContext ctx, List<Map<String, Object>> results) {
    showBottomSheet(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      context: ctx,
      builder: (_) => Padding(
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
                    .map((e) => ListTile(
                          onTap: () async {
                            final movie = await Provider.of<MovieProvider>(
                                    context,
                                    listen: false)
                                .fetchDetails(e['id'] as int);
                            Navigator.of(context).pushNamed(ItemDetails.route,arguments: movie);
                          },
                          leading: Image.network(e['poster'] as String),
                          title: Text(e['name'] as String),
                        ))
                    .toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        // future: Provider.of<MovieProvider>(context, listen: false)
        //  .fetchMovieBy('popular'),
        builder: (ctx, snapshot) => SingleChildScrollView(
              child: Column(children: [
                Form(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onFieldSubmitted: (input) async {
                      final result = await Provider.of<MovieProvider>(context,
                              listen: false)
                          .searchFor(input);
                      _searchForResults(ctx, result);
                    },
                    decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        labelText: 'Search for movie, show, or person ...'),
                  ),
                )),
                Container(
                    height: MediaQuery.of(context).size.height * 0.30,
                    child: PreviewCard('Movies', Icons.tv_rounded)),
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
