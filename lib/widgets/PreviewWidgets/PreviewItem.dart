import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/People.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/HomeWidgets/Type/PosterList.dart';
import 'package:discuss_it/widgets/Seasons/SeasonsCard.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class PreviewItem extends StatelessWidget {
  static const String route = '/preview_item';

  Widget textContent(Status status) {
    String title = '';
    switch (status) {
      case Status.watchList:
        title = 'Remove From WatchList';
        break;
      case Status.watched:
        title = 'Remove From Watched';
        break;
      case Status.watching:
        title = 'Remove From Watching';
        break;
      case Status.none:
        title = 'Add to WatchList';
        break;
    }
    return Text(
      title,
      style: TextStyle(color: Colors.black),
    );
  }

  void action(Status status, User user, Data _data) {
    switch (status) {
      case Status.watchList:
        user.removeFromWatchList(_data.id);
        break;
      case Status.watched:
        user.removeFromWatched(_data.id);
        break;
      case Status.watching:
        user.removeFromWatching(_data.id);
        break;
      case Status.none:
        user.addToWatchList(_data);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _data = ModalRoute.of(context)!.settings.arguments as Data;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          CustomAppBar(_data),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                FutureBuilder<List<People>?>(
                    future: Provider.of<DataProvider>(context, listen: false)
                        .fetchCast(_data.id, context),
                    builder: (_, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Universal.loadingWidget();
                      }
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Universal.failedWidget();
                      }

                      final List<People>? _cast = snapshot.data;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: InfoColumn(_data, _cast),
                      );
                    })
              ],
            ),
          ),
        ],
      ),
      persistentFooterButtons: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Consumer<User>(
              builder: (ctx, user, _) {
                final status = user.getStatus(_data.id);

                return ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Global.accent),
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(210, 60),
                      )),
                  onPressed: () {
                    action(status, user, _data);
                  },
                  child: textContent(status),
                );
              },
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: Global.accent,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 27,
                child: Text(
                  _data.certification,
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class InfoColumn extends StatelessWidget {
  const InfoColumn(
    this._data,
    this._cast,
  );

  final Data _data;
  final List<People>? _cast;

  List<Widget> setTitle(String title) {
    return [
      Divider(
        thickness: 2,
      ),
      Text(
        title,
        style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bool isShow = _data is Show;
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _data.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 33,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Flexible(
            child: Row(
              children: [
                Text(_data.yearOfRelease.toString()),
                SizedBox(
                  width: 7,
                ),
                Icon(
                  Icons.circle,
                  size: 5,
                ),
                SizedBox(
                  width: 7,
                ),
                Text(
                  (!isShow
                      ? (_data as Movie).duration.toString() + ' mins'
                      : _data is Episode
                          ? (_data as Episode).runTime.toString() + 'mins'
                          : (_data as Show).runTime.toString() + 'mins'),
                ),
                SizedBox(
                  width: 7,
                ),
                if (isShow) ...[
                  Icon(
                    Icons.circle,
                    size: 5,
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Text((_data as Show).network),
                  SizedBox(
                    width: 7,
                  ),
                  Icon(
                    Icons.circle,
                    size: 5,
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  Text((_data as Show).status)
                ]
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: _data.genre.map(
              (e) {
                return Universal.genreContainer(e);
              },
            ).toList(),
          ),
          ...setTitle('Story Line '),
          Text(
            _data.overview,
            style: TextStyle(wordSpacing: 1, height: 2, fontSize: 15),
          ),
          if (isShow) ...[
            ...setTitle('Seasons'),
            SeasonsView(_data.id),
          ],
          ...setTitle('Trailers and More'),
          MediaView(_data.tmdb),
          ...setTitle('Cast'),
          PreviewList(_cast, null, true),
          ...setTitle('Similar'),
          FutureBuilder<List<int>>(
              future: Provider.of<DataProvider>(context, listen: false)
                  .fetchDataBy(context, id: _data.id),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Universal.loadingWidget();

                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Universal.failedWidget();
                }
                return PreviewList(null, snapshot.data, false);
              }),
        ],
      ),
    );
  }
}

class PreviewList extends StatelessWidget {
  PreviewList(this._cast, this._data, this.isCast);

  final List<People>? _cast;
  final List<int>? _data;
  bool isCast;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        height: 200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: isCast && _cast != null
              ? _cast!
                  .map((e) => AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ActorItem(
                            e,
                            null,
                            true,
                          ),
                        ),
                      ))
                  .toList()
              : _data!
                  .map((id) => AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ActorItem(null, id, false),
                        ),
                      ))
                  .toList(),
        ),
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  CustomAppBar(
    this._data,
  );

  final Data _data;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      elevation: 0,
      pinned: true,
      expandedHeight: 400,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Consumer<PhotoProvider>(
              builder: (ctx, image, _) {
                List<String> backdrop = [
                  Global.defaultImage,
                  Global.defaultImage
                ];
                if (Global.isMovie())
                  backdrop = image.getMovieImages(_data.id) ?? backdrop;
                else
                  backdrop = image.getShowImages(_data.id) ?? backdrop;

                return Image.network(
                  backdrop[1],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Positioned(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(40)),
              ),
            ),
            bottom: -35,
            left: 0,
            right: 0,
          ),
          Positioned(
            bottom: 4,
            left: MediaQuery.of(context).size.width * 0.4,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(55),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 4, color: Colors.black87, spreadRadius: 1)
                ],
              ),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: Global.accent,
                child: Text(
                  _data.rate,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class ActorItem extends StatelessWidget {
  final bool isCast;
  final People? _cast;
  final int? id;
  ActorItem(
    this._cast,
    this.id,
    this.isCast,
  );

  @override
  Widget build(BuildContext context) {
    Data data = DataProvider.dataDB[id] ?? Global.defaultData;
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(44),
        bottomLeft: Radius.circular(44),
      ),
      child: GridTile(
        child: Consumer<PhotoProvider>(
          builder: (ctx, image, _) {
            var profile = [Global.defaultImage];
            if (isCast)
              profile = image.getPersonProfiles(_cast!.id) ?? profile;
            else
              profile = Global.isMovie()
                  ? image.getMovieImages(data.id) ?? profile
                  : image.getShowImages(data.id) ?? profile;

            return Image.network(
              profile[0],
              fit: BoxFit.cover,
            );
          },
        ),
        footer: Container(
          height: 100,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                color: Colors.black45,
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _cast?.name ?? data.name,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    if (isCast)
                      ..._cast!.character
                          .map((e) => Expanded(
                                child: Text(
                                  e,
                                  style: TextStyle(
                                      color: Colors.white.withAlpha(240)),
                                ),
                              ))
                          .toList()
                  ],
                ),
              ),
              Positioned(
                  bottom: -8,
                  left: 0,
                  right: 0,
                  child: ElevatedButton(
                    child: Text(
                      'View more',
                      style: TextStyle(color: Colors.black),
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Global.accent)),
                    onPressed: () {
                      if (!isCast)
                        Navigator.of(context)
                            .pushNamed(PreviewItem.route, arguments: data);
                    },
                  ))
            ],
          ),
        ),
      ),
    );
  }
}

