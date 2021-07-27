import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/screens/list_all_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchWidget extends StatelessWidget {
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
          if (input.isNotEmpty)
            Navigator.of(context).pushNamed(ListAll.route, arguments: {
              'type': DiscoverTypes.search,
              'text': input,
            }).then((v) {
              Provider.of<MovieProvider>(context, listen: false)
                  .clearCache(DiscoverTypes.search);
            });
          _fieldController.clear();
        },
      ),
    );
  }
}
