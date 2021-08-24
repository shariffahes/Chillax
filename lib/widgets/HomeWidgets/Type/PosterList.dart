import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../models/providers/Movies.dart';
import '../../../models/providers/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PosterList extends StatefulWidget {
  final List<int> _items;
  final int k;
  PosterList(this._items, this.k);

  @override
  _PosterListState createState() => _PosterListState();
}

class _PosterListState extends State<PosterList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      key: PageStorageKey(widget.k),
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
  PosterItem(this._data, this.footer);

  @override
  Widget build(BuildContext context) {
    GlobalKey key = GlobalKey();

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
              key: key,
              height: 27.h,
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
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(
              _data.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
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
              fontSize: 15.sp,
            ),
          )
        ],
      ),
    );
  }
}

class ImagePoster extends StatelessWidget {
  final int id;
  const ImagePoster(
    this.id,
  );
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Universal.imageSource(id, 0, context),
      ),
    );
  }
}
