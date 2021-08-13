import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchListCard extends StatefulWidget {
  WatchListCard(this._data, this.userProv, {this.season = 1});
  final Data _data;
  final User userProv;
  int season = 1;

  @override
  _WatchListCardState createState() => _WatchListCardState();
}

class _WatchListCardState extends State<WatchListCard>
    with SingleTickerProviderStateMixin {
  late final _offsetAnimation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 4));

    _offsetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(1.5, 0))
        .animate(_animationController);
  }

  void moveToNextEps(
    int sec,
    int milliSec,
  ) {
    _animationController.forward();
    Future.delayed(Duration(seconds: sec, milliseconds: milliSec), () {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProv = widget.userProv;
    final data = widget._data;
    Episode? eps;
    Status statusOfData = userProv.getStatus(widget._data.id);
    Track? track = userProv.track[data.id];
    int season = track?.currentSeason ?? widget.season;
    return Container(
      key: UniqueKey(),
      width: 200,
      height: 130,
      color: Colors.white,
      margin: const EdgeInsets.all(5),
      padding: const EdgeInsets.all(5),
      child: FutureBuilder<Episode?>(
        //check if episodes are loaded or if we are in shows watching
        //load them if they are missing
        future: statusOfData == Status.watching
            ? Provider.of<User>(context, listen: false)
                .getEpisodeInfo(data.id, context, season: season)
            : null,
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Universal.failedWidget();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            print('waiting');
            _animationController.forward(from: 2);
            return Container(
              color: Colors.amber,
              width: double.infinity,
              height: 130,
              child: Center(
                child: Text(
                  'loading Season Info...',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            eps = snapshot.data;
            print(eps?.name);
            _animationController.reverse();
          }

          return LayoutBuilder(
            builder: (ctx, constraints) {
              return Stack(children: [
                Container(
                  color: Colors.amber,
                  width: double.infinity,
                  height: 130,
                  child: Center(
                      child: Text(
                    'loading next Episode ...',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  )),
                ),
                SlideTransition(
                  position: _offsetAnimation,
                  child: Dismissible(
                    key: UniqueKey(),
                    background: Container(
                      color: Colors.amber,
                    ),
                    onDismissed: (_) => moveToNextEps(0, 650),
                    child: Container(
                      color: Colors.white,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElipseImageView(constraints, data.id),
                          InfoColumn(
                              constraints, data, statusOfData, eps, userProv),
                          Spacer(),
                          IconButton(
                            icon: Icon(
                                statusOfData == Status.watchList
                                    ? Icons.circle_outlined
                                    : statusOfData == Status.watched
                                        ? Icons.check_circle_rounded
                                        : Icons.check_circle_outline,
                                size: 28),
                            onPressed: () {
                              if (statusOfData == Status.watching) {
                                moveToNextEps(0, 780);
                                userProv
                                    .getEpisodeInfo(data.id, ctx)
                                    .then((episode) {
                                  setState(() {
                                    eps = episode;
                                    userProv.watchComplete(data.id);
                                  });
                                });
                              } else {
                                setState(() {
                                  userProv.watchComplete(data.id);
                                });
                              }
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -7,
                  right: 0,
                  left: 0,
                  child: Divider(
                    endIndent: 5,
                    indent: 5,
                    thickness: 2,
                  ),
                )
              ]);
            },
          );
        },
      ),
    );
  }
}

class ElipseImageView extends StatelessWidget {
  final BoxConstraints cnst;
  final int id;
  const ElipseImageView(this.cnst, this.id);

  @override
  Widget build(BuildContext context) {
    print('build image');
    return Container(
      width: cnst.minWidth * 0.4,
      child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.elliptical(80, 125)),
          child: Consumer<PhotoProvider>(
            builder: (_, photoProv, __) {
              final dataType =
                  Global.isMovie() ? DataType.movie : DataType.tvShow;
              Provider.of<DataProvider>(context, listen: false)
                  .fetchImage(id, dataType, context);
              List<String> backdrop = [
                Global.defaultImage,
                Global.defaultImage
              ];
              if (Global.isMovie())
                backdrop = photoProv.getMovieImages(id) ?? backdrop;
              else
                backdrop = photoProv.getShowImages(id) ?? backdrop;

              return Image.network(
                backdrop[1],
              );
            },
          )),
    );
  }
}

class RowData extends StatelessWidget {
  const RowData(
    this.sub1,
    this.sub2,
  );

  final String sub1;
  final String sub2;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            sub1,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          SizedBox(
            width: 7,
          ),
          Icon(
            Icons.circle,
            size: 8,
            color: Colors.grey.shade700,
          ),
          SizedBox(
            width: 7,
          ),
          Text(
            sub2,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  final BoxConstraints constraints;
  final Data _data;
  final Status status;
  final Episode? episode;
  final User _userProv;
  const InfoColumn(
      this.constraints, this._data, this.status, this.episode, this._userProv);

  List<Widget> createFooter(String title, double percentUntilFinish) {
    if (Global.isMovie()) return [Container()];
    if (status == Status.watchList)
      return [
        Container(
            height: 37,
            child: OutlinedButton(
                onPressed: () {
                  _userProv.startWatching(_data.id);
                },
                child: Text('Start watching')))
      ];
    return [
      Text(
        title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey.shade600),
      ),
      Spacer(),
      LinearProgressIndicator(
        value: percentUntilFinish,
        backgroundColor: Colors.grey,
      ),
      SizedBox(
        height: 5,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    print('build info column');
    String title = _data.name;
    String sub1 = _data is Movie ? 'Movie' : 'Series';
    String sub2 = _data is Movie
        ? (_data as Movie).duration.toString() + 'min'
        : (_data as Show).airedEpisode.toString() + ' Eps';
    String footer = title;
    double percent = 0;

    if (status == Status.watching) {
      print('search episode $episode');
      if (episode == null) {
        print('null found');
        return Container();
      }
      footer = episode!.name;

      String numberOfEpisode = episode!.number.toString().length < 2
          ? 'E0${episode!.number.toString()}'
          : episode!.number.toString();
      String season = episode!.season.toString().length < 2
          ? 'S0${episode!.season.toString()}'
          : episode!.number.toString();

      int totalNbOfEps = (_data as Show).episodes![episode!.season]!.length;
      sub1 = season + numberOfEpisode;
      sub2 = totalNbOfEps.toString() + ' Eps';
      percent = episode!.number.toDouble() / totalNbOfEps.toDouble();
    }

    return Container(
      margin: const EdgeInsets.only(left: 3, top: 5),
      padding: const EdgeInsets.all(4.0),
      width: constraints.minWidth * 0.45,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            footer,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Spacer(),
          RowData(sub1, sub2),
          ...createFooter(title, percent),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}
