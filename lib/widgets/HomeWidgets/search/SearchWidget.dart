import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/HomeWidgets/search/SearchList.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatelessWidget {
  void _searchForResults(BuildContext ctx, String input) {
    showModalBottomSheet(
        elevation: 4,
        shape: Universal.roundedShape(15.0),
        context: ctx,
        builder: (_) => FutureBuilder<List<Movie>>(
            future:
                Provider.of<MovieProvider>(ctx, listen: false).searchFor(input,ctx),
            builder: (_, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return Universal.loadingWidget();

              if (snapshot.hasError) return Universal.failedWidget();

              final results = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Icon(Icons.space_bar_outlined),
                    ),
                    SearchLists(results),
                  ],
                ),
              );
            }));
  }

  final _fieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: _fieldController,
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
          _fieldController.clear();
        },
      ),
    );
  }
}
