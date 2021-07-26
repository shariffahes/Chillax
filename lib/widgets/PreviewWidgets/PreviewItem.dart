import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/People.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreviewItem extends StatelessWidget {
  static const String route = '/preview_item';

  @override
  Widget build(BuildContext context) {
    final _movie = ModalRoute.of(context)!.settings.arguments as Movie;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          CustomAppBar(_movie),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                FutureBuilder<List<People>>(
                    future: Provider.of<MovieProvider>(context, listen: false)
                        .fetchCast(_movie.id),
                    builder: (_, snapshot) {
                      print(snapshot.error);
                      if (snapshot.hasError) return Universal.failedWidget();
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return Universal.loadingWidget();

                      final List<People> _cast = snapshot.data!;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        child: InfoColumn(movie: _movie, cast: _cast),
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
                final isAdded = user.isAdded(_movie.id);
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
                    isAdded
                        ? user.removeFromList(_movie.id)
                        : user.addToWatchList(_movie);
                  },
                  child: Text(isAdded ? 'Remove from List' : 'Add to list'),
                );
              },
            ),
            CircleAvatar(
              radius: 27,
              backgroundColor: Colors.red,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 25,
                child: Text(
                  _movie.rate.toString(),
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
  const InfoColumn({
    Key? key,
    required Movie movie,
    required List<People> cast,
  })  : _movie = movie,
        _cast = cast,
        super(key: key);

  final Movie _movie;
  final List<People> _cast;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _movie.name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 33,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Text(
            'Crime, thriller, Action',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Text(
            _movie.duration.toString(),
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          SizedBox(
            height: 14,
          ),
          Text(
            _movie.overview,
            style: TextStyle(height: 1.5, fontSize: 15),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _cast
                  .map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 17.0),
                        child: Actor(e.name, e.profileURL, e.character),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget {
  CustomAppBar(
    this._movie,
  );

  final Movie _movie;

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
            child: Image.network(
              _movie.backDropURL,
              fit: BoxFit.cover,
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
                child: Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 80),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Actor extends StatelessWidget {
  final String name;
  final String profileURL;
  final List<String> character;
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
          ...character.map((e) => Text(e)).toList(),
        ],
      ),
    );
  }
}
