import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:discuss_it/widgets/Item_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PosterItem extends StatelessWidget {
  final Movie movie;
  final double ratio;
  final Function(BuildContext ctx, Movie movie) _presentPopUp;
  PosterItem(this.movie, this.ratio, this._presentPopUp);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(ItemDetails.route, arguments: movie);
      },
      onLongPress: () {
        _presentPopUp(context, movie);
      },
      child: AspectRatio(
        aspectRatio: ratio,
        child: Container(
          padding: EdgeInsets.all(4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              FadeInImage(
                placeholder: AssetImage("assets/images/logo.png"),
                image: NetworkImage(
                  movie.posterURL,
                ),
                fit: BoxFit.contain,
              ),
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.black38),
                child: IconButton(
                    onPressed: () {
                      Provider.of<User>(context, listen: false).addToWatchList(movie);
                    },
                    icon: Icon(
                      Icons.add,
                      color: Colors.white,
                    )),
              ),
              Positioned(
                top: 5,
                right: 20,
                child: Container(
                  alignment: AlignmentDirectional.center,
                  decoration: BoxDecoration(
                      color: Colors.white54, shape: BoxShape.circle),
                  child: Stack(clipBehavior: Clip.none, children: [
                    Positioned(
                        top: 9,
                        left: 3,
                        child: Text(
                          (movie.rate < 0 ? '-' : '${movie.rate}'),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                    CircularProgressIndicator(
                      backgroundColor: Colors.black54,
                      valueColor: AlwaysStoppedAnimation(Colors.green),
                      value: movie.rate / 10.0,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
