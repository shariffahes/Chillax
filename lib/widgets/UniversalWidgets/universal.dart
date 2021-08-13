import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:flutter/material.dart';

class Universal {
  static RoundedRectangleBorder roundedShape(double radius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static Widget loadingWidget() {
    return Center(child: CircularProgressIndicator());
  }

  static Widget failedWidget() {
    return Center(child: Text('Failed'));
  }

  static Widget footerContainer(String content, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.all(Radius.elliptical(90, 85))),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Colors.amber,
                size: 20,
              ),
              SizedBox(
                width: 4,
              ),
              Text(
                content,
                style: TextStyle(
                  color: Colors.white,
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  static Widget genreContainer(String content) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Text(
          content,
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
        ),
      ),
    );
  }

  static Widget createIcon(Status st, User user, Data _data) {
    switch (st) {
      case Status.watchList:
        return IconButton(
          alignment: AlignmentDirectional.topStart,
          padding: EdgeInsets.zero,
          onPressed: () {
            user.removeFromWatchList(_data.id);
          },
          icon: Icon(
            Icons.check_circle,
            size: 35,
            color: Global.accent,
          ),
        );
      case Status.watched:
        return ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
            Global.accent,
          )),
          onPressed: () {
            user.removeFromWatched(_data.id);
          },
          child: Text(
            'Watched',
            style: TextStyle(color: Colors.black),
          ),
        );
      case Status.watching:
        return ElevatedButton(
          onPressed: () {
            user.removeFromWatching(_data.id);
          },
          child: Text(
            'Watching',
            style: TextStyle(color: Colors.black),
          ),
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(
            Global.accent,
          )),
        );

      case Status.none:
        return IconButton(
          alignment: AlignmentDirectional.topStart,
          padding: EdgeInsets.zero,
          onPressed: () {
            user.addToWatchList(_data);
          },
          icon: Icon(
            Icons.add_circle_rounded,
            size: 35,
            color: Global.accent,
          ),
        );
    }
  }
}
