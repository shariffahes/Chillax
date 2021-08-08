import 'dart:async';
import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchList extends StatefulWidget {
  final Data _data;
  final User _userProv;
  final bool isWatching;

  WatchList(this._data, this._userProv, {this.isWatching = false});

  @override
  _WatchListState createState() => _WatchListState();
}

class _WatchListState extends State<WatchList> {
  var isLoading = false;
  var isVisible = true;
  @override
  Widget build(BuildContext context) {
    String title;
    String sub1;
    String sub2;
    String showTitle = '';

    if (keys.isMovie()) {
      final movie = widget._data as Movie;
      title = movie.name;
      sub1 = 'Movie';
      sub2 = movie.duration.toString() + ' min';
    } else {
      if (widget.isWatching) {
        Show show = widget._data as Show;

        title = 'episode name';
        sub1 = 'S01E01';
        sub2 = show.runTime.toString() + ' min';
        showTitle = show.name;
      } else {
        final Show show = widget._data as Show;
        title = show.name;
        sub1 = 'Series';
        sub2 = show.airedEpisode.toString() + ' ep';
      }
    }

    return AnimatedOpacity(
      opacity: isVisible ? 1 : 0,
      duration: const Duration(milliseconds: 700),
      child: Dismissible(
        direction: DismissDirection.endToStart,
        background: Container(
          padding: const EdgeInsets.all(10),
          alignment: AlignmentDirectional.centerEnd,
          color: Colors.red,
          child: Text(
            'Remove From List',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        onDismissed: (_) => widget._userProv.deleteItem(widget._data.id),
        key: ValueKey(widget._data.id),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pushNamed(
            PreviewItem.route,
            arguments: widget._data,
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                Container(
                  width: 170,
                  padding: const EdgeInsets.only(right: 8.0, top: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.elliptical(70, 90)),
                    child: Consumer<PhotoProvider>(
                      builder: (ctx, image, _) {
                        List<String> backdrop = [
                          keys.defaultImage,
                          keys.defaultImage
                        ];
                        if (keys.isMovie())
                          backdrop =
                              image.getMovieImages(widget._data.id) ?? backdrop;
                        else
                          backdrop =
                              image.getShowImages(widget._data.id) ?? backdrop;

                        return Stack(children: [
                          Image.network(backdrop[1]),
                          if (!keys.isMovie())
                            Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                    alignment: AlignmentDirectional.center,
                                    width: double.infinity,
                                    color: Colors.black54,
                                    height: 30,
                                    child: Text(
                                      (widget._data as Show).status,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )))
                        ]);
                      },
                    ),
                  ),
                ),
                FutureBuilder<DataProvider>(
                  future: widget.isWatching
                      ? Provider.of<DataProvider>(context, listen: false)
                          .fetchEpisodes(widget._data.id)
                      : null,
                  builder: (ctx, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Universal.loadingWidget();

                    if (snapshot.hasError) return Universal.failedWidget();
                    if (snapshot.hasData) {
                      final id = widget._data.id;
                      final track = widget._userProv.track[id] ??
                          Track(currentEp: 1, currentSeason: 1);
                          
                      Episode? ep = snapshot.data!.getEpisodeInfo(
                          id, track.currentSeason, track.currentEp, context);
                      if (ep == null)
                        print('finish');
                      else {
                        title = ep.name;
                        sub1 = 'E${ep.number}S${ep.season}';
                      }
                    }

                    return Flexible(
                      fit: FlexFit.tight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              Text(
                                sub1,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(
                                width: 13,
                              ),
                              Icon(
                                Icons.circle,
                                size: 9,
                                color: Colors.grey.shade700,
                              ),
                              SizedBox(
                                width: 13,
                              ),
                              Text(
                                sub2,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              SizedBox(
                                width: 13,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          if (!keys.isMovie() &&
                              widget._userProv.isShowAdded(widget._data.id))
                            OutlinedButton(
                              onPressed: () {
                                widget._userProv.startWatching(widget._data.id);
                              },
                              child: Text('Start watching'),
                            )
                          else
                            Text(showTitle),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isVisible = false;
                      Timer(Duration(milliseconds: 500), () {
                        widget._userProv.watchComplete(widget._data.id);
                        setState(() {
                          isVisible = true;
                        });
                      });
                    });
                  },
                  icon: Icon(
                    widget._userProv.isMovieWatched(widget._data.id)
                        ? Icons.check_circle_rounded
                        : Icons.check_circle_outline_rounded,
                    size: 33,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
