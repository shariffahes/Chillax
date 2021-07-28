import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class Trending extends StatefulWidget {
  final MovieTypes type;
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

    Provider.of<DataProvider>(context, listen: false)
        .fetchMovieListBy(widget.type,context)
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
      child: _movies.isEmpty
          ? ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(
                      12.0,
                    ),
                  ),
                  margin: const EdgeInsets.all(5),
                  height: 300,
                  width: 360,
                ),
              ],
            )
          : ListView.builder(
              physics: ScrollPhysics(parent: NeverScrollableScrollPhysics()),
              controller: _controller,
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, index) => AutoScrollTag(
                key: ValueKey(index),
                controller: _controller,
                index: index,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed(PreviewItem.route,
                        arguments: _movies[index]);
                  },
                  // onHorizontalDragEnd: (details) {

                  // },
                  onPanUpdate: (details) {
                    if (details.delta.dx > 0)
                      _scrollToIndex(
                          (index - 1) == 0 ? _movies.length - 1 : index - 1);
                    else
                      _scrollToIndex((index + 1) % _movies.length);
                  },
                  child: Consumer<PhotoProvider>(
                    builder: (ctx, image, child) {
                      final backdrop =
                          image.getMovieImages(_movies[index].id) ??
                              [keys.defaultImage, keys.defaultImage];
                     
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ),
                          image: DecorationImage(
                            image: NetworkImage(backdrop[1]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        margin: const EdgeInsets.all(5),
                        height: 300,
                        width: 360,
                        child: child,
                      );
                    },
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
            'US Box Office',
            style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
          ),
        ),
        aspectRatio,
        SizedBox(
          height: 13,
        ),
        InfoRow(_movies, ind)
      ],
    );
  }
}

class InfoRow extends StatelessWidget {
  final List<Movie> _movies;
  final int ind;

  const InfoRow(
    this._movies,
    this.ind,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        icons(
          Icons.star_outline,
          (_movies.isNotEmpty ? _movies[ind].rate : '-'),
        ),
        icons(Icons.calendar_today_outlined,
            (_movies.isNotEmpty ? _movies[ind].releaseDate.toString() : '-')),
        icons(Icons.timer_outlined,
            _movies.isNotEmpty ? _movies[ind].duration.toString() : '-'),
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
