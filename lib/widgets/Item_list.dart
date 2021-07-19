import 'package:flutter/material.dart';

class ItemList extends StatelessWidget {
  final double ratio;
  ItemList(this.ratio);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: ratio,
        child: Container(
          padding: EdgeInsets.all(4),
          child: Image.network(
            "https://thumbs.dreamstime.com/b/film-reel-icon-video-icon-movie-symbol-dark-background-film-reel-icon-video-icon-movie-symbol-dark-background-simple-116780933.jpg",
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
