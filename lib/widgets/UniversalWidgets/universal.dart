import 'package:discuss_it/models/Enums.dart';
import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Universal {
  static RoundedRectangleBorder roundedShape(double radius) {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static Widget loadingWidget() {
    return Center(child: Image.asset('assets/images/TvSpinning.gif'));
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
          height: 3.7.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.all(Radius.elliptical(90, 85))),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.amber,
                size: 18.sp,
              ),
              SizedBox(
                width: 8.sp,
              ),
              Text(
                content,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
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
            size: 24.sp,
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
            size: 24.sp,
            color: Global.accent,
          ),
        );
    }
  }

  static Widget imageSource(int id, int flag, BuildContext ctx) {
    return Consumer<PhotoProvider>(
      builder: (ctx, image, _) {
        List<String> posters = [Global.defaultImage, Global.defaultImage];

        if (DataProvider.dataDB[id] != null)
          Provider.of<DataProvider>(ctx, listen: false)
              .fetchImage(id, Global.dataType, ctx);
        if (flag != 0 && flag != 1) {
          if (Global.isMovie()) {
            posters = image.getMovieImages(id) ?? posters;
          } else {
            posters = image.getShowImages(flag) ?? posters;
          }
          flag = 1;
        } else if (Global.isMovie())
          posters = image.getMovieImages(id) ?? posters;
        else {
          posters = image.getShowImages(id) ?? posters;
        }

        return FadeInImage(
            placeholder: AssetImage('assets/images/logo.png'),
            image: NetworkImage(
              posters[flag],
            ),
            fit: BoxFit.cover);
      },
    );
  }
}
