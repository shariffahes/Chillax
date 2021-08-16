import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import '../../../models/providers/Movies.dart';
import '../../../models/providers/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PosterList extends StatefulWidget {
  final List<int> _items;

  PosterList(this._items);

  @override
  _PosterListState createState() => _PosterListState();
}

class _PosterListState extends State<PosterList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: widget._items.map((item) {
        Data data = DataProvider.dataDB[item] ?? Global.defaultData;
        return PosterItem(
          data,
          Universal.footerContainer(data.rate, Icons.star),
        );
      }).toList(),
    );
  }
}

class PosterItem extends StatelessWidget {
  final Data _data;
  final Widget footer;
  const PosterItem(this._data, this.footer);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              Data info = _data;
              if (_data is Episode) info = DataProvider.dataDB[_data.id]!;
              Navigator.of(context)
                  .pushNamed(PreviewItem.route, arguments: info);
            },
            child: Container(
              height: 230,
              child: Stack(
                children: [
                  ImagePoster(_data.id),
                  Consumer<User>(
                    builder: (ctx, user, _) {
                      Status status = user.getStatus(_data.id);

                      return Universal.createIcon(status, user, _data);
                    },
                  )
                ],
              ),
            ),
          ),
          Container(
            width: 180,
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(
              _data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          footer,
          SizedBox(
            height: 6,
          ),
          Text(
            _data is Show
                ? (_data as Show).status.toUpperCase()
                : _data.yearOfRelease.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 15,
            ),
          )
        ],
      ),
    );
  }
}

class ImagePoster extends StatelessWidget {
  final int id;
  const ImagePoster(this.id);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Consumer<PhotoProvider>(
          builder: (ctx, image, _) {
            List<String> posters = [Global.defaultImage];
            if (Global.isMovie())
              posters = image.getMovieImages(id) ?? posters;
            else
              posters = image.getShowImages(id) ?? posters;

            return FadeInImage(
              placeholder: AssetImage('assets/images/logo.png'),
              image: NetworkImage(
                posters[0],
              ),
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}
