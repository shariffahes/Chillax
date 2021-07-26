import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/People.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ItemDetails extends StatelessWidget {
  
  List<People> _movieCast = [];

  @override
  Widget build(BuildContext context) {
    final movie = ModalRoute.of(context)!.settings.arguments as Movie;
    Provider.of<MovieProvider>(context, listen: false)
        .fetchCast(movie.id)
        .then((value) => _movieCast = value);

    Future<void> _populateCast() async {
      _movieCast = await Provider.of<MovieProvider>(context, listen: false)
          .fetchCast(movie.id);
    }

    return Scaffold(
      body: FutureBuilder(
        future: _populateCast(),
        builder: (ctx, snapshot) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Image.network(
                  movie.backDropURL,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Center(
                    child: Text(
                      movie.name,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                      child: CircleAvatar(
                    maxRadius: 30,
                    child: Center(
                      child: Text(
                        '${movie.rate}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )),
                  InfoRow(movie.releaseDate, movie.language),
                  Divider(
                    thickness: 2,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Subtitles('Story Line'),
                  ),
                  Padding(padding: const EdgeInsets.all(8.0)),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        movie.overview,
                        style: TextStyle(
                            height: 1.7,
                            fontSize: 16,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  Subtitles('Cast'),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _movieCast
                          .map((e) => Padding(
                                padding: const EdgeInsets.only(bottom: 17.0),
                                child: Actor(e.name, e.profileURL, e.character),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Subtitles extends StatelessWidget {
  final title;
  const Subtitles(this.title);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String date;
  final String lan;
  InfoRow(this.date, this.lan);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ColumnInfo('Length', '02:12:11'),
          ColumnInfo('Language', lan),
          ColumnInfo(
            'Year',
            date == '-'
                ? date
                : DateFormat("yyyy").format(
                    DateTime.parse(date),
                  ),
          ),
        ],
      ),
    );
  }
}

class ColumnInfo extends StatelessWidget {
  final title;
  final value;
  const ColumnInfo(
    this.title,
    this.value,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}

class Actor extends StatelessWidget {
  final String name;
  final String profileURL;
  final String character;
  @override
  Actor(this.name, this.profileURL, this.character);

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(profileURL),
            child: Container(),
          ),
          Text(name),
          Text(character),
        ],
      ),
    );
  }
}
