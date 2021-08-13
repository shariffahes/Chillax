import 'dart:async';
import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
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
  bool isWatching;

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

    if (Global.isMovie()) {
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
                WLImageView(widget._data),
                FutureBuilder<DataProvider>(
                  future: widget.isWatching
                      ? Provider.of<DataProvider>(context, listen: false)
                          .fetchEpisodes(widget._data.id)
                      : null,
                  builder: (ctx, snapshot) {
                    if (snapshot.hasError) {
                      print('err: ${snapshot.error}');
                      return Universal.failedWidget();
                    }
                    if (snapshot.hasData) {
                      final id = widget._data.id;
                      final track = widget._userProv.track[id] ??
                          Track(currentEp: 1, currentSeason: 1);

                      Episode? ep = snapshot.data!.getEpisodeInfo(
                          id, track.currentSeason, track.currentEp, context);

                      if (ep == null) {
                        widget._userProv.moveToWatched(id);
                      } else {
                        title = ep.name;
                        sub1 = 'S${ep.season}E${ep.number}';
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
                              fontSize: 16,
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
                                  fontSize: 14,
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
                          if (widget._data is Show &&
                              widget._userProv.getStatus(widget._data.id) ==
                                  Status.watchList)
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
                        print('run now');
                        widget._userProv.watchComplete(widget._data.id);
                        setState(() {
                          isVisible = true;
                        });
                      });
                    });
                  },
                  icon: Icon(
                    widget._userProv.getStatus(widget._data.id) ==
                            Status.watching
                        ? Icons.check_circle_outline
                        : widget._userProv.getStatus(widget._data.id) ==
                                Status.watched
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                    size: 28,
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

class WLImageView extends StatelessWidget {
  final Data data;
  const WLImageView(this.data);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 95,
      padding: const EdgeInsets.only(right: 8.0, top: 1.0),
      margin: const EdgeInsets.only(top: 6.0),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.elliptical(80, 110)),
        child: Consumer<PhotoProvider>(
          builder: (ctx, image, _) {
            List<String> backdrop = [Global.defaultImage, Global.defaultImage];
            if (Global.isMovie())
              backdrop = image.getMovieImages(data.id) ?? backdrop;
            else
              backdrop = image.getShowImages(data.id) ?? backdrop;

            return Stack(children: [
              Image.network(
                backdrop[1],
              ),
              if (!Global.isMovie())
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
                          (data as Show).status,
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
    );
  }
}
