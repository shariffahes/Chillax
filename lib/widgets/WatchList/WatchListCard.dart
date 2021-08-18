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
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _offsetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset(1.5, 0))
        .animate(_animationController);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  void moveToNextEps(Status statusOfData, User userProv, int id) {
    if (statusOfData == Status.watching) {
      _animationController.forward();

      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          userProv.watchComplete(id);
        });
      });
    } else {
      setState(() {
        userProv.watchComplete(id);
      });
    }
  }

  Episode? eps;
  @override
  Widget build(BuildContext context) {
    final userProv = widget.userProv;
    final data = widget._data;

    Status statusOfData = userProv.getStatus(widget._data.id);
    Track? track = userProv.track[data.id];
    int season = track?.currentSeason ?? widget.season;
    return Container(
      key: UniqueKey(),
      width: 200,
      height: 135,
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
          String title = 'Episode Completed.';

          if (snapshot.hasError) {
            return Universal.failedWidget();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            //_animationController.forward();
          }

          if (snapshot.connectionState == ConnectionState.done) {
            eps = snapshot.data;

            Future.delayed(Duration(milliseconds: 510), () {
              if (snapshot.data == null)
                userProv.completeShow(data.id);
              else {
                if (!_animationController.isDismissed &&
                        _animationController.isAnimating ||
                    _animationController.isCompleted) {
                  _animationController.reverse();
                }
              }
            });
            if (statusOfData == Status.watching && snapshot.data == null) {
              title = 'Watch complete. \n No more episodes';
            }
          }

          return LayoutBuilder(
            builder: (ctx, constraints) {
              return Stack(children: [
                Container(
                  color: Global.accent,
                  width: double.infinity,
                  height: 135,
                  child: Center(
                      child: Text(
                    title,
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
                    secondaryBackground: Container(
                      padding: const EdgeInsets.only(right: 20),
                      alignment: Alignment.centerRight,
                      color: Colors.red,
                      child: Text('Delete'),
                    ),
                    onDismissed: (dir) {
                      if (dir == DismissDirection.endToStart) {
                        userProv.deleteItem(data.id);
                    
                      } else {
                        moveToNextEps(statusOfData, userProv, data.id);
                      }
                    },
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
                              moveToNextEps(statusOfData, userProv, data.id);
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
    return Container(
      width: cnst.minWidth * 0.4,
      child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.elliptical(80, 125)),
          child: Consumer<PhotoProvider>(
            builder: (_, photoProv, __) {
           
              Provider.of<DataProvider>(context, listen: false)
                  .fetchImage(id, Global.dataType, context);
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
    this.constraints,
    this._data,
    this.status,
    this.episode,
    this._userProv,
  );

  void _startWatching(BuildContext ctx) {
    _userProv.startWatching(_data.id);
  }

  List<Widget> createFooter(
      String title, double percentUntilFinish, BuildContext ctx) {
    if (Global.isMovie()) return [Container()];
    if (status == Status.watchList)
      return [
        Container(
            height: 37,
            child: OutlinedButton(
                onPressed: () {
                  _startWatching(ctx);
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
    String title = _data.name;
    String sub1 = _data is Movie ? 'Movie' : 'Series';
    String sub2 = _data is Movie
        ? (_data as Movie).duration.toString() + 'min'
        : (_data as Show).airedEpisode.toString() + ' Eps';
    String footer = title;
    double percent = 0;

    if (status == Status.watching) {
      if (episode == null) {
        return Container();
      }
      footer = episode!.name;

      String numberOfEpisode = 'E' +
          (episode!.number.toString().length < 2
              ? '0${episode!.number.toString()}'
              : episode!.number.toString());
      String season = 'S' +
          (episode!.season.toString().length < 2
              ? '0${episode!.season.toString()}'
              : episode!.number.toString());

      int totalNbOfEps = (DataProvider.dataDB[_data.id] as Show)
          .episodes![episode!.season]!
          .length;
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
          ...createFooter(title, percent, context),
          SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}
