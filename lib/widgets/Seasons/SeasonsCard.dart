import 'package:discuss_it/models/Global.dart';
import 'package:discuss_it/models/providers/Movies.dart';
import 'package:discuss_it/models/providers/PhotoProvider.dart';
import 'package:discuss_it/models/providers/User.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SeasonCard extends StatelessWidget {
  const SeasonCard(this.id, this.epsId, this.season, this.number, this.showName,
      this.epsName, this.countDown);
  final int season;
  final int number;
  final int? countDown;
  final String epsName;
  final String showName;
  final int id;
  final epsId;

  List<Widget> renderScheduleInfo() {
    final numberString =
        (number.toString().length > 1 ? 'E' : 'E0') + number.toString();
    final seasonString =
        (season.toString().length > 1 ? 'S' : 'S0') + season.toString();
    return [
      SizedBox(
        height: 10,
      ),
      Text(
        epsName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16.5.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(
        height: 8,
      ),
      Row(children: [
        Text(
          numberString,
          style: TextStyle(
            fontSize: 15.3.sp,
          ),
        ),
        SizedBox(
          width: 6,
        ),
        Icon(
          Icons.circle,
          size: 6,
        ),
        SizedBox(
          width: 5,
        ),
        Text(seasonString,
            style: TextStyle(
              fontSize: 15.3.sp,
            )),
      ]),
      Spacer(),
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          showName,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
        ),
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    var countDownWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (countDown == 0)
              Text('Today')
            else if (countDown == 1)
              Text('Tomorrow')
            else ...[
              Text(
                countDown.toString(),
              ),
              Text(
                'day(s)',
              )
            ],
          ],
        ));
    final userProv = Provider.of<User>(context, listen: false);
    final Track? track = userProv.track[id];
    Widget setIcon() {
      if (track == null || track.currentSeason > season)
        return IconButton(
            onPressed: () {}, icon: Icon(Icons.check_circle_rounded,size: 30,));
      else if (track.currentSeason < season)
        return IconButton(
            onPressed: () {}, icon: Icon(Icons.check_circle_outline,size: 30,));
      else if (track.currentSeason == season) {
        if (track.currentEp > number)
          return IconButton(
              onPressed: () {}, icon: Icon(Icons.check_circle_rounded,size: 30,));
        else if (track.currentEp < number)
          return IconButton(
              onPressed: () {}, icon: Icon(Icons.check_circle_outline,size: 30,));
        else if (track.currentEp == number)
          return IconButton(
              onPressed: () {}, icon: Icon(Icons.check_circle_outline,size: 30,));
      }
      return Container();
    }

    return Container(
      margin: const EdgeInsets.all(8),
      height: 110,
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(
            blurRadius: 4,
            spreadRadius: 1,
            color: Colors.grey.shade400,
            offset: Offset(0, 2)),
      ]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 110,
            margin: const EdgeInsets.only(right: 12),
            child: Consumer<PhotoProvider>(
              builder: (ctx, imageProv, __) {
                Provider.of<DataProvider>(context, listen: false).fetchImage(
                    id, Global.dataType, context,
                    season: season, episode: number, epsId: epsId);
                List<String> backdrop = [
                  Global.defaultImage,
                  Global.defaultImage
                ];
                if (Global.isMovie())
                  backdrop = imageProv.getMovieImages(id) ?? backdrop;
                else {
                  backdrop = imageProv.getShowImages(epsId) ?? backdrop;
                }

                return Image.network(
                  backdrop[1],
                  fit: BoxFit.cover,
                );
              },
            ),
          ),
          Flexible(
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [...renderScheduleInfo()],
            ),
          ),
          if (countDown == null)
            Container()
          else if (countDown! >= 0)
            countDownWidget
          else
            setIcon(),
        ],
      ),
    );
  }
}
