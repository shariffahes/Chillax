import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/People.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviewItem extends StatelessWidget {
  static const String route = '/preview_item';

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
                FutureBuilder<List<People>>(
                    future: Provider.of<DataProvider>(context, listen: false)
                        .fetchCast(_data.id, context),
                    builder: (_, snapshot) {
                      if (snapshot.hasError) return Universal.failedWidget();
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Universal.loadingWidget();

                      final List<People> _cast = snapshot.data!;

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
                final isMovieAdded = user.isMovieAdded(_data.id);
                final isShowAdded = user.isShowAdded(_data.id);
                return ElevatedButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      fixedSize: MaterialStateProperty.all<Size>(
                        Size(210, 60),
                      )),
                  onPressed: () {
                    isMovieAdded || isShowAdded
                        ? user.removeFromList(_data.id)
                        : user.addToWatchList(_data as Movie);
                  },
                  child: Text(isMovieAdded || isShowAdded
                      ? 'Remove from List'
                      : 'Add to list'),
                );
              },
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.red,
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
  final List<People> _cast;

  @override
  Widget build(BuildContext context) {
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
                Text(_data.releaseDate.toString()),
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
                  (' mins'),
                ),
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
                return Card(
                  elevation: 5,
                  margin: const EdgeInsets.all(8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      e,
                      style: TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.grey),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          Divider(
            thickness: 2,
          ),
          Text(
            "Story line",
            style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
          ),
          Text(
            _data.overview,
            style: TextStyle(wordSpacing: 1, height: 2, fontSize: 15),
          ),
          Divider(
            thickness: 2,
          ),
          Text(
            "Cast",
            style: TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              height: 200,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _cast
                    .map((e) => AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ActorItem(e.name, e.id, e.character),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
        ],
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
                List<String> backdrop = [keys.defaultImage, keys.defaultImage];
                if (keys.isMovie())
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
                child: Text(
                  _data.rate,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
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
  final String name;
  final int id;
  final List<String> char;
  const ActorItem(this.name, this.id, this.char);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(44),
        bottomLeft: Radius.circular(44),
      ),
      child: GridTile(
        child: Consumer<PhotoProvider>(
          builder: (ctx, image, _) {
            final profile = image.getPersonProfiles(id) ?? [keys.defaultImage];

            return Image.network(
              profile[0],
              fit: BoxFit.cover,
            );
          },
        ),
        footer: Container(
          height: 100,
          color: Colors.black54,
          child: Stack(
            children: [
              GridTileBar(
                title: Text(name),
                subtitle: Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        char.map((e) => Expanded(child: Text(e))).toList(),
                  ),
                ),
              ),
              Positioned(
                  bottom: -8,
                  left: 0,
                  right: 0,
                  child: ElevatedButton(
                    child: Text('View more'),
                    onPressed: () {},
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
