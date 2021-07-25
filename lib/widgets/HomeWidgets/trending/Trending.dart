import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class Trending extends StatefulWidget {
  final DiscoverTypes type;
  const Trending(this.type);

  @override
  _TrendingState createState() => _TrendingState();
}

class _TrendingState extends State<Trending> {
  List<Movie> _movies = [];

  var ind = 0;

  final AutoScrollController _controller = AutoScrollController();

  void _scrollToIndex(int index) async {
    await _controller.scrollToIndex(index,
        preferPosition: AutoScrollPosition.middle);
    setState(() {
      ind = index;
    });
  }

  @override
  void initState() {
    super.initState();

    Provider.of<MovieProvider>(context, listen: false)
        .fetchMovieListBy(widget.type)
        .then((value) {
      setState(() {
        _movies = value.getMoviesBy(widget.type);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var aspectRatio = AspectRatio(
      aspectRatio: 7 / 4,
      child: ListView.builder(
        controller: _controller,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) => AutoScrollTag(
          key: ValueKey(index),
          controller: _controller,
          index: index,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(PreviewItem.route, arguments: _movies[index]);
            },
            onHorizontalDragDown: (details) {
              _scrollToIndex((index + 1) % _movies.length);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(
                  12.0,
                ),
                image: DecorationImage(
                  image: NetworkImage(_movies[index].backDropURL),
                  fit: BoxFit.cover,
                ),
              ),
              margin: const EdgeInsets.all(5),
              height: 300,
              width: 360,
              child: Text(
                _movies[index].name,
                textAlign: TextAlign.start,
                style: TextStyle(
                  backgroundColor: Colors.white70,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        itemCount: _movies.length,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Trending',
            style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
          ),
        ),
        aspectRatio,
        SizedBox(
          height: 13,
        ),
        InfoRow(movies: _movies, ind: ind)
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    Key? key,
    required List<Movie> movies,
    required this.ind,
  }) : _movies = movies, super(key: key);

  final List<Movie> _movies;
  final int ind;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        icons(
          Icons.star_outline,
          (_movies.isNotEmpty ? '${_movies[ind].rate}' : '-'),
        ),
        icons(Icons.calendar_today_outlined,
            (_movies.isNotEmpty ? _movies[ind].releaseDate : '-')),
        icons(Icons.timer_outlined, '02:12:20'),
        icons(
          Icons.language,
          (_movies.isNotEmpty ? _movies[ind].language : '-'),
        ),
      ],
    );
  }
}

class icons extends StatelessWidget {
  final IconData icon;
  final String value;
  const icons(this.icon, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 44,
          color: Colors.red,
        ),
        Text(value),
      ],
    );
  }
}
