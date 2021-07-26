import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import '../../../models/providers/Movies.dart';
import '../../../models/providers/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PosterList extends StatefulWidget {
  final List<Movie> _items;

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
            (movie) => Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(PreviewItem.route, arguments: movie);
                    },
                    child: Container(
                      height: 230,
                      child: Stack(
                        children: [
                          ImagePoster(movie.posterURL),
                          Consumer<User>(
                            builder: (ctx, user, _) {
                              final isAdded = user.isAdded(movie.id);

                              return IconButton(
                                alignment: AlignmentDirectional.topStart,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  isAdded
                                      ? user.removeFromList(movie.id)
                                      : user.addToWatchList(movie);
                                },
                                icon: Icon(
                                  isAdded
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
                      movie.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Universal.rateContainer(movie.rate),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class ImagePoster extends StatelessWidget {
  final String imageURL;
  const ImagePoster(this.imageURL);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: FadeInImage(
          placeholder: AssetImage('assets/images/logo.png'),
          image: NetworkImage(
            imageURL,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
