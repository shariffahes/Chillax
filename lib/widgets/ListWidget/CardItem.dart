import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/PreviewWidgets/PreviewItem.dart';
import 'package:discuss_it/widgets/UniversalWidgets/universal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CardItem extends StatelessWidget {
  final Movie _movie;

  CardItem(this._movie);
  BorderRadius roundedBorder(double edge1, double edg2) {
    return BorderRadius.only(
      topLeft: Radius.circular(edge1),
      topRight: Radius.circular(edg2),
      bottomLeft: Radius.circular(edg2),
      bottomRight: Radius.circular(edge1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        
        Navigator.of(context).pushNamed(PreviewItem.route, arguments: _movie);
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: roundedBorder(17, 50),
        ),
        margin: const EdgeInsets.all(10),
        elevation: 7,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                height: 180,
                child: ClipRRect(
                  borderRadius: roundedBorder(22, 55),
                  child: Image(
                    image: NetworkImage(_movie.posterURL),
                  ),
                ),
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: InfoColumn(movie: _movie),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  const InfoColumn({
    Key? key,
    required Movie movie,
  })  : _movie = movie,
        super(key: key);

  final Movie _movie;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5.0),
      width: 240,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _movie.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Consumer<User>(
                    builder: (ctx, user, _) {
                      final isAdded = user.isAdded(_movie.id);

                      return IconButton(
                        onPressed: () {
                          isAdded
                              ? user.removeFromList(_movie.id)
                              : user.addToWatchList(_movie);
                        },
                        icon: Icon(
                          isAdded ? Icons.check_circle : Icons.add_circle,
                          size: 35,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Crime, Drama, Thriller',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(
            height: 3,
          ),
          Universal.rateContainer(_movie.rate),
          SizedBox(
            height: 2,
          ),
          Expanded(
            child: Container(
              height: 70,
              width: 200,
              child: Text(
                _movie.overview,
                style: TextStyle(
                  fontSize: 15,
                ),
                //height/17.5
                maxLines: 70 ~/ 17.5,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }
}
