import 'package:discuss_it/models/keys.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import '../../../models/providers/Movies.dart';
import '../../../models/providers/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PosterList extends StatefulWidget {
  final List<Data> _items;

  PosterList(this._items);

  @override
  _PosterListState createState() => _PosterListState();
}

class _PosterListState extends State<PosterList> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: widget._items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(PreviewItem.route, arguments: item);
                    },
                    child: Container(
                      height: 230,
                      child: Stack(
                        children: [
                          ImagePoster(item.id),
                          Consumer<User>(
                            builder: (ctx, user, _) {
                              bool isMovieAdded = user.isMovieAdded(item.id);
                              bool isShowAdded = user.isShowAdded(item.id);

                              return IconButton(
                                alignment: AlignmentDirectional.topStart,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  final isMovieAdded =
                                      user.isMovieAdded(item.id);
                                  final isShowAdded = user.isShowAdded(item.id);

                                  isMovieAdded || isShowAdded
                                      ? user.removeFromList(item.id)
                                      : user.addToWatchList(item);
                                },
                                icon: Icon(
                                  isShowAdded || isMovieAdded
                                      ? Icons.check_circle
                                      : Icons.add_circle_rounded,
                                  size: 35,
                                  color: Colors.amber,
                                ),
                              );
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 140,
                    height: 60,
                    padding: const EdgeInsets.only(top: 10, bottom: 2),
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Universal.rateContainer(item.rate),
                ],
              ),
            ),
          )
          .toList(),
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
            List<String> posters = [keys.defaultImage];
            if (keys.isMovie())
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
