import 'dart:ui';

import 'package:discuss_it/models/providers/Movies.dart';
import 'package:flutter/material.dart';

class ItemList extends StatelessWidget {
  final Movie movie;
  final double ratio;
  ItemList(this.movie, this.ratio);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: ratio,
        child: Container(
          padding: EdgeInsets.all(4),
          child: FadeInImage(placeholder:  AssetImage("assets/images/logo.png"),
          image:
           NetworkImage(
            movie.posterURL,
          ),fit: BoxFit.contain,),
        ),
      ),
    );
  }
}
