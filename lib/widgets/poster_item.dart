import 'package:flutter/material.dart';

class PosterItem extends StatelessWidget {
  final String imageURL;
  final double ratio;
  PosterItem(this.imageURL, this.ratio);
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: ratio,
        child: Container(
          padding: EdgeInsets.all(4),
          child: FadeInImage(
            placeholder: AssetImage("assets/images/logo.png"),
            image: NetworkImage(
              imageURL,
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
