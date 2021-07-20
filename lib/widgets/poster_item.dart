import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/widgets/Item_details.dart';
import 'package:flutter/material.dart';

class PosterItem extends StatelessWidget {
  final Movie movie;
  final double ratio;
  final Function(BuildContext ctx, Movie movie) _presentPopUp;
  PosterItem(this.movie, this.ratio, this._presentPopUp);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _presentPopUp(context, movie);
      },
      onLongPress: () {
        Navigator.of(context).pushNamed(ItemDetails.route, arguments: movie);
      },
      child: AspectRatio(
        aspectRatio: ratio,
        child: Container(
          padding: EdgeInsets.all(4),
          child: FadeInImage(
            placeholder: AssetImage("assets/images/logo.png"),
            image: NetworkImage(
              movie.posterURL,
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
