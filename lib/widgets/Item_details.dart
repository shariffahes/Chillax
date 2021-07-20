import 'package:discuss_it/models/providers/Movies.dart';
import 'package:flutter/material.dart';

class ItemDetails extends StatelessWidget {
  const ItemDetails();

  static const route = "/item_details";

  @override
  Widget build(BuildContext context) {
    final movie = ModalRoute.of(context)!.settings.arguments as Movie;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Container(
                color: Colors.white60,
                child: Text(
                  movie.name,
                ),
              ),
              background: Image.network(
                movie.backDropURL,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            Center(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  movie.overview,
                  style: TextStyle(
                      height: 1.7, fontSize: 16, fontWeight: FontWeight.w300),
                ),
              ),
            )
          ]))
        ],
      ),
    );
  }
}