class MediaView extends StatelessWidget {
  final tmdbId;
  const MediaView(this.tmdbId);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: Provider.of<DataProvider>(context, listen: false)
            .getVideosFor(tmdbId, Global.dataType),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Universal.loadingWidget();
          if (snapshot.hasError) {
            print(snapshot.error);
            return Universal.failedWidget();
          }
          List<String> keys = snapshot.data!;

          return Container(
            height: 200,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                  children: keys.map((key) {
                YoutubePlayerController _controller = YoutubePlayerController(
                    initialVideoId: key,
                    params: YoutubePlayerParams(
                      desktopMode: true,
                      showFullscreenButton: true,
                      autoPlay: false,
                    ));

                return Container(
                  width: 90.w,
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Global.accent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: YoutubePlayerIFrame(
                      controller: _controller,
                      gestureRecognizers: {
                        Factory<VerticalDragGestureRecognizer>(
                            () => VerticalDragGestureRecognizer()),
                      },
                    ),
                  ),
                );
              }).toList()),
            ),
          );
        });
  }
}

class SeasonsView extends StatelessWidget {
  final int id;
  const SeasonsView(this.id);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future:
            Provider.of<DataProvider>(context, listen: false).fetchSeasons(id),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Universal.loadingWidget();
          if (snapshot.hasError) {
            print(snapshot.error);
            return Universal.failedWidget();
          }
          Provider.of<DataProvider>(context, listen: false).fetchSeasons(
            id,
          );
          List<int> seasons =
              (DataProvider.dataDB[id]! as Show).episodes!.keys.toList();

          return Container(
            height: 280,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: seasons.length,
                itemBuilder: (ctx, index) {
                  return GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(22),
                                  topRight: Radius.circular(22))),
                          context: context,
                          builder: (ctx) => Container(
                              margin: EdgeInsets.all(5),
                              height: 80.h,
                              child: SeasonView(id, index + 1)));
                    },
                    child: AspectRatio(
                        aspectRatio: 2.6 / 4,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ImagePoster(id),
                            ),
                            Text(
                              'Season ${index + 1}',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  );
                }),
          );
        });
  }
}

class SeasonView extends StatelessWidget {
  final int id;
  final int season;
  const SeasonView(this.id, this.season);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Provider.of<DataProvider>(context, listen: false)
            .fetchSeasons(id, season: season),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Universal.loadingWidget();
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return Universal.failedWidget();
          }
          Show show = DataProvider.dataDB[id] as Show;
          List<Episode> episodes = show.episodes![season]!;
          return ListView.builder(
              itemCount: episodes.length,
              itemBuilder: (ctx, ind) {
                DateTime date =
                    DateTime.parse(episodes[ind].releasedDate).toLocal();
                DateFormat formatDate = DateFormat('yyyy-MM-dd');
                date = DateTime.parse(formatDate.format(date)).toLocal();
                final today =
                    DateTime.parse(formatDate.format(DateTime.now())).toLocal();
                final countDown = date.difference(today).inDays;
                return Container(
                  margin: EdgeInsets.all(5),
                  child: SeasonCard(id, season, ind + 1, show.name,
                      episodes[ind].name, countDown),
                );
              });
        });
  }
}
